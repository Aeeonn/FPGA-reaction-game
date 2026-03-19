`timescale 1ns / 1ps

module tb_update_highscore_selfcheck;

    reg iCLK = 1'b0;
    reg [1:0] state = 2'd0;
    reg sw = 1'b0;
    reg [13:0] current_score = 14'd9999;

    wire new_hs;
    wire [13:0] q;

    integer failures = 0;

    always #10 iCLK = ~iCLK;

    update_highscore dut (
        .iCLK(iCLK),
        .state(state),
        .sw(sw),
        .current_score(current_score),
        .new_hs(new_hs),
        .q(q)
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

    task step_cycles;
        input integer n;
        integer i;
        begin
            for (i = 0; i < n; i = i + 1)
                @(posedge iCLK);
        end
    endtask

    initial begin
        // Allow init write/read pipeline to settle in IDLE.
        state = 2'd0;
        current_score = 14'd9999;
        step_cycles(8);

        check_cond(q == 14'd9999, "Initial stored high score is 9999");
        check_cond(new_hs == 1'b0, "new_hs is low when score equals high score");

        // Better score should be recognized and written during SHOW.
        current_score = 14'd1234;
        #1;
        check_cond(new_hs == 1'b1, "new_hs is high for better score");

        state = 2'd3; // SHOW triggers write path
        step_cycles(3);

        state = 2'd0; // IDLE reads back stored value
        step_cycles(4);
        check_cond(q == 14'd1234, "Better score is written to high score RAM");

        // Worse score should not overwrite existing high score.
        current_score = 14'd2000;
        #1;
        check_cond(new_hs == 1'b0, "new_hs is low for worse score");
        state = 2'd3;
        step_cycles(3);

        state = 2'd0;
        step_cycles(4);
        check_cond(q == 14'd1234, "Worse score does not overwrite stored high score");

        // Another improvement should overwrite.
        current_score = 14'd1100;
        #1;
        check_cond(new_hs == 1'b1, "new_hs is high for new best score");
        state = 2'd3;
        step_cycles(3);

        state = 2'd0;
        step_cycles(4);
        check_cond(q == 14'd1100, "New best score overwrites stored high score");

        if (failures == 0) begin
            $display("\nALL UPDATE_HIGHSCORE TESTS PASSED\n");
        end else begin
            $display("\nUPDATE_HIGHSCORE TESTS FAILED: %0d failure(s)\n", failures);
            $fatal(1, "tb_update_highscore_selfcheck failed");
        end

        $finish;
    end

endmodule
