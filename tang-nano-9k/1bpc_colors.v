/*
Drive an LED matrix with changing 1BPC solid color.
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

// Color should change once per second, so divide the 27MHz external clock by 27'000'000.
prescaler #(
    .NUM(27000000),
    .NUM_BITS(32),
)
color_psc (
    .clk(clk),
    .rst(!S2),
    .enable(color_clk),
);

reg [2:0] color;

assign led[0] = color[0];
assign led[1] = color[0];
assign led[2] = color[1];
assign led[3] = color[1];
assign led[4] = color[2];
assign led[5] = color[2];

always @(posedge clk) begin
    if (color_clk) begin
        color <= color + 1'b1;
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

/*
The HUB75 protocol works like this:
- Pixel values are clocked out into a shift register.
- OE (active-low) is pulled high.
- Shift register is latched.
- OE is pulled low.

To simplify the case statement, we can assume OE is already pulled high at the beginnging, and instead pull it high at the end.
*/

reg [7:0] state;
reg [4:0] line;

assign H75_A = line[0];
assign H75_B = line[1];
assign H75_C = line[2];
assign H75_D = line[3];
assign H75_E = line[4];

always @(posedge clk) begin
    if (pixel_clk) begin
        casex (state)
            8'b0xxx_xxx0: begin
                // Set clock high.
                H75_Clk <= 1'b1;
            end
            8'b0xxx_xxx1: begin
                // Set clock low.
                H75_Clk <= 1'b0;
                H75_R1 <= color[0];
                H75_R2 <= color[0];
                H75_G1 <= color[1];
                H75_G2 <= color[1];
                H75_B1 <= color[2];
                H75_B2 <= color[2];
            end
            8'b1000_0000: begin
                // Latch high.
                H75_Lat <= 1'b0;
            end
            8'b1000_0001: begin
                // Latch low.
                H75_Lat <= 1'b0;
                // Update line.
                line <= line + 1'b1;
            end
            8'b1000_0010: begin
                // Pull Output Enable low.
                H75_OE <= 1'b1;
            end
            8'b1111_1111: begin
                // Pull Output Enable high.
                H75_OE <= 1'b0;
            end
        endcase
        state <= state + 1'b1;
    end
end

endmodule
