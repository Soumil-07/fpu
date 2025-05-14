`timescale 1ns / 1ps

module tb_fmul;

    reg  clk;
    reg  rst;
    reg  [31:0] a;
    reg  [31:0] b;
    wire [31:0] out;

    // Instantiate the clocked fmul
    fmul uut (.*);

    initial begin
        $dumpfile("signals.vcd");
        $dumpvars;
    end

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock (period = 10ns)
    end

    // Task to apply inputs and display outputs after latency
    task run_test;
        input [31:0] a_in;
        input [31:0] b_in;
        input [31:0] expected;
        begin
            a <= a_in;
            b <= b_in;
            @(posedge clk); // first clock: register inputs (a_q, b_q)
            a <= 32'd0;      // optional: clear inputs to simulate new transaction
            b <= 32'd0;
            @(posedge clk); // second clock: fmul computes output (out_q computed)
            // @(posedge clk); // third clock: output is valid and registered
            $display("A      = 0x%h", a_in);
            $display("B      = 0x%h", b_in);
            $display("OUT    = 0x%h", out);
            $display("EXPECT = 0x%h", expected);
            $display("MATCH  = %s", (out === expected) ? "YES" : "NO");
            $display("-------------------------------");
        end
    endtask

    initial begin
        // Reset sequence
        rst = 0;
        a   = 0;
        b   = 0;
        #20;
        rst = 1;

        $display("Starting clocked FP32 multiplier tests...\n");

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
