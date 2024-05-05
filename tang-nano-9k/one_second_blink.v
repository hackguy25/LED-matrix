/*
Make all LEDs toggle state once per second.
*/

`include "includes/prescaler.v"

module top (
    input clk,
	input S2,
	output [5:0] led,
);

// Wire upp all LEDS to one wire.
reg led_all;
assign led = {6{led_all}};

wire en;

// Extrenal clock is set to 27MHz.
// Buttons are active-low, so invert the signal to reset the prescaler.
prescaler #(
    .NUM(27000000),
    .NUM_BITS(25),
)
psc (
    .clk(clk),
    .rst(!S2),
    .enable(en),
);

always @(posedge clk) begin
    if (en) begin
        led_all <= !led_all;
    end
end

endmodule
