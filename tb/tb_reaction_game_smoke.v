`timescale 1ns / 1ps

module tb_reaction_game_smoke;

    reg        CLK_50 = 1'b0;
    reg [9:0]  SW = 10'b0;
    reg [1:0]  KEY = 2'b11; // active-low buttons on board

    wire [6:0] HEX0, HEX1, HEX2, HEX4, HEX5;
    wire [7:0] HEX3;
    wire [9:0] LEDR;

    integer failures = 0;

    // 50 MHz clock
    always #10 CLK_50 = ~CLK_50;

    reaction_game dut (
        .CLK_50(CLK_50),
        .SW(SW),
        .KEY(KEY),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .LEDR(LEDR)
    );

    task check_cond;
        input cond;
        input [255:0] msg;
        begin
            if (!cond) begin
                failures = failures + 1;
                $display("[FAIL] %0t: %0s", $time, msg);
            end else begin
                $display("[PASS] %0t: %0s", $time, msg);
            end
        end
    endtask

    task press_key0;
        begin
            @(negedge CLK_50);
            KEY[0] = 1'b0;
            repeat (2) @(negedge CLK_50);
            KEY[0] = 1'b1;
        end
    endtask

    task press_key1;
        begin
            @(negedge CLK_50);
            KEY[1] = 1'b0;
            repeat (2) @(negedge CLK_50);
            KEY[1] = 1'b1;
        end
    endtask

    initial begin
        repeat (5) @(posedge CLK_50);

        check_cond(dut.timer1.state == 2'd0, "Top-level powers up in IDLE state");

        press_key0();
        repeat (3) @(posedge CLK_50);
        check_cond(dut.timer1.state == 2'd1, "KEY0 start enters WAIT_DELAY");

        // Force delay completion so smoke test finishes quickly.
        force dut.timer1.done_delay = 1'b1;
        @(posedge CLK_50);
        release dut.timer1.done_delay;
        repeat (2) @(posedge CLK_50);
        check_cond(dut.timer1.state == 2'd2, "Random delay completion enters TIMING");

        press_key1();
        repeat (3) @(posedge CLK_50);
        check_cond(dut.timer1.state == 2'd3, "KEY1 stop enters SHOW");

        // Verify display source mux: SW[0]=1 selects high score storage path.
        SW[0] = 1'b1;
        @(posedge CLK_50);
        check_cond(dut.display == dut.stored_high_score, "SW0=1 selects stored high score");

        SW[0] = 1'b0;
        @(posedge CLK_50);
        check_cond(dut.display == dut.timer, "SW0=0 selects live timer");

        if (failures == 0) begin
            $display("\nTOP-LEVEL SMOKE TEST PASSED\n");
        end else begin
            $display("\nTOP-LEVEL SMOKE TEST FAILED: %0d failure(s)\n", failures);
            $fatal(1, "tb_reaction_game_smoke failed");
        end

        $finish;
    end

endmodule
