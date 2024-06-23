/*
Main loop that drives the currently displayed pixel.

When variable `column` changes, new color should be provided.
*/

module LM_pixel_loop #(
    parameter SLICE_BITS = 1,
)(
    input clk,
    input clk_enable,
    output reg [4:0] line,
    output reg [4:0] next_line,
    output reg [5:0] next_column,
    output reg [SLICE_BITS:0] next_slice,
    output reg matrix_OE,
    output reg matrix_clk,
    output reg matrix_lat,
);

reg [7:0] state;

always @(posedge clk) begin
    if (clk_enable) begin
        casex (state)
            8'b0000_0000: begin
                // Do nothing.
                matrix_clk <= 1'b0;
            end
            8'b0xxx_xxx1: begin
                // Set clock high.
                matrix_clk <= 1'b1;
            end
            8'b0xxx_xxx0: begin
                // Set clock low.
                matrix_clk <= 1'b0;
                next_column <= state[6:1];
            end
            8'b1000_0000: begin
                // All pixels in line were clocked.
                // Update all variables.
                matrix_clk <= 1'b0;
                next_column <= 6'b000000;
                next_line <= line + 2;
                if (line == 5'b11110) next_slice <= next_slice + 1;
            end
            // -----
            8'b1111_1100: begin
                // Pull Output Enable high.
                matrix_OE <= 1'b1;
            end
            8'b1111_1101: begin
                // Latch high.
                matrix_lat <= 1'b1;
                // Update line.
                line <= line + 1;
            end
            8'b1111_1110: begin
                // Latch low.
                matrix_lat <= 1'b0;
            end
            8'b1111_1111: begin
                // Pull Output Enable low.
                matrix_OE <= 1'b0;
            end
        endcase
        state <= state + 1'b1;
    end
end

endmodule