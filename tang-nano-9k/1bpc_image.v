/*
Display a 1BPC image on an LED matrix.
*/

`include "includes/prescaler.v"

module top (
    input clk,
    input S2,
    output reg H75_R2,
    output reg H75_R1,
    output reg H75_G1,
    output reg H75_G2,
    output reg H75_B1,
    output reg H75_B2,
    output H75_A,
    output H75_B,
    output H75_C,
    output H75_D,
    output H75_E,
    output reg H75_OE,
    output reg H75_Clk,
    output reg H75_Lat,
);

// Hex inverse ref:
// 0 0   4 2   8 1   c 3
// 1 8   5 a   9 9   d b
// 2 4   6 6   a 5   e 7
// 3 c   7 e   b d   f f

// An image of 3 rings.
// Each block is of type `[0:63] x [31:0]`.

// Top half of the red channel.
localparam img_r1 = {
    64'h0000007ffe000000, 64'h000007ffffe00000, 64'h00001ffffff80000, 64'h00007ff81ffe0000,
    64'h0001ff0000ff8000, 64'h0007f800001fe000, 64'h000fe0000007f000, 64'h001f80000001f800,
    64'h003f00000000fc00, 64'h007c000000003e00, 64'h00f8000000001f00, 64'h01f0000000000f80,
    64'h03e00000000007c0, 64'h07c00000000003e0, 64'h07800000000001e0, 64'h0f800000000001f0,
    64'h0f000000000000f0, 64'h1e00000000000078, 64'h1e00000000000078, 64'h3c0000000000003c,
    64'h3c0000000000003c, 64'h780000000000001e, 64'h780000000000001e, 64'h780000000000001e,
    64'h700000000000000e, 64'hf00000000000000f, 64'hf00000000000000f, 64'hf00000000000000f,
    64'hf00000000000000f, 64'he000000000000007, 64'he000000000000007, 64'he000000000000007
};

// Bottom half of the red channel.
localparam img_r2 = {
    64'he000000000000007, 64'he000000000000007, 64'he000000000000007, 64'hf00000000000000f,
    64'hf00000000000000f, 64'hf00000000000000f, 64'hf00000000000000f, 64'h700000000000000e,
    64'h780000000000001e, 64'h780000000000001e, 64'h780000000000001e, 64'h3c0000000000003c,
    64'h3c0000000000003c, 64'h1e00000000000078, 64'h1e00000000000078, 64'h0f000000000000f0,
    64'h0f800000000001f0, 64'h07800000000001e0, 64'h07c00000000003e0, 64'h03e00000000007c0,
    64'h01f0000000000f80, 64'h00f8000000001f00, 64'h007c000000003e00, 64'h003f00000000fc00,
    64'h001f80000001f800, 64'h000fe0000007f000, 64'h0007f800001fe000, 64'h0001ff0000ff8000,
    64'h00007ff81ffe0000, 64'h00001ffffff80000, 64'h000007ffffe00000, 64'h0000007ffe000000
};

// Top half of the green channel.
localparam img_g1 = {
    64'h0000001ff8000000, 64'h0000007ffe000000, 64'h000001ffff800000, 64'h000003fc3fc00000,
    64'h000007e007e00000, 64'h00000f8001f00000, 64'h00001f0000f80000, 64'h00001e0000780000,
    64'h00003c00003c0000, 64'h00003c00003c0000, 64'h00007800001e0000, 64'h00007800001e0000,
    64'h00007800001e0000, 64'h00007000000e0000, 64'h00007000000e0000, 64'h00007000000e0000,
    64'h00007000000e0000, 64'h00007800001e0000, 64'h00007800001e0000, 64'h00007800001e0000,
    64'h00003c00003c0000, 64'h00003c00003c0000, 64'h00001e0000780000, 64'h00001f0000f80000,
    64'h00000f8001f00000, 64'h000007e007e00000, 64'h000003fc3fc00000, 64'h000001ffff800000,
    64'h0000007ffe000000, 64'h0000001ff8000000, 64'h0000000000000000, 64'h0000000000000000
};

// Bottom half of the green channel, all zeros.
localparam img_g2 = {32{64'h0000000000000000}};

// Top half of the blue channel.
localparam img_b1 = {
    64'h0000000001ffe000, 64'h0000000007fff800, 64'h000000001ffffe00, 64'h000000007fc0ff80,
    64'h00000000fe001fc0, 64'h00000001f8000730, 64'h00000003f00003f0, 64'h00000007c00000f8,
    64'h0000000780000078, 64'h0000000f8000007c, 64'h0000000f0000003c, 64'h0000001e0000001e,
    64'h0000001e0000001e, 64'h0000003c0000000f, 64'h0000003c0000000f, 64'h0000003c0000000f,
    64'h0000003800000007, 64'h0000003800000007, 64'h0000003800000007, 64'h0000003800000007,
    64'h0000003800000007, 64'h0000003800000007, 64'h0000003c0000000f, 64'h0000003c0000000f,
    64'h0000003c0000000f, 64'h0000001e0000001e, 64'h0000001e0000001e, 64'h0000000f0000003c,
    64'h0000000f8000007c, 64'h0000000780000078, 64'h00000007c00000f8, 64'h00000003f00003f0
};

// Bottom half of the blue channel.
localparam img_b2 = {
    64'h00000001f8000730, 64'h00000000fe001fc0, 64'h000000007fc0ff80, 64'h000000001ffffe00,
    64'h0000000007fff800, 64'h0000000001ffe000, 64'h0000000000000000, 64'h0000000000000000,
    64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000,
    64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000,
    64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000,
    64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000,
    64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000,
    64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000, 64'h0000000000000000
};


wire pixel_clk;

// 1MHz clock is desired, so divide the 27MHz external clock by 27.
prescaler #(
    .NUM(27),
    .NUM_BITS(32),
)
pixel_psc (
    .clk(clk),
    .rst(1'b0),
    .enable(pixel_clk),
);

reg [7:0] state;
reg [4:0] line;

assign H75_A = line[0];
assign H75_B = line[1];
assign H75_C = line[2];
assign H75_D = line[3];
assign H75_E = line[4];

wire [4:0] next_line;
assign next_line = line + 1;

wire [4:0] column;
assign column = state[5:1];

wire [0:5] next_color;

// TODO: This.
assign next_color = case (next_line)
    for (i = 0; i < 32; i = i + 1)
endcase

always @(posedge clk) begin
    if (pixel_clk) begin
        casex (state)
            8'b00xx_xxx0: begin
                // Set clock low.
                H75_Clk <= 1'b0;
                H75_R1 <= next_color[0];
                H75_R2 <= next_color[1];
                H75_G1 <= next_color[2];
                H75_G2 <= next_color[3];
                H75_B1 <= next_color[4];
                H75_B2 <= next_color[5];
            end
            8'b00xx_xxx1: begin
                // Set clock high.
                H75_Clk <= 1'b1;
            end
            8'b0100_0000: begin
                // Set clock to final low.
                H75_Clk <= 1'b0;
            end
            // -----
            8'b1111_1100: begin
                // Pull Output Enable high.
                H75_OE <= 1'b1;
            end
            8'b1111_1101: begin
                // Latch high.
                H75_Lat <= 1'b1;
                // Update line.
                line <= next_line;
            end
            8'b1111_1110: begin
                // Latch low.
                H75_Lat <= 1'b0;
            end
            8'b1111_1111: begin
                // Pull Output Enable low.
                H75_OE <= 1'b0;
            end
        endcase
        state <= state + 1'b1;
    end
end

endmodule
