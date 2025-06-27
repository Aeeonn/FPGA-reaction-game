module new_highscore(
    input wire iCLK,
    input wire new_hs,
    input wire [1:0] state,
    output reg [9:0] leds
);

    reg [22:0] counter = 0;

    always @(posedge iCLK) begin
        if (state == 2'd3 && new_hs) begin
            counter <= counter + 1;

            if (counter == 23'd0)
                leds <= 10'b1010101010;
            else if (counter == 23'd4_000_000)
                leds <= 10'b0101010101;
            else if (counter >= 23'd8_000_000)
                counter <= 0;
        end
    end
endmodule
