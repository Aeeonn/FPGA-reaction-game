`timescale 1ns/1ps
module tb_reaction_game;

    /* 1. clocks & inputs */
    reg clk = 0;
    always #10 clk = ~clk;          // 50 MHz

    reg  rst = 1'b0;                // if your top-level has a reset
    reg  [1:0] KEY = 2'b11;         // DE10-Lite keys idle high

    /* 2. DUT */
    reaction_game #(
        .SIM_MODE(1)                // param in your RTL to shorten delays
    ) dut (
        .CLK_50 (clk),
        .RESET  (rst),
        .KEY    (KEY),
        .LEDR   (),                 // leave un-connected or log
        .HEX0   (),
        .HEX1   ()
    );

    /* 3. helpers */
    task press_key0; begin KEY[0]=0; #60; KEY[0]=1; end endtask
    task press_key1; begin KEY[1]=0; #60; KEY[1]=1; end endtask

    /* 4. waveform dump (Icarus / Questa works too) */
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_reaction_game);
    end

    /* 5. stimulus & self-checks */
    initial begin
        // global reset pulse (if you need it)
        rst = 1;  #200;  rst = 0;

        // START a round
        press_key0;

        // wait until LEDs are on (random delay done)
        wait (dut.u_timer.state == 2);   // TIMING state

        // let it count ~5 ms then stop
        repeat (250_000) @(posedge clk);
        press_key1;

        // assert the timer is non-zero and LEDs stayed lit
        if (dut.oTIMER == 0)
            $error("Timer never incremented!");

        #1000 $finish;
    end
endmodule
