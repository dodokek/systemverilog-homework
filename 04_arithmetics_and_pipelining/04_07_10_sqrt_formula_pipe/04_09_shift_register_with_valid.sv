//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module one_bit_wide_shift_register_with_reset
# (
    parameter depth = 8
)
(
    input  clk,
    input  rst,
    input  in_data,
    output out_data
);
    logic [depth - 1:0] data;

    always_ff @ (posedge clk)
        if (rst)
            data <= '0;
        else
            data <= { data [depth - 2:0], in_data };

    assign out_data = data [depth - 1];

endmodule

//----------------------------------------------------------------------------

module shift_register
# (
    parameter width = 8, depth = 8
)
(
    input                clk,
    input  [width - 1:0] in_data,
    output [width - 1:0] out_data
);
    logic [width - 1:0] data [0:depth - 1];

    always_ff @ (posedge clk)
    begin
        data [0] <= in_data;

        for (int i = 1; i < depth; i ++)
            data [i] <= data [i - 1];
    end

    assign out_data = data [depth - 1];

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module shift_register_with_valid
# (
    parameter width = 8, depth = 8
)
(
    input                clk,
    input                rst,

    input                in_vld,
    input  [width - 1:0] in_data,

    output               out_vld,
    output [width - 1:0] out_data
);

    // Task:
    //
    // Implement a variant of a shift register module
    // that moves a transfer of data only if this transfer is valid.
    //
    // For the discussion of shift registers
    // see the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    logic [width - 1:0] reg_data [0:depth-1];
    logic               reg_valid [0:depth-1];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int idx = 0; idx < depth; idx++) begin
                reg_data[idx] <= '0;
                reg_valid[idx] <= 1'b0;
            end
        end else begin
            if (in_vld) begin
                for (int idx = depth-1; idx > 0; idx--) begin
                    reg_data[idx] <= reg_data[idx - 1];
                    reg_valid[idx] <= reg_valid[idx - 1];
                end
                reg_data[0] <= in_data;
                reg_valid[0] <= 1'b1;
            end else begin
                reg_valid[0] <= 1'b0;
            end
        end
    end

    assign out_data = reg_data[depth - 1];
    assign out_vld  = reg_valid[depth - 1];

endmodule
