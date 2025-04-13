//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_floats_using_fsm (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output                         busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order using FSM.
    //
    // Requirements:
    // The solution must have latency equal to the three clock cycles.
    // The solution should use the inputs and outputs to the single "f_less_or_equal" module.
    // The solution should NOT create instances of any modules.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res1
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    typedef enum logic [2:0] {
        S_IDLE, 
        S_LOAD, 
        S_COMPARE1, 
        S_COMPARE2, 
        S_COMPARE3, 
        S_DONE
    } fsm_state_t;

    fsm_state_t current_state, next_state;

    always_ff @(posedge clk) begin
        if (rst)
            current_state <= S_IDLE;
        else
            current_state <= next_state;
    end

    logic fault1, fault2, fault3;

    always_comb begin
        next_state = current_state;

        case (current_state)
            S_IDLE:     
                if (valid_in)
                    next_state = S_LOAD;
            S_LOAD:     
                next_state = S_COMPARE1;
            S_COMPARE1: 
                next_state = S_COMPARE2;
            S_COMPARE2: 
                next_state = S_COMPARE3;
            S_COMPARE3: 
                next_state = S_DONE;
            S_DONE:     
                next_state = S_IDLE;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            valid_out <= 1'b0;
            fault1 <= 1'b0;
            fault2 <= 1'b0;
            fault3 <= 1'b0;
        end else begin
            case (current_state)
                S_LOAD: begin
                    sorted <= unsorted;
                end
                S_COMPARE1: begin
                    f_le_a <= sorted[0];
                    f_le_b <= sorted[1];

                    if (!f_le_res) begin
                        sorted[0] <= sorted[1];
                        sorted[1] <= sorted[0];
                    end

                    if (f_le_err)
                        fault1 <= 1'b1;
                end
                S_COMPARE2: begin
                    f_le_a <= sorted[1];
                    f_le_b <= sorted[2];

                    if (!f_le_res) begin
                        sorted[1] <= sorted[2];
                        sorted[2] <= sorted[1];
                    end

                    if (f_le_err)
                        fault2 <= 1'b1;
                end
                S_COMPARE3: begin
                    f_le_a <= sorted[0];
                    f_le_b <= sorted[1];

                    if (!f_le_res) begin
                        sorted[0] <= sorted[1];
                        sorted[1] <= sorted[0];
                    end

                    if (f_le_err)
                        fault3 <= 1'b1;
                end
                S_DONE: begin
                    if (f_le_err)
                        fault3 <= 1'b1;
                    valid_out <= 1'b1;
                end
            endcase
        end
    end

    assign err = fault1 | fault2 | fault3;
    assign busy = (current_state != S_IDLE) && (current_state != S_DONE);

endmodule
