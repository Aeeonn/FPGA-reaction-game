`timescale 1ns / 1ps

module tb_timer_selfcheck;

    reg iCLK = 1'b0;
    reg start_btn = 1'b0;
    reg stop_btn = 1'b0;

    wire [9:0] leds;
    wire [13:0] oTIMER;
    wire [13:0] oFINAL;
    wire [1:0] state;

    integer failures = 0;

    // 50 MHz clock
    always #10 iCLK = ~iCLK;

    timer dut (
        .iCLK(iCLK),
        .start_btn(start_btn),
        .stop_btn(stop_btn),
        .leds(leds),
        .oTIMER(oTIMER),
        .oFINAL(oFINAL),
        .state(state)
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

    task pulse_start;
        begin
            @(negedge iCLK);
            start_btn = 1'b1;
            @(negedge iCLK);
            start_btn = 1'b0;
        end
    endtask

    task pulse_stop;
        begin
            @(negedge iCLK);
            stop_btn = 1'b1;
            @(negedge iCLK);
            stop_btn = 1'b0;
        end
    endtask

    initial begin
        // Let initial values settle.
        repeat (3) @(posedge iCLK);

        check_cond(state == 2'd0, "Initial state is IDLE");
        check_cond(oTIMER == 14'd0, "Timer starts at 0");

        // Case 1: Early stop during WAIT_DELAY -> penalty and SHOW state.
        pulse_start();
        @(posedge iCLK);
        check_cond(state == 2'd1, "After start pulse, state enters WAIT_DELAY");
        check_cond(leds == 10'b1110000111, "WAIT_DELAY LED pattern is shown");

        pulse_stop();
        @(posedge iCLK);
        check_cond(state == 2'd3, "Early stop sends FSM to SHOW");
        check_cond(oTIMER == 14'd9999, "Early stop applies 9999 penalty");
        check_cond(leds == 10'b0000000000, "LEDs clear in SHOW");

        // Case 2: Restart from SHOW using start pulse.
        pulse_start();
        @(posedge iCLK);
        check_cond(state == 2'd0, "Start pulse in SHOW returns FSM to IDLE");

        // Case 3: Normal run into TIMING, then stop and capture final.
        pulse_start();
        @(posedge iCLK);
        check_cond(state == 2'd1, "Second run enters WAIT_DELAY");

        // Force delay completion to avoid long random wait in simulation.
        force dut.done_delay = 1'b1;
        @(posedge iCLK);
        release dut.done_delay;
        @(posedge iCLK);
        check_cond(state == 2'd2, "Delay done moves FSM into TIMING");
        check_cond(leds == 10'b1111111111, "TIMING LED cue is shown");

        // Speed up one millisecond tick by preloading internal counter.
        @(negedge iCLK);
        dut.counter = 26'd49998;
        repeat (3) @(posedge iCLK);
        check_cond(oTIMER >= 14'd1, "Timer increments after 50k cycles equivalent");

        pulse_stop();
        @(posedge iCLK);
        check_cond(state == 2'd3, "Stop in TIMING goes to SHOW");
        @(posedge iCLK);
        check_cond(oFINAL == oTIMER, "SHOW captures final time");

        if (failures == 0) begin
            $display("\nALL TIMER TESTS PASSED\n");
        end else begin
            $display("\nTIMER TESTS FAILED: %0d failure(s)\n", failures);
            $fatal(1, "tb_timer_selfcheck failed");
        end

        $finish;
    end

endmodule
