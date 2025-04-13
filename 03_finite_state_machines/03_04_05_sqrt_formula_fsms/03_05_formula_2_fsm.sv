//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_fsm (
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface
    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,
    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);

    // Task:
    // Implement a module that calculates the formula from the `formula_2_fn.svh` file
    // using only one instance of the isqrt module.
    //
    // Design the FSM to calculate answer step-by-step and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    enum logic [2:0] {
        ST_IDLE,
        ST_SEND_C,
        ST_WAIT_C,
        ST_SEND_B,
        ST_WAIT_B,
        ST_SEND_A,
        ST_WAIT_A,
        ST_DONE
    } 
    cur_state, next_state;

    logic [31:0] reg_a, reg_b, reg_c;
    logic [31:0] sum_bc, sum_abc;

    always_comb begin
        next_state = cur_state;

        res_vld = 0;
        res = 0;
        isqrt_x_vld = 0;
        isqrt_x = 0;

        case (cur_state)
            ST_IDLE:
                if (arg_vld)
                    next_state = ST_SEND_C;

            ST_SEND_C: begin
                isqrt_x_vld = 1;
                isqrt_x     = reg_c;
                next_state  = ST_WAIT_C;
            end

            ST_WAIT_C:
                if (isqrt_y_vld)
                    next_state = ST_SEND_B;

            ST_SEND_B: begin
                isqrt_x_vld = 1;
                isqrt_x     = sum_bc;
                next_state  = ST_WAIT_B;
            end

            ST_WAIT_B:
                if (isqrt_y_vld)
                    next_state = ST_SEND_A;

            ST_SEND_A: begin
                isqrt_x_vld = 1;
                isqrt_x     = sum_abc;
                next_state  = ST_WAIT_A;
            end

            ST_WAIT_A:
                if (isqrt_y_vld)
                    next_state = ST_DONE;

            ST_DONE: begin
                res_vld    = 1;
                res        = isqrt_y;
                next_state = ST_IDLE;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst)
            cur_state <= ST_IDLE;
        else
            cur_state <= next_state;
    end

    always_ff @(posedge clk) begin
        if (cur_state == ST_IDLE && arg_vld) begin
            reg_a <= a;
            reg_b <= b;
            reg_c <= c;
        end

        if (cur_state == ST_WAIT_C && isqrt_y_vld)
            sum_bc <= reg_b + isqrt_y;

        if (cur_state == ST_WAIT_B && isqrt_y_vld)
            sum_abc <= reg_a + isqrt_y;
    end

endmodule