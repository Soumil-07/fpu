module fmul (
   a, b, out
);
    input wire [31:0] a;
    input wire [31:0] b;
    output wire [31:0] out;

    wire [23:0] mant_a, mant_b;
    wire [7:0] exp_a, exp_b;
    wire sgn_a, sgn_b;

    assign mant_a   = {1'b1, a[22:0]};
    assign mant_b   = {1'b1, b[22:0]};
    assign exp_a    = a[30:23];
    assign exp_b    = b[30:23];
    assign sgn_a    = a[31];
    assign sgn_b    = b[31];

    (* DONT_TOUCH = "yes" *) wire [47:0] mant_mul;
    (* DONT_TOUCH = "yes" *) wire [7:0]  exp_res;
    wire        sgn_out;

    // assign mant_mul = mant_a * mant_b;
    imul imul_inst (
        .a(mant_a),
        .b(mant_b),
        .out(mant_mul)
    );
    assign exp_res  = exp_a + exp_b - 9'd127;
    assign sgn_out  = sgn_a ^ sgn_b;

    reg [7:0]  exp_adj;
    (* DONT_TOUCH = "yes" *) reg [23:0] mant_out;

    wire is_zero_a, is_zero_b, is_inf_a, is_inf_b, is_nan_a, is_nan_b;

    assign is_zero_a = (a[30:0] == 31'd0);
    assign is_zero_b = (b[30:0] == 31'd0);
    assign is_inf_a = (a[30:23] == 8'hFF) && (a[22:0] == 0);
    assign is_inf_b = (b[30:23] == 8'hFF) && (b[22:0] == 0);
    assign is_nan_a = (a[30:23] == 8'hFF) && (a[22:0] != 0);
    assign is_nan_b = (b[30:23] == 8'hFF) && (b[22:0] != 0);

    reg [31:0] special_result;
    reg special_case;

    always @(*) begin
        // handle special case FPs
        special_case = 1'b1;

        if (is_nan_a || is_nan_b) begin
            special_result = 32'h7FC00000; // QNaN
        end else if (is_inf_a && is_zero_b || is_inf_b && is_zero_a) begin
            special_result = 32'h7FC00000; // ∞ * 0 = NaN
        end else if (is_inf_a || is_inf_b) begin
            special_result = {sgn_a ^ sgn_b, 8'hFF, 23'd0}; // result is signed ∞
        end else if (is_zero_a || is_zero_b) begin
            special_result = {sgn_a ^ sgn_b, 31'd0}; // result is signed 0
        end else begin
            special_case = 1'b0; // not special
            special_result = 32'd0;
        end
    end


    always @(*) begin
        if (mant_mul[47]) begin
           mant_out = mant_mul[46:24];
           exp_adj  = exp_res + 1;
        end else begin
            mant_out = mant_mul[45:23];
            exp_adj = exp_res;
        end
    end

    assign out = special_case ? special_result : {sgn_out, exp_adj, mant_out[22:0]};

endmodule
