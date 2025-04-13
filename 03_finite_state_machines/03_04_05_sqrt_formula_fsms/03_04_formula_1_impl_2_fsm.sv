//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_impl_2_fsm (
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface
    output logic        isqrt_1_x_vld,
    output logic [31:0] isqrt_1_x,
    input               isqrt_1_y_vld,
    input        [15:0] isqrt_1_y,

    output logic        isqrt_2_x_vld,
    output logic [31:0] isqrt_2_x,
    input               isqrt_2_y_vld,
    input        [15:0] isqrt_2_y
);

    // Task:
    // Implement a module that calculates the formula from the `formula_1_fn.svh` file
    // using two instances of the isqrt module in parallel.
    //
    // Design the FSM to calculate an answer and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    enum logic [2:0] {
        ST_IDLE,
        ST_SEND_AB,
        ST_WAIT_AB,
        ST_SEND_C,
        ST_WAIT_C,
        ST_DONE
    } 
    cur_state, nxt_state;

    logic [31:0] reg_a, reg_b, reg_c;
    logic [15:0] sqrt_a, sqrt_b, sqrt_c;

    always_comb begin
        nxt_state = cur_state;

        res_vld = 0;
        res = 0;
        isqrt_1_x_vld = 0;
        isqrt_2_x_vld = 0;
        isqrt_1_x = 0;
        isqrt_2_x = 0;

        case (cur_state)
            ST_IDLE:
                if (arg_vld)
                    nxt_state = ST_SEND_AB;

            ST_SEND_AB: begin
                isqrt_1_x_vld = 1;
                isqrt_1_x     = reg_a;
                isqrt_2_x_vld = 1;
                isqrt_2_x     = reg_b;
                nxt_state     = ST_WAIT_AB;
            end

            ST_WAIT_AB:
                if (isqrt_1_y_vld && isqrt_2_y_vld)
                    nxt_state = ST_SEND_C;

            ST_SEND_C: begin
                isqrt_1_x_vld = 1;
                isqrt_1_x     = reg_c;
                nxt_state     = ST_WAIT_C;
            end

            ST_WAIT_C:
                if (isqrt_1_y_vld)
                    nxt_state = ST_DONE;

            ST_DONE: begin
                res_vld = 1;
                res     = sqrt_a + sqrt_b + sqrt_c;
                nxt_state = ST_IDLE;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst)
            cur_state <= ST_IDLE;
        else
            cur_state <= nxt_state;

        if (arg_vld && cur_state == ST_IDLE) begin
            reg_a <= a;
            reg_b <= b;
            reg_c <= c;
        end

        if (cur_state == ST_WAIT_AB) begin
            if (isqrt_1_y_vld)
                sqrt_a <= isqrt_1_y;
            if (isqrt_2_y_vld)
                sqrt_b <= isqrt_2_y;
        end

        if (cur_state == ST_WAIT_C && isqrt_1_y_vld)
            sqrt_c <= isqrt_1_y;
    end

endmodule
