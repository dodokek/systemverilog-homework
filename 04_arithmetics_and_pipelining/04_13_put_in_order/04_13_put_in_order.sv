module put_in_order #(
    parameter width    = 16,
    parameter n_inputs = 4
) (
    input                        clk,
    input                        rst,
    input  [n_inputs-1:0]        up_vlds,
    input  [n_inputs-1:0][width-1:0] up_data,
    output                       down_vld,
    output [width-1:0]           down_data
);

    // Task:
    //
    // Implement a module that accepts many outputs of the computational blocks
    // and outputs them one by one in order. Input signals "up_vlds" and "up_data"
    // are coming from an array of non-pipelined computational blocks.
    // These external computational blocks have a variable latency.
    //
    // The order of incoming "up_vlds" is not determent, and the task is to
    // output "down_vld" and corresponding data in a round-robin manner,
    // one after another, in order.
    //
    // Comment:
    // The idea of the block is kinda similar to the "parallel_to_serial" block
    // from Homework 2, but here block should also preserve the output order.

    typedef logic [$clog2(n_inputs)-1:0] chan_t;

    chan_t  index_now, index_next, index_try;
    logic   hit;
    logic   is_valid;
    logic [n_inputs-1:0] wait_mask, wait_mask_next;
    logic [width-1:0] data_buf;

    always_comb begin
        index_next = index_now;
        hit = 0;

        for (int offset = 1; offset < n_inputs; offset++) begin
            index_try = (index_now + offset) % n_inputs;
            if (wait_mask[index_try] && !hit) begin
                index_next = index_try;
                hit = 1;
            end
        end
    end

    always_comb begin
        wait_mask_next = up_vlds | wait_mask;
        if (down_vld) begin
            wait_mask_next[index_now] = 0;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            index_now   <= 0;
            wait_mask   <= 0;
            data_buf    <= 0;
            is_valid    <= 0;
        end else begin
            wait_mask <= wait_mask_next;

            if (!is_valid || down_vld) begin
                if (|wait_mask) begin
                    index_now <= index_next;
                    data_buf  <= up_data[index_next];
                    is_valid  <= 1;
                end else begin
                    is_valid <= 0;
                end
            end
        end
    end

    assign down_vld  = is_valid;
    assign down_data = is_valid ? data_buf : '0;

endmodule
