/*
Display a 1BPC image on an LED matrix, but refactored into separate files.
*/

`include "includes/prescaler.v"
`include "includes/three_rings.v"
`include "includes/LED_matrix/LM_pixel_loop.v"

module top (
    input clk,
    input S2,
    output H75_R1,
    output H75_R2,
    output H75_G1,
    output H75_G2,
    output H75_B1,
    output H75_B2,
    output H75_A,
    output H75_B,
    output H75_C,
    output H75_D,
    output H75_E,
    output H75_OE,
    output H75_Clk,
    output H75_Lat,
);

// 1MHz clock is desired, so divide the 27MHz external clock by 27.
wire pixel_clk;
prescaler #(
    .NUM(27),
    .NUM_BITS(32),
)
pixel_psc (
    .clk(clk),
    .rst(1'b0),
    .enable(pixel_clk),
);

wire [4:0] line;
wire [4:0] next_line;
wire [5:0] next_column;

assign H75_A = line[0];
assign H75_B = line[1];
assign H75_C = line[2];
assign H75_D = line[3];
assign H75_E = line[4];

three_rings tr(
    .line(next_line),
    .column(next_column),
    .r1(H75_R1),
    .r2(H75_R2),
    .g1(H75_G1),
    .g2(H75_G2),
    .b1(H75_B1),
    .b2(H75_B2),
);

// Ignore the slice parameter.
LM_pixel_loop pl(
    .clk(clk),
    .clk_enable(pixel_clk),
    .line(line),
    .next_line(next_line),
    .next_column(next_column),
    .matrix_OE(H75_OE),
    .matrix_clk(H75_Clk),
    .matrix_lat(H75_Lat),
);

endmodule
