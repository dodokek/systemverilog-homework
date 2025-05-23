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

    logic isqrt_vld_a, isqrt_vld_b, isqrt_vld_c;
    logic [31:0] isqrt_a;
    logic [31:0] isqrt_b;
    logic [31:0] isqrt_c;

    isqrt dd_isqrt_a
    (
        .clk    (clk),
        .rst    (rst),
        .x_vld  (arg_vld),
        .x      (a),
        .y_vld  (isqrt_vld_a),
        .y      (isqrt_a)
    );

    isqrt dd_isqrt_b
    (
        .clk    (clk),
        .rst    (rst),
        .x_vld  (arg_vld),
        .x      (b),
        .y_vld  (isqrt_vld_b),
        .y      (isqrt_b)
    );
    
    isqrt dd_isqrt_c
    (
        .clk    (clk),
        .rst    (rst),
        .x_vld  (arg_vld),
        .x      (c),
        .y_vld  (isqrt_vld_c),
        .y      (isqrt_c)
    );

    assign res_vld = (isqrt_vld_a) ? 1'b1 : 1'b0;
    assign res     = (isqrt_vld_a) ? isqrt_a + isqrt_b + isqrt_c : res;


endmodule