module timer #(
	parameter SIM_MODE = 0
	
)(iCLK, start_btn, stop_btn, leds, oTIMER, oFINAL, state);
	input wire iCLK;
	input wire start_btn;
	input wire stop_btn;
	output reg [9:0] leds;
	output reg [13:0] oTIMER;
	output reg [13:0] oFINAL = 14'd9999;
	output reg [1:0] state = 0; // 0 = IDLE, 1 = WAIT_DELAY, 2 = TIMING, 3 = FINAL TIME
	
	reg [25:0] counter = 0;
	reg delay_triggered = 0;
	
	wire [26:0] delay_value;
	wire done_delay;
	
	localparam REAL_TICK = 14'd49999; // ~1ms
	localparam SIM_TICK  = 14'd50;    // 1000x faster
	localparam TICK_VALUE = SIM_MODE ? SIM_TICK : REAL_TICK;

	
	
	//Instantiate delay module
	lfsr_delay #(.SIM_MODE(SIM_MODE)) delay (
		.iCLK(iCLK), 
		.iRST(1'b0),
		.iEN(delay_triggered), 
		.oDONE(done_delay), 
		.oDELAY(delay_value)
	);
	
	
	always @(posedge iCLK) begin
		case (state)
			0: begin //IDLE
				delay_triggered <= 0;
				oTIMER <= 0;
				leds <= 10'b0000000000;
				counter <= 0;
				
				
				if (start_btn) 
				begin
					leds <= 10'b1110000111;
					delay_triggered <= 1;
					state <= 1;
				end
			end
				
			1: begin //WAITING FOR DELAY
				delay_triggered <= 0;
				if (done_delay)
				begin
					leds <= 10'b1111111111;
					state <= 2;
				end
				
				if (stop_btn)
				begin
					oTIMER <= 10_000 - 1;
					leds <= 10'b0;
					state <= 3;
				end
			end
			
			
			2: begin //TIMING USER
				if (counter < TICK_VALUE) 
				begin
					counter <= counter + 1;
				end else begin
					counter <= 0;
					oTIMER <= oTIMER + 1;
				end
				
				if (stop_btn || oTIMER == 14'd10_000 - 1) 
				begin
					state <= 3;
					leds <= 10'b0000000000;
				end
			end
			
			3: begin //SHOW
				oFINAL <= oTIMER;
				if (start_btn) begin
					state <= 0;
				end
			end
			
			default: state <= 0;
			
		endcase
	end
	
endmodule