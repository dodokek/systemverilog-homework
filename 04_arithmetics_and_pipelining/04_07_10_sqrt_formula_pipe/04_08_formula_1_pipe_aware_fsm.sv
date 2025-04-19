//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
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

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);

    // Task:
    //
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    //
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    //
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    //
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    //
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    //
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    //
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    typedef enum logic [1:0] {
        ST_IDLE,
        ST_A,
        ST_B,
        ST_C
    } fsm_t;

    fsm_t st_cur, st_nxt;

    logic [15:0] val_a, val_b, val_c;
    logic        val_a_ok, val_b_ok, val_c_ok;

    logic [31:0] ab_sum, abc_sum;
    logic        ab_ok, abc_ok;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            st_cur <= ST_IDLE;
        end else begin
            st_cur <= st_nxt;
        end
    end

    always_comb begin
        st_nxt = st_cur;
        isqrt_x_vld = 1'b0;
        isqrt_x = '0;

        case (st_cur)
            ST_IDLE: begin
                if (arg_vld) begin
                    st_nxt = ST_A;
                    isqrt_x_vld = 1'b1;
                    isqrt_x = a;
                end
            end

            ST_A: begin
                isqrt_x_vld = 1'b1;
                isqrt_x = b;
                st_nxt = ST_B;
            end

            ST_B: begin
                isqrt_x_vld = 1'b1;
                isqrt_x = c;
                st_nxt = ST_C;
            end

            ST_C: begin
                if (arg_vld) begin
                    st_nxt = ST_A;
                    isqrt_x_vld = 1'b1;
                    isqrt_x = a;
                end else begin
                    st_nxt = ST_IDLE;
                end
            end
        endcase
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            val_a <= '0;
            val_b <= '0;
            val_c <= '0;
            val_a_ok <= 1'b0;
            val_b_ok <= 1'b0;
            val_c_ok <= 1'b0;
        end else begin
            if (isqrt_y_vld) begin
                case (st_cur)
                    ST_A: begin
                        val_a <= isqrt_y;
                        val_a_ok <= 1'b1;
                    end
                    ST_B: begin
                        val_b <= isqrt_y;
                        val_b_ok <= 1'b1;
                    end
                    ST_C: begin
                        val_c <= isqrt_y;
                        val_c_ok <= 1'b1;
                    end
                    default: begin
                        val_a_ok <= 1'b0;
                        val_b_ok <= 1'b0;
                        val_c_ok <= 1'b0;
                    end
                endcase
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ab_sum <= '0;
            abc_sum <= '0;
            ab_ok <= 1'b0;
            abc_ok <= 1'b0;
            res <= '0;
            res_vld <= 1'b0;
        end else begin
            ab_ok <= 1'b0;
            abc_ok <= 1'b0;

            if (val_a_ok && val_b_ok) begin
                ab_sum <= val_a + val_b;
                ab_ok <= 1'b1;
            end

            if (ab_ok && val_c_ok) begin
                abc_sum <= ab_sum + val_c;
                abc_ok <= 1'b1;
            end

            res <= abc_sum;
            res_vld <= abc_ok;
        end
    end

endmodule
