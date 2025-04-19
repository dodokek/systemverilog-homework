//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe
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
    // Implement a pipelined module formula_2_pipe that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
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

    logic [31:0] reg_sqrt_c, reg_sqrt_bc, reg_sqrt_abc;
    logic        vld_sqrt_c, vld_sqrt_bc, vld_sqrt_abc;

    isqrt #(.n_pipe_stages(4)) inst_sqrt_c (
        .clk(clk),
        .rst(rst),
        .x_vld(arg_vld),
        .x(c),
        .y_vld(vld_sqrt_c),
        .y(reg_sqrt_c)
    );

    logic [31:0] reg_sum_bc;
    logic        vld_sum_bc;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_sum_bc <= '0;
            vld_sum_bc <= 1'b0;
        end else begin
            vld_sum_bc <= vld_sqrt_c;
            if (vld_sqrt_c) begin
                reg_sum_bc <= b + reg_sqrt_c;
            end
        end
    end

    isqrt #(.n_pipe_stages(4)) inst_sqrt_bc (
        .clk(clk),
        .rst(rst),
        .x_vld(vld_sum_bc),
        .x(reg_sum_bc),
        .y_vld(vld_sqrt_bc),
        .y(reg_sqrt_bc)
    );

    logic [31:0] reg_sum_abc;
    logic        vld_sum_abc;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_sum_abc <= '0;
            vld_sum_abc <= 1'b0;
        end else begin
            vld_sum_abc <= vld_sqrt_bc;
            if (vld_sqrt_bc) begin
                reg_sum_abc <= a + reg_sqrt_bc;
            end
        end
    end

    isqrt #(.n_pipe_stages(4)) inst_sqrt_abc (
        .clk(clk),
        .rst(rst),
        .x_vld(vld_sum_abc),
        .x(reg_sum_abc),
        .y_vld(vld_sqrt_abc),
        .y(reg_sqrt_abc)
    );

    logic [31:0] reg_result;
    logic        vld_result;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_result <= '0;
            vld_result <= 1'b0;
        end else begin
            reg_result <= reg_sqrt_abc;
            vld_result <= vld_sqrt_abc;
        end
    end

    assign res     = reg_result;
    assign res_vld = vld_result;

endmodule
