`timescale 1ns / 1ps

module tb_btn_pulse_selfcheck;

    reg iCLK = 1'b0;
    reg iBTN = 1'b1; // active-low push button
    wire oBTN_PULSE;

    integer failures = 0;
    integer pulse_count = 0;

    always #10 iCLK = ~iCLK;

    btn_pulse dut (
        .iCLK(iCLK),
        .iBTN(iBTN),
        .oBTN_PULSE(oBTN_PULSE)
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

    task count_pulses;
        input integer cycles;
        integer i;
        begin
            pulse_count = 0;
            for (i = 0; i < cycles; i = i + 1) begin
                @(posedge iCLK);
                if (oBTN_PULSE)
                    pulse_count = pulse_count + 1;
            end
        end
    endtask

    initial begin
        // Let synchronizer initialize.
        count_pulses(6);
        check_cond(pulse_count == 0, "No pulses while button is idle");

        // One press-and-hold should create exactly one pulse.
        iBTN = 1'b0;
        count_pulses(8);
        check_cond(pulse_count == 1, "Press-and-hold creates exactly one pulse");

        // Keep holding low longer: still no extra pulses.
        count_pulses(8);
        check_cond(pulse_count == 0, "Holding low does not retrigger pulses");

        // Release should not create pulse.
        iBTN = 1'b1;
        count_pulses(6);
        check_cond(pulse_count == 0, "Release does not create pulse");

        // A second press should create a second single pulse.
        iBTN = 1'b0;
        count_pulses(8);
        check_cond(pulse_count == 1, "Second press creates one pulse");

        // A one-cycle low glitch can still be captured as one clean pulse.
        iBTN = 1'b1;
        @(posedge iCLK);
        iBTN = 1'b0;
        @(posedge iCLK);
        iBTN = 1'b1;
        count_pulses(6);
        check_cond(pulse_count == 1, "One-cycle glitch creates at most one pulse");

        if (failures == 0) begin
            $display("\nALL BTN_PULSE TESTS PASSED\n");
        end else begin
            $display("\nBTN_PULSE TESTS FAILED: %0d failure(s)\n", failures);
            $fatal(1, "tb_btn_pulse_selfcheck failed");
        end

        $finish;
    end

endmodule
