module fmul_clk (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] a,
    input  wire [31:0] b,
    output reg  [31:0] out
);

    reg [31:0] a_q, b_q;
    wire [31:0] out_q;

    // First register the inputs
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_q <= 32'd0;
            b_q <= 32'd0;
        end else begin
            a_q <= a;
            b_q <= b;
        end
    end

    // Then combinationally compute the result
    fmul fmul_inst (
        .a(a_q),
        .b(b_q),
        .out(out_q)
    );

    // Then register the output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 32'd0;
        end else begin
            out <= out_q;
        end
    end

endmodule
