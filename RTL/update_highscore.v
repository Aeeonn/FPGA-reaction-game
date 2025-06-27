module update_highscore (
    input wire iCLK,
    input wire [1:0] state,
    input wire sw,
    input wire [13:0] current_score,
	output wire new_hs,
    output wire [13:0] q
);

    localparam HIGH_SCORE_DATA_WIDTH = 14;
    localparam HIGH_SCORE_ADDR_WIDTH = 1;

    wire [HIGH_SCORE_ADDR_WIDTH-1:0] ram_address;
    reg [HIGH_SCORE_DATA_WIDTH-1:0] ram_data_in;
    reg ram_wren;
    wire [HIGH_SCORE_DATA_WIDTH-1:0] ram_data_out;

    reg [HIGH_SCORE_DATA_WIDTH-1:0] stored_high_score;
    reg init_done = 0;

    assign ram_address = 1'd0; // single address RAM
    assign q = stored_high_score;
	assign new_hs = current_score < stored_high_score;

    highscore hs_ram (
        .address(ram_address),
        .clock(iCLK),
        .data(ram_data_in),
        .wren(ram_wren),
        .q(ram_data_out)
    );

    always @(posedge iCLK) begin
        if (!init_done) begin
            ram_data_in <= 14'd9999;
            ram_wren <= 1'b1;
            init_done <= 1'b1;
        end else begin
            // Default to not writing unless conditions below match
            ram_wren <= 1'b0;

            if (state == 2'd0) begin
                // Read high score from RAM
                stored_high_score <= ram_data_out;

            end else if (current_score < stored_high_score && state == 3) begin
                // Write new high score
                ram_data_in <= current_score;
                ram_wren <= 1'b1;
            end
        end
    end

endmodule
