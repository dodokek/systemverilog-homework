//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_impl_2_fsm
(
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
        S_IDLE     ,
        S_SEND_A   ,
        S_WAIT_A   ,
        S_SEND_BC  ,
        S_WAIT_BC  ,
        S_DONE
    } state, new_state;

    logic [31:0] reg_a, reg_b, reg_c;
    logic [15:0] sqrt_a, sqrt_b, sqrt_c;

    always_comb begin
        new_state = state;

        res_vld       = 0;
        res           = 0;
        isqrt_1_x_vld = 0;
        isqrt_1_x     = 0;
        isqrt_2_x_vld = 0;
        isqrt_2_x     = 0;

        case (state)
            S_IDLE: begin
                if (arg_vld)
                    new_state = S_SEND_A;
            end

            S_SEND_A: begin
                isqrt_1_x_vld = 1;
                isqrt_1_x     = reg_a;
                new_state     = S_WAIT_A;
            end

            S_WAIT_A: begin
                if (isqrt_1_y_vld)
                    new_state = S_SEND_BC;
            end

            S_SEND_BC: begin
                isqrt_1_x_vld = 1;
                isqrt_1_x     = reg_b;
                isqrt_2_x_vld = 1;
                isqrt_2_x     = reg_c;
                new_state     = S_WAIT_BC;
            end

            S_WAIT_BC: begin
                if (isqrt_1_y_vld && isqrt_2_y_vld)
                    new_state = S_DONE;
            end

            S_DONE: begin
                res_vld = 1;
                res     = sqrt_a + sqrt_b + sqrt_c;
                new_state = S_IDLE;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE;
        end else begin
            state <= new_state;
        end

        if (arg_vld && state == S_IDLE) begin
            reg_a <= a;
            reg_b <= b;
            reg_c <= c;
        end

        if (state == S_WAIT_A) begin
            if (isqrt_1_y_vld)
                sqrt_a <= isqrt_1_y;
        end

        if (state == S_WAIT_BC) begin
            if (isqrt_1_y_vld)
                sqrt_b <= isqrt_1_y;
            if (isqrt_2_y_vld)
                sqrt_c <= isqrt_2_y;
        end
    end

endmodule
