//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module serial_divisibility_by_3_using_fsm
(
  input  clk,
  input  rst,
  input  new_bit,
  output div_by_3
);

  // States
  enum logic[1:0]
  {
     mod_0 = 2'b00,
     mod_1 = 2'b01,
     mod_2 = 2'b10
  }
  state, new_state;

  // State transition logic
  always_comb
  begin
    new_state = state;

    // This lint warning is bogus because we assign the default value above
    // verilator lint_off CASEINCOMPLETE

    case (state)
      mod_0 : if(new_bit) new_state = mod_1;
              else        new_state = mod_0;
      mod_1 : if(new_bit) new_state = mod_0;
              else        new_state = mod_2;
      mod_2 : if(new_bit) new_state = mod_2;
              else        new_state = mod_1;
    endcase

    // verilator lint_on CASEINCOMPLETE

  end

  // Output logic
  assign div_by_3 = state == mod_0;

  // State update
  always_ff @ (posedge clk)
    if (rst)
      state <= mod_0;
    else
      state <= new_state;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_divisibility_by_5_using_fsm
(
    input  clk,
    input  rst,
    input  new_bit,
    output logic div_by_5
);

    typedef enum logic[2:0]
    {
        ST_MOD_0 = 3'b000,
        ST_MOD_1 = 3'b001,
        ST_MOD_2 = 3'b010,
        ST_MOD_3 = 3'b011,
        ST_MOD_4 = 3'b100
    } state_t;

    state_t cur_state, next_state;

    // State transition logic
    always_comb begin
        case (cur_state)
            ST_MOD_0: begin
                if (new_bit)
                    next_state = ST_MOD_1;
                else
                    next_state = ST_MOD_0;
            end

            ST_MOD_1: begin
                if (new_bit)
                    next_state = ST_MOD_3;
                else
                    next_state = ST_MOD_2;
            end

            ST_MOD_2: begin
                if (new_bit)
                    next_state = ST_MOD_0;
                else
                    next_state = ST_MOD_4;
            end

            ST_MOD_3: begin
                if (new_bit)
                    next_state = ST_MOD_2;
                else
                    next_state = ST_MOD_1;
            end

            ST_MOD_4: begin
                if (new_bit)
                    next_state = ST_MOD_4;
                else
                    next_state = ST_MOD_3;
            end

            default: next_state = ST_MOD_0;
        endcase
    end

    // Output logic
    assign div_by_5 = (cur_state == ST_MOD_0);

    // State update
    always_ff @(posedge clk) begin
        if (rst)
            cur_state <= ST_MOD_0;
        else
            cur_state <= next_state;
    end

endmodule
