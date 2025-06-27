module reaction_game (
	//CLOCK
	input  wire        CLK_50,
	
	//SWITCHES
    input  wire [9:0]  SW,
	
	//BUTTONS
    input  wire [1:0]  KEY,
	
	//HEX DISPLAYS
    output wire [6:0]  HEX0, HEX1, HEX2, HEX4, HEX5,
    output wire [7:0]  HEX3,
	
	//LEDS
    output wire [9:0]  LEDR
);


	wire [9:0] led_from_timer;
	wire [9:0] led_from_highscore;
	wire [13:0] timer;
	wire [13:0] final_time;
	wire [13:0] display;
	wire btn0_pulse;
	wire btn1_pulse;
	wire [1:0] state;
	wire [13:0] stored_high_score;
	wire new_hs;

	btn_pulse btn0 (.iCLK(CLK_50), .iBTN(KEY[0]), .oBTN_PULSE(btn0_pulse));
	btn_pulse btn1 (.iCLK(CLK_50), .iBTN(KEY[1]), .oBTN_PULSE(btn1_pulse));
	
	timer timer1 (
		.iCLK(CLK_50), 
		.start_btn(btn0_pulse), 
		.stop_btn(btn1_pulse), 
		.leds(led_from_timer), 
		.oTIMER(timer),
		.oFINAL(final_time),
		.state(state)
	);
	
	update_highscore hs (
		.iCLK(CLK_50),
		.state(state),
		.sw(SW[0]),
		.current_score(final_time),
		.new_hs(new_hs),
		.q(stored_high_score)
	);
	
	new_highscore new (
		.iCLK(CLK_50),
		.new_hs(new_hs),
		.state(state),
		.leds(led_from_highscore)
	);
	
	assign display = SW[0] ? stored_high_score : timer;
	assign LEDR = new_hs ? led_from_highscore : led_from_timer;
	
	wire [3:0] thousandths = display % 10;
	wire [3:0] hundredths = (display / 10) % 10;
	wire [3:0] tenths = (display / 100) % 10;
	wire [3:0] secs = (display / 1000) % 10;
	
	hex_to_7seg display0 (.hex_digit(thousandths), .seg(HEX0));
	hex_to_7seg display1 (.hex_digit(hundredths), .seg(HEX1));
	hex_to_7seg display2 (.hex_digit(tenths), .seg(HEX2));
	hex_to_7seg display3 (.hex_digit(secs), .seg(HEX3));
	hex_to_7seg display4 (.hex_digit(10), .seg(HEX4));
	hex_to_7seg display5 (.hex_digit(10), .seg(HEX5));
	
endmodule