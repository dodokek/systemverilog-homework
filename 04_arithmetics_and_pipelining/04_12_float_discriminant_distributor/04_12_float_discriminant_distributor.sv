module float_discriminant_distributor (
    input                           clk,
    input                           rst,

    input                           arg_vld,
    input        [FLEN - 1:0]       a,
    input        [FLEN - 1:0]       b,
    input        [FLEN - 1:0]       c,

    output logic                    res_vld,
    output logic [FLEN - 1:0]       res,
    output logic                    res_negative,
    output logic                    err,

    output logic                    busy
);

    // Task:
    //
    // Implement a module that will calculate the discriminant based
    // on the triplet of input number a, b, c. The module must be pipelined.
    // It should be able to accept a new triple of arguments on each clock cycle
    // and also, after some time, provide the result on each clock cycle.
    // The idea of the task is similar to the task 04_11. The main difference is
    // in the underlying module 03_08 instead of formula modules.
    //
    // Note 1:
    // Reuse your file "03_08_float_discriminant.sv" from the Homework 03.
    //
    // Note 2:
    // Latency of the module "float_discriminant" should be clarified from the waveform.

    logic [FLEN-1:0] reg_a [0:4];
    logic [FLEN-1:0] reg_b [0:4];
    logic [FLEN-1:0] reg_c [0:4];
    logic            pipe_valid [0:4];

    logic result_ready;
    logic [FLEN-1:0] result_data;
    logic result_sign;
    logic is_busy;
    logic has_error;

    float_discriminant discr_core (
        .clk(clk),
        .rst(rst),
        .arg_vld(arg_vld),
        .a(a),
        .b(b),
        .c(c),
        .res_vld(result_ready),
        .res(result_data),
        .res_negative(result_sign),
        .err(has_error),
        .busy(is_busy)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int j = 0; j < 4; j++) begin
                reg_a[j]      <= '0;
                reg_b[j]      <= '0;
                reg_c[j]      <= '0;
                pipe_valid[j] <= 1'b0;
            end
        end else begin
            for (int j = 3; j > 0; j--) begin
                reg_a[j]      <= reg_a[j-1];
                reg_b[j]      <= reg_b[j-1];
                reg_c[j]      <= reg_c[j-1];
                pipe_valid[j] <= pipe_valid[j-1];
            end

            reg_a[0]      <= a;
            reg_b[0]      <= b;
            reg_c[0]      <= c;
            pipe_valid[0] <= arg_vld;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            res_vld      <= 1'b0;
            res          <= '0;
            res_negative <= 1'b0;
            err          <= 1'b0;
            busy         <= 1'b0;
        end else begin
            res_vld      <= result_ready;
            res          <= result_data;
            res_negative <= result_sign;
            err          <= has_error;
            busy         <= is_busy || (pipe_valid[0] && !result_ready);
        end
    end

endmodule
