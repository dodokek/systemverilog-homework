//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);

    // Task:
    //
    // Implement a pipelined module formula_1_pipe that computes the result
    // of the formula defined in the file formula_1_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_1_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    logic [31:0] sqrt_a, sqrt_b, sqrt_c;
    logic isqrt_vld_a, isqrt_vld_b, isqrt_vld_c;

    logic [31:0] res_stage_1, res_stage_2;
    logic res_vld_stage_1, res_vld_stage_2;

    isqrt #(.n_pipe_stages(4)) dd_isqrt_a
    (
        .clk(clk),
        .rst(rst),
        .x_vld(arg_vld),
        .x(a),
        .y_vld(isqrt_vld_a),
        .y(sqrt_a)
    );

    isqrt #(.n_pipe_stages(4)) dd_isqrt_b
    (
        .clk(clk),
        .rst(rst),
        .x_vld(arg_vld),
        .x(b),
        .y_vld(isqrt_vld_b),
        .y(sqrt_b)
    );

    isqrt #(.n_pipe_stages(4)) dd_isqrt_c
    (
        .clk(clk),
        .rst(rst),
        .x_vld(arg_vld),
        .x(c),
        .y_vld(isqrt_vld_c),
        .y(sqrt_c)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            res_stage_1 <= 32'b0;
            res_vld_stage_1 <= 1'b0;
        end else begin
            if (isqrt_vld_a && isqrt_vld_b && isqrt_vld_c) begin
                res_stage_1 <= sqrt_a + sqrt_b + sqrt_c;
                res_vld_stage_1 <= 1'b1;
            end else begin
                res_vld_stage_1 <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            res_stage_2 <= 32'b0;
            res_vld_stage_2 <= 1'b0;
        end else begin
            res_stage_2 <= res_stage_1;
            res_vld_stage_2 <= res_vld_stage_1;
        end
    end

    assign res = res_stage_2;
    assign res_vld = res_vld_stage_2;

endmodule
