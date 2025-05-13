`include "rtl/imul_gen.v"

module imul (a, b, out);

input wire [23:0] a, b;
output wire [47:0] out;

multiplier multiplier_inst (
    .a(a),
    .b(b),
    .o(out)
);

endmodule
