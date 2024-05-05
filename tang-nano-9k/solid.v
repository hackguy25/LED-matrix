/*
Drive an LED matrix with a solid white color.
*/

`include "includes/prescaler.v"

module top (
    input clk,
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
    output reg H75_OE,
    output reg H75_Clk,
    output reg H75_Lat,
);

wire en;

// 1kHz clock is desired, so divide the 27MHz extrenal clock by 27000.
prescaler #(
    .NUM(27),
    .NUM_BITS(16),
)
psc (
    .clk(clk),
    .rst(1'b0),
    .enable(en),
);

// We want an all-white panel.
assign H75_R1 = 1'b1;
assign H75_R2 = 1'b1;
assign H75_G1 = 1'b1;
assign H75_G2 = 1'b1;
assign H75_B1 = 1'b1;
assign H75_B2 = 1'b1;

/*
The HUB75 protocol works like this:
- OE (active-low) is pulled high.
- Pixel values are clocked out into a shift register.
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
    if (en) begin
        casex (state)
            8'b0xxx_xxx0: begin
                // Set clock high.
                H75_Clk <= 1'b1;
            end
            8'b0xxx_xxx1: begin
                // Set clock low.
                H75_Clk <= 1'b0;
            end
            8'b1000_0000: begin
                // Pull Output Enable high.
                H75_OE <= 1'b1;
            end
            8'b1000_0001: begin
                // Latch high.
                H75_Lat <= 1'b0;
            end
            8'b1000_0010: begin
                // Latch low.
                H75_Lat <= 1'b0;
                // Update line.
                line <= line + 1'b1;
            end
            8'b1000_0011: begin
                // Pull Output Enable low.
                H75_OE <= 1'b0;
            end
        endcase
        state <= state + 1'b1;
    end
end

endmodule
