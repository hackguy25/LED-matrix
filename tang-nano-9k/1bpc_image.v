/*
Display a 1BPC image on an LED matrix.
*/

`include "includes/prescaler.v"
`include "includes/three_rings.v"

module top (
    input clk,
    input S2,
    output reg H75_R1,
    output reg H75_R2,
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

wire [4:0] column;
assign column = state[5:1];
wire next_r1;
wire next_r2;
wire next_g1;
wire next_g2;
wire next_b1;
wire next_b2;

three_rings tr(
    .line(line),
    .column(column),
    .r1(next_r1),
    .r2(next_r2),
    .g1(next_g1),
    .g2(next_g2),
    .b1(next_b1),
    .b2(next_b2),
);

always @(posedge clk) begin
    if (pixel_clk) begin
        casex (state)
            8'b00xx_xxx0: begin
                // Set clock low.
                H75_Clk <= 1'b0;
                H75_R1 <= next_r1;
                H75_R2 <= next_r2;
                H75_G1 <= next_g1;
                H75_G2 <= next_g2;
                H75_B1 <= next_b1;
                H75_B2 <= next_b2;
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
                line <= line + 1;
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
