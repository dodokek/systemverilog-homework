//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4ac == b*b - 4*a*c
    //
    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    real a_real, b_real, c_real, result;

    function logic is_nan(input real x);
        return x != x;
    endfunction

    function logic is_inf(input real x);
        return x == 1.0/0.0 || x == -1.0/0.0;
    endfunction

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            res_vld       <= 0;
            err           <= 0;
            res           <= 0;
            res_negative  <= 0;
            busy          <= 0;
        end else begin
            if (arg_vld) begin
                busy <= 1;

                a_real = $bitstoreal(a);
                b_real = $bitstoreal(b);
                c_real = $bitstoreal(c);

                err <= is_nan(a_real) || is_nan(b_real) || is_nan(c_real) ||
                       is_inf(a_real) || is_inf(b_real) || is_inf(c_real);

                // Discriminant calculations.
                result = b_real * b_real - 4.0 * a_real * c_real;
                res <= $realtobits(result);

                res_negative <= (result < 0.0);
                res_vld <= 1;

                busy <= 0;
            end else begin
                res_vld <= 0;
            end
        end
    end

endmodule