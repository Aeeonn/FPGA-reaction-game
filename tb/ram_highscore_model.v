module ram_highscore (
    input wire [0:0] address,
    input wire clock,
    input wire [13:0] data,
    input wire wren,
    output reg [13:0] q
);

    reg [13:0] mem;

    initial begin
        mem = 14'd9999;
        q = 14'd9999;
    end

    always @(posedge clock) begin
        if (wren)
            mem <= data;
        q <= mem;
    end

endmodule
