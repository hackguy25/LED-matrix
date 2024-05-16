/*
Like `1bpc_colors`, but drive pixels and lines independently.
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
	output [5:0] led,
);

wire color_clk;

// External clock is 27MHz, divide it by 27 to get a 1MHz pulse.
prescaler #(
    .NUM(27),
    .NUM_BITS(32),
)
color_psc (
    .clk(clk),
    .rst(!S2),
    .enable(color_clk),
);

// Only the first 3 bits are used for color, the rest are padding.
reg [0:13] color;

// Pixel state.
// Larger S => less time spent with output disabled, more time displaying color.
localparam S = 7;
reg [S-1:0] state;

assign led[0] = color[0];
assign led[1] = color[0];
assign led[2] = color[1];
assign led[3] = color[1];
assign led[4] = color[2];
assign led[5] = color[2];

assign H75_R1 = color[0];
assign H75_R2 = color[0];
assign H75_G1 = color[1];
assign H75_G2 = color[1];
assign H75_B1 = color[2];
assign H75_B2 = color[2];

always @(posedge clk) begin
    if (color_clk) begin
        case (state)
            // Raise OE high.
            S'd0: H75_OE <= 1'b1;
            // Change color.
            S'd1: color <= color + 1'b1;
            // Clock the color in.
            S'd2: H75_Clk <= 1'b1;
            S'd3: H75_Clk <= 1'b0;
            // Latch the line.
            S'd4: H75_Lat <= 1'b1;
            S'd5: H75_Lat <= 1'b0;
            // Pull OE low.
            S'd6: H75_OE <= 1'b0;
        endcase
        state <= state + 1'b1;
    end
end


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

reg [4:0] line;

assign H75_A = line[0];
assign H75_B = line[1];
assign H75_C = line[2];
assign H75_D = line[3];
assign H75_E = line[4];

always @(posedge clk) begin
    if (pixel_clk) begin
        line <= line + 1;
    end
end

endmodule
