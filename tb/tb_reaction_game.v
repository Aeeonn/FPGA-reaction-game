`timescale 1ns / 1ps

module tb_reaction_game();

    reg        CLK_50;
    reg [9:0]  SW;
    reg [1:0]  KEY;

    wire [6:0] HEX0, HEX1, HEX2, HEX4, HEX5;
    wire [7:0] HEX3;
    wire [9:0] LEDR;

    reaction_game #(.SIM_MODE(1)) dut (
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

    // Clock: 50 MHz
    initial begin
        CLK_50 = 0;
        forever #10 CLK_50 = ~CLK_50;
    end

    // Stimulus
    initial begin
        // Initialize inputs
        SW = 10'b0;
        KEY = 2'b11;

        #100;
        KEY[0] = 0;  // press button 0
        #40;
        KEY[0] = 1;  // release button 0

        #200;
        SW[0] = 1;   // toggle switch 0 on
        #100;
        SW[0] = 0;   // toggle switch 0 off

        #200;
        KEY[1] = 0;  // press button 1
        #40;
        KEY[1] = 1;  // release button 1

        #500;
        $finish;
    end

	reg test_signal;
	initial begin
		test_signal = 0;
		forever #50 test_signal = ~test_signal;
	end

    // Monitor key signals
    initial begin
        $monitor("Time=%0t | SW=%b | KEY=%b | LEDR=%b", $time, SW, KEY, LEDR);
    end

	
endmodule
