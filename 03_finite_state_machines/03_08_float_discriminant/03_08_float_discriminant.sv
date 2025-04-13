// Compute the shit. Was pretty hard to be honest

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

    // FSM states for computation pipeline
    typedef enum logic [3:0] {
        S_IDLE,
        S_COMPUTE_B_SQR,
        S_WAIT_B_SQR,
        S_COMPUTE_AC,
        S_WAIT_AC,
        S_COMPUTE_4AC,
        S_WAIT_4AC,
        S_SUBTRACT,
        S_WAIT_SUB,
        S_FINISH
    } state_t;

    state_t current_state, next_state;

    // Intermediate signal registers
    logic [FLEN-1:0] b_squared, ac_value, four_ac_value;
    logic [FLEN-1:0] constant_four;
    logic [FLEN-1:0] mul_a, mul_b;
    logic [FLEN-1:0] sub_a, sub_b;

    logic            mul_up_valid, mul_down_valid, mul_busy, mul_err;
    logic [FLEN-1:0] mul_result;

    logic            sub_up_valid, sub_down_valid, sub_busy, sub_err;
    logic [FLEN-1:0] sub_result;

    assign constant_four = 64'h4010000000000000; // Represents constant 4.0 in IEEE 754

    // Floating-point multiplication unit
    f_mult mult_unit (
        .clk(clk),
        .rst(rst),
        .a(mul_a),
        .b(mul_b),
        .up_valid(mul_up_valid),
        .res(mul_result),
        .down_valid(mul_down_valid),
        .busy(mul_busy),
        .error(mul_err)
    );

    // Floating-point subtraction unit
    f_sub sub_unit (
        .clk(clk),
        .rst(rst),
        .a(sub_a),
        .b(sub_b),
        .up_valid(sub_up_valid),
        .res(sub_result),
        .down_valid(sub_down_valid),
        .busy(sub_busy),
        .error(sub_err)
    );

    // State machine state transition
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= S_IDLE;
        else
            current_state <= next_state;
    end

    // FSM control logic and state updates
    always_comb begin
        next_state = current_state;

        // Default signal states
        res_vld = 0;
        mul_up_valid = 0;
        sub_up_valid = 0;
        mul_a = '0;
        mul_b = '0;
        sub_a = '0;
        sub_b = '0;

        case (current_state)
            S_IDLE: begin
                if (arg_vld)
                    next_state = S_COMPUTE_B_SQR;
            end

            S_COMPUTE_B_SQR: begin
                mul_up_valid = 1;
                mul_a = b;
                mul_b = b;
                next_state = S_WAIT_B_SQR;
            end

            S_WAIT_B_SQR: begin
                if (mul_down_valid)
                    next_state = S_COMPUTE_AC;
            end

            S_COMPUTE_AC: begin
                mul_up_valid = 1;
                mul_a = a;
                mul_b = c;
                next_state = S_WAIT_AC;
            end

            S_WAIT_AC: begin
                if (mul_down_valid)
                    next_state = S_COMPUTE_4AC;
            end

            S_COMPUTE_4AC: begin
                mul_up_valid = 1;
                mul_a = constant_four;
                mul_b = ac_value;
                next_state = S_WAIT_4AC;
            end

            S_WAIT_4AC: begin
                if (mul_down_valid)
                    next_state = S_SUBTRACT;
            end

            S_SUBTRACT: begin
                sub_up_valid = 1;
                sub_a = b_squared;
                sub_b = four_ac_value;
                next_state = S_WAIT_SUB;
            end

            S_WAIT_SUB: begin
                if (sub_down_valid)
                    next_state = S_FINISH;
            end

            S_FINISH: begin
                res_vld = 1;
                next_state = S_IDLE;
            end
        endcase
    end

    // Register intermediate results
    always_ff @(posedge clk) begin
        if (current_state == S_WAIT_B_SQR && mul_down_valid)
            b_squared <= mul_result;

        if (current_state == S_WAIT_AC && mul_down_valid)
            ac_value <= mul_result;

        if (current_state == S_WAIT_4AC && mul_down_valid)
            four_ac_value <= mul_result;

        if (current_state == S_WAIT_SUB && sub_down_valid)
            res <= sub_result;
    end

    // Output and status flags
    always_comb begin
        busy         = (current_state != S_IDLE && current_state != S_FINISH);
        err          = mul_err | sub_err;
        res_negative = res[FLEN-1];
    end

endmodule
