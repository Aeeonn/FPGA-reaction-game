module timer (iCLK, start_btn, stop_btn, leds, oTIMER, oFINAL, state);

input wire iCLK;
input wire start_btn;
input wire stop_btn;
output reg [9:0] leds;
output reg [13:0] oTIMER;
output reg [13:0] oFINAL = 14'd9999;
output reg [1:0] state = IDLE;

localparam IDLE = 0;
localparam WAIT_DELAY = 1;
localparam TIMING = 2;
localparam FINAL_SHOW = 3;

localparam LED_OFF = 10'b0000000000;
localparam LED_ON = 10'b1111111111;
localparam LED_WAIT = 10'b1110000111;


reg [25:0] counter = 0;
reg delay_triggered = 0;

wire [26:0] delay_value;
wire done_delay;
	
//Instantiate delay module
lfsr_delay delay (
	.iCLK(iCLK), 
	.iRST(1'b0),
	.iEN(delay_triggered), 
	.oDONE(done_delay), 
	.oDELAY(delay_value)
);
	
	
always @(posedge iCLK) begin
	case (state)
		IDLE: begin
			delay_triggered <= 0;
			oTIMER <= 0;
			leds <= LED_OFF;
			counter <= 0;
			
			
			if (start_btn) begin
				leds <= LED_WAIT;
				delay_triggered <= 1;
				state <= WAIT_DELAY;
			end
		end
			
		WAIT_DELAY: begin
			delay_triggered <= 0;
			if (done_delay) begin
				leds <= LED_ON;
				state <= TIMING;
			end
			
			if (stop_btn) begin
				oTIMER <= 10_000 - 1;
				leds <= 10'b0;
				state <= FINAL_SHOW;
			end
		end
		
		
		TIMING: begin
			if (counter < 16'd49999) begin
				counter <= counter + 1;
			end else begin
				counter <= 0;
				oTIMER <= oTIMER + 1;
			end
			
			if (stop_btn || oTIMER == 14'd10_000 - 1) begin
				state <= FINAL_SHOW;
				leds <= LED_OFF;
			end
		end
		
		FINAL_SHOW: begin
			oFINAL <= oTIMER;
			if (start_btn) begin
				state <= IDLE;
			end
		end
		
		default: state <= IDLE;
		
	endcase
end
	
endmodule