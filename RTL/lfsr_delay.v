module lfsr_delay #(
//for a testbench simulation, this is good practice (to override the time instead of waiting 2 seconds)
    parameter SEED   = 27'h1ABCDE7,
    parameter MIN_CYC = 25_000_000,   // 0.5 s @ 50 MHz   (synthesis)
    parameter RANGE   = 75_000_000    // 2 s – 0.5 s
)(iCLK, iRST, iEN, oDONE, oDELAY);
    input wire iCLK;
    input wire iRST;
    input wire iEN;
    output reg oDONE = 0;
    output reg [26:0] oDELAY;

    reg [26:0] lfsr = 27'h1ABCDE7;
    reg [26:0] counter = 0;
    reg waiting = 0;
	
	// taps for primitive polynomial x^27 + x^26 + x^25 + x^22 + 1
    wire feedback = lfsr[26] ^ lfsr[25] ^ lfsr[21];

    always @(posedge iCLK) begin

    //---------------- default state (reset) ----------------
    if (iRST) begin
        lfsr <= 27'h1ABCDE7;
        counter <= 0;
        oDELAY <= 25_000_000;   // parking value
        waiting <= 0;
        oDONE <= 0;
    end
	
    //---------------- normal operation ------------
    else begin //if reset == 0

		lfsr <= {lfsr[25:0], feedback};

		// 2. capture a fresh delay when enable is pulsed
		if (iEN && !waiting) begin
			oDELAY <= 25_000_000 + (lfsr % 75_000_001);
			counter <= 0;
			waiting <= 1;
			oDONE <= 0;
		end
		// 3. count down until the delay expires
		else if (waiting) begin
			if (counter < oDELAY)
				counter <= counter + 1;
			else begin
				oDONE    <= 1;
				waiting <= 0;
			end
		end
		// 4. if enable is low and we're idle, keep done low
		else
			oDONE <= 0;
    end
end


endmodule
