/*
Clock prescaler.

Generates a positive pulse every NUM clock cycles.
Make sure NUM parameter can be stored in NUM_BITS bits.
The counter can be reset by setting "rst" high.
*/

module prescaler
    #(
        parameter NUM = 2,
        parameter NUM_BITS = 1,
    )
    (
        input clk,
        input rst,
        output reg enable,
    );

    reg [NUM_BITS-1:0] cnt;
    wire [NUM_BITS-1:0] cnt_next;

    assign cnt_next = cnt + 1'd1;

    always @(posedge clk) begin
        if ((cnt == NUM) | rst) begin
            enable <= 1'b1;
            cnt <= NUM_BITS'h0;
        end
        else begin
            enable <= 1'b0;
            cnt <= cnt_next;
        end
    end

endmodule
