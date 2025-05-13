module imul #(parameter N=32) (
    input  signed [N-1:0] a,
    input  signed [N-1:0] b,
    output signed [2*N-1:0] out
);

logic [N:0] acc;

assign acc = {b, 1'b0};

endmodule

