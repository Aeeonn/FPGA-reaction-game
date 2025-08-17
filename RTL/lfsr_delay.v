module lfsr_delay #(
	parameter SIM_MODE = 0
	
)(iCLK, iRST, iEN, oDONE, oDELAY);
    input wire iCLK;
    input wire iRST;
    input wire iEN;
    output reg oDONE = 0;
    output reg [26:0] oDELAY;

    reg [26:0] lfsr = 27'h1ABCDE7;
    reg [26:0] counter = 0;
    reg waiting = 0;
	
    localparam REAL_MAX = 27'd25_000_000;
    localparam SIM_MAX  = 27'd1_000;
    wire [26:0] max_delay = SIM_MODE ? SIM_MAX : REAL_MAX;

	// taps for primitive polynomial x^27 + x^26 + x^25 + x^22 + 1
    wire feedback = lfsr[26] ^ lfsr[25] ^ lfsr[24] ^ lfsr[21];

    always @(posedge iCLK) begin

    //---------------- default state (reset) ----------------
    if (iRST) begin
        lfsr <= 27'h1ABCDE7;
		oDELAY <= max_delay;
        counter <= 0;
        waiting <= 0;
        oDONE <= 0;
    end
	
    //---------------- normal operation ------------
    else begin //if reset == 0

		lfsr <= {lfsr[25:0], feedback};

		// capture a fresh delay when enable is pulsed
		if (iEN && !waiting) begin
			oDELAY <= max_delay + (lfsr % (max_delay * 3 + 1));
			counter <= 0;
			waiting <= 1;
			oDONE <= 0;
		end
		// count down until the delay expires
		else if (waiting) begin
			if (counter < oDELAY)
				counter <= counter + 1;
			else begin
				oDONE    <= 1;
				waiting <= 0;
			end
		end
		// if enable is low and we're idle, keep done low
		else
			oDONE <= 0;
    end
end


endmodule
