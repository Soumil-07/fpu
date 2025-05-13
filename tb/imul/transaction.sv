class transaction;

rand bit [15:0] a;
rand bit [15:0] b;
bit [15:0] out;

function void print(string tag="");
    $display("T=%0t [%s] a=%0d b=%0d out=%0d",
        $time, tag, a, b, out);
endfunction

endclass
