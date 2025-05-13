module imul_tb;

parameter N = 24;

reg [N-1:0] a, b;
wire [2*N-1:0] out;

imul dut (.*);

initial begin
    $dumpfile("signals.vcd");
    $dumpvars;
end

// testbench related
function automatic [2*N-1:0] reference (
    input [N-1:0] a, b
);
    reference = a * b;
endfunction

integer total, correct;
integer TOTAL_CHECKS = 20;
logic [2*N-1:0] golden;

initial begin
    total = 0;
    correct = 0;

    for (int i = 0; i < TOTAL_CHECKS; i++) begin
        a = $random;
        b = $random;

        golden = reference(a, b);
        if (out != golden)
            $display("TEST FAILED: exp %0d got %0d", golden, out);
        else
            correct++;
        total++;
    end

    $display("Final score: %0d / %0d", correct, total);
end

endmodule;
