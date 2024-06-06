/*
Three rings with additive blending.

A LUT ROM of 3 rings: red, green and blue, with their intersections adding up in color.
*/

module three_rings (
    input [4:0] line,
    input [5:0] column,
    output r1,
    output r2,
    output g1,
    output g2,
    output b1,
    output b2,
);

// Hex char bit order inverse ref:
// 0 0   4 2   8 1   c 3
// 1 8   5 a   9 9   d b
// 2 4   6 6   a 5   e 7
// 3 c   7 e   b d   f f

// R1
wire [0:63] r1_inner;
always @* begin
    case (line)
        5'h00: r1_inner = 64'h000007ffffe00000;
        5'h01: r1_inner = 64'h0000007ffe000000;
        5'h02: r1_inner = 64'h00001ffffff80000;
        5'h03: r1_inner = 64'h00007ff81ffe0000;
        5'h04: r1_inner = 64'h0001ff0000ff8000;
        5'h05: r1_inner = 64'h0007f800001fe000;
        5'h06: r1_inner = 64'h000fe0000007f000;
        5'h07: r1_inner = 64'h001f80000001f800;
        5'h08: r1_inner = 64'h003f00000000fc00;
        5'h09: r1_inner = 64'h007c000000003e00;
        5'h0a: r1_inner = 64'h00f8000000001f00;
        5'h0b: r1_inner = 64'h01f0000000000f80;
        5'h0c: r1_inner = 64'h03e00000000007c0;
        5'h0d: r1_inner = 64'h07c00000000003e0;
        5'h0e: r1_inner = 64'h07800000000001e0;
        5'h0f: r1_inner = 64'h0f800000000001f0;
        5'h10: r1_inner = 64'h0f000000000000f0;
        5'h11: r1_inner = 64'h1e00000000000078;
        5'h12: r1_inner = 64'h1e00000000000078;
        5'h13: r1_inner = 64'h3c0000000000003c;
        5'h14: r1_inner = 64'h3c0000000000003c;
        5'h15: r1_inner = 64'h780000000000001e;
        5'h16: r1_inner = 64'h780000000000001e;
        5'h17: r1_inner = 64'h780000000000001e;
        5'h18: r1_inner = 64'h700000000000000e;
        5'h19: r1_inner = 64'hf00000000000000f;
        5'h1a: r1_inner = 64'hf00000000000000f;
        5'h1b: r1_inner = 64'hf00000000000000f;
        5'h1c: r1_inner = 64'hf00000000000000f;
        5'h1d: r1_inner = 64'he000000000000007;
        5'h1e: r1_inner = 64'he000000000000007;
        5'h1f: r1_inner = 64'he000000000000007;
    endcase
    r1 = r1_inner[column];
end

// R2
wire [0:63] r2_inner;
always @* begin
    case (line)
        5'h00: r2_inner = 64'he000000000000007;
        5'h01: r2_inner = 64'he000000000000007;
        5'h02: r2_inner = 64'he000000000000007;
        5'h03: r2_inner = 64'hf00000000000000f;
        5'h04: r2_inner = 64'hf00000000000000f;
        5'h05: r2_inner = 64'hf00000000000000f;
        5'h06: r2_inner = 64'hf00000000000000f;
        5'h07: r2_inner = 64'h700000000000000e;
        5'h08: r2_inner = 64'h780000000000001e;
        5'h09: r2_inner = 64'h780000000000001e;
        5'h0a: r2_inner = 64'h780000000000001e;
        5'h0b: r2_inner = 64'h3c0000000000003c;
        5'h0c: r2_inner = 64'h3c0000000000003c;
        5'h0d: r2_inner = 64'h1e00000000000078;
        5'h0e: r2_inner = 64'h1e00000000000078;
        5'h0f: r2_inner = 64'h0f000000000000f0;
        5'h10: r2_inner = 64'h0f800000000001f0;
        5'h11: r2_inner = 64'h07800000000001e0;
        5'h12: r2_inner = 64'h07c00000000003e0;
        5'h13: r2_inner = 64'h03e00000000007c0;
        5'h14: r2_inner = 64'h01f0000000000f80;
        5'h15: r2_inner = 64'h00f8000000001f00;
        5'h16: r2_inner = 64'h007c000000003e00;
        5'h17: r2_inner = 64'h003f00000000fc00;
        5'h18: r2_inner = 64'h001f80000001f800;
        5'h19: r2_inner = 64'h000fe0000007f000;
        5'h1a: r2_inner = 64'h0007f800001fe000;
        5'h1b: r2_inner = 64'h0001ff0000ff8000;
        5'h1c: r2_inner = 64'h00007ff81ffe0000;
        5'h1d: r2_inner = 64'h00001ffffff80000;
        5'h1e: r2_inner = 64'h000007ffffe00000;
        5'h1f: r2_inner = 64'h0000007ffe000000;
    endcase
    r2 = r2_inner[column];
end

// G1
wire [0:63] g1_inner;
always @* begin
    case (line)
        5'h00: g1_inner = 64'h0000001ff8000000;
        5'h01: g1_inner = 64'h0000007ffe000000;
        5'h02: g1_inner = 64'h000001ffff800000;
        5'h03: g1_inner = 64'h000003fc3fc00000;
        5'h04: g1_inner = 64'h000007e007e00000;
        5'h05: g1_inner = 64'h00000f8001f00000;
        5'h06: g1_inner = 64'h00001f0000f80000;
        5'h07: g1_inner = 64'h00001e0000780000;
        5'h08: g1_inner = 64'h00003c00003c0000;
        5'h09: g1_inner = 64'h00003c00003c0000;
        5'h0a: g1_inner = 64'h00007800001e0000;
        5'h0b: g1_inner = 64'h00007800001e0000;
        5'h0c: g1_inner = 64'h00007800001e0000;
        5'h0d: g1_inner = 64'h00007000000e0000;
        5'h0e: g1_inner = 64'h00007000000e0000;
        5'h0f: g1_inner = 64'h00007000000e0000;
        5'h10: g1_inner = 64'h00007000000e0000;
        5'h11: g1_inner = 64'h00007800001e0000;
        5'h12: g1_inner = 64'h00007800001e0000;
        5'h13: g1_inner = 64'h00007800001e0000;
        5'h14: g1_inner = 64'h00003c00003c0000;
        5'h15: g1_inner = 64'h00003c00003c0000;
        5'h16: g1_inner = 64'h00001e0000780000;
        5'h17: g1_inner = 64'h00001f0000f80000;
        5'h18: g1_inner = 64'h00000f8001f00000;
        5'h19: g1_inner = 64'h000007e007e00000;
        5'h1a: g1_inner = 64'h000003fc3fc00000;
        5'h1b: g1_inner = 64'h000001ffff800000;
        5'h1c: g1_inner = 64'h0000007ffe000000;
        5'h1d: g1_inner = 64'h0000001ff8000000;
        5'h1e: g1_inner = 64'h0000000000000000;
        5'h1f: g1_inner = 64'h0000000000000000;
    endcase
    g1 = g1_inner[column];
end

// G2, all black
assign g2 = 1'b0;

// B1
wire [0:63] b1_inner;
always @* begin
    case (line)
        5'h00: b1_inner = 64'h0000000001ffe000;
        5'h01: b1_inner = 64'h0000000007fff800;
        5'h02: b1_inner = 64'h000000001ffffe00;
        5'h03: b1_inner = 64'h000000007fc0ff80;
        5'h04: b1_inner = 64'h00000000fe001fc0;
        5'h05: b1_inner = 64'h00000001f8000730;
        5'h06: b1_inner = 64'h00000003f00003f0;
        5'h07: b1_inner = 64'h00000007c00000f8;
        5'h08: b1_inner = 64'h0000000780000078;
        5'h09: b1_inner = 64'h0000000f8000007c;
        5'h0a: b1_inner = 64'h0000000f0000003c;
        5'h0b: b1_inner = 64'h0000001e0000001e;
        5'h0c: b1_inner = 64'h0000001e0000001e;
        5'h0d: b1_inner = 64'h0000003c0000000f;
        5'h0e: b1_inner = 64'h0000003c0000000f;
        5'h0f: b1_inner = 64'h0000003c0000000f;
        5'h10: b1_inner = 64'h0000003800000007;
        5'h11: b1_inner = 64'h0000003800000007;
        5'h12: b1_inner = 64'h0000003800000007;
        5'h13: b1_inner = 64'h0000003800000007;
        5'h14: b1_inner = 64'h0000003800000007;
        5'h15: b1_inner = 64'h0000003800000007;
        5'h16: b1_inner = 64'h0000003c0000000f;
        5'h17: b1_inner = 64'h0000003c0000000f;
        5'h18: b1_inner = 64'h0000003c0000000f;
        5'h19: b1_inner = 64'h0000001e0000001e;
        5'h1a: b1_inner = 64'h0000001e0000001e;
        5'h1b: b1_inner = 64'h0000000f0000003c;
        5'h1c: b1_inner = 64'h0000000f8000007c;
        5'h1d: b1_inner = 64'h0000000780000078;
        5'h1e: b1_inner = 64'h00000007c00000f8;
        5'h1f: b1_inner = 64'h00000003f00003f0;
    endcase
    b1 = b1_inner[column];
end

// B2
wire [0:63] b2_inner;
always @* begin
    casex (line)
        5'b00000: b2_inner = 64'h00000001f8000730;
        5'b00001: b2_inner = 64'h00000000fe001fc0;
        5'b00010: b2_inner = 64'h000000007fc0ff80;
        5'b00011: b2_inner = 64'h000000001ffffe00;
        5'b00100: b2_inner = 64'h0000000007fff800;
        5'b00101: b2_inner = 64'h0000000001ffe000;
        5'b0011x: b2_inner = 64'h0000000000000000;
        5'b01xxx: b2_inner = 64'h0000000000000000;
        5'b1xxxx: b2_inner = 64'h0000000000000000;
    endcase
    b2 = b2_inner[column];
end

endmodule