`timescale 1ns / 1ps
`include "rtl/fmul.v"

module tb_fmul;

    reg  [31:0] a, b;
    wire [31:0] out;

    // Instantiate the floating-point multiplier
    fmul uut (
        .a(a),
        .b(b),
        .out(out)
    );

    // Task to apply inputs and display results
    task run_test;
        input [31:0] a_in;
        input [31:0] b_in;
        input [31:0] expected;
        begin
            a = a_in;
            b = b_in;
            #10;
            $display("A      = 0x%h", a);
            $display("B      = 0x%h", b);
            $display("OUT    = 0x%h", out);
            $display("EXPECT = 0x%h", expected);
            $display("MATCH  = %s", (out === expected) ? "YES" : "NO");
            $display("-------------------------------");
        end
    endtask

    initial begin
        $display("Starting comprehensive FP32 multiplier tests...\n");

        // Normal Numbers
        run_test(32'h40000000, 32'h40400000, 32'h40C00000); // 2.0 * 3.0 = 6.0
        run_test(32'h3F800000, 32'h3F800000, 32'h3F800000); // 1.0 * 1.0 = 1.0
        run_test(32'hBF800000, 32'h3F800000, 32'hBF800000); // -1.0 * 1.0 = -1.0
        run_test(32'hBF800000, 32'hBF800000, 32'h3F800000); // -1.0 * -1.0 = 1.0

        // Zeros
        run_test(32'h00000000, 32'h3F800000, 32'h00000000); // 0 * 1 = 0
        run_test(32'h80000000, 32'h40000000, 32'h80000000); // -0 * 2 = -0

        // Infinities
        run_test(32'h7F800000, 32'h40000000, 32'h7F800000); // ∞ * 2 = ∞
        run_test(32'hFF800000, 32'h40000000, 32'hFF800000); // -∞ * 2 = -∞
        run_test(32'h40000000, 32'h7F800000, 32'h7F800000); // 2 * ∞ = ∞

        // NaNs
        run_test(32'h7FC00000, 32'h40000000, 32'h7FC00000); // NaN * 2 = NaN
        run_test(32'h7F800000, 32'h00000000, 32'h7FC00000); // ∞ * 0 = NaN
        run_test(32'h00000000, 32'hFF800000, 32'h7FC00000); // 0 * -∞ = NaN

        // Denormals (small values)
        run_test(32'h00000001, 32'h3F800000, 32'h00000001); // Denormal * 1 = Denormal

        $display("All tests completed.");
        $finish;
    end

endmodule
