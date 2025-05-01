module finvsqr(
    in, out
);

   input wire [31:0] in;
   output wire [31:0] out;

   assign in_int = in;
   assign in_double = in * 2;


endmodule
