//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add
(
  input  [3:0] a, b,
  output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module signed_add_with_saturation
(
  input  [3:0] a, b,
  output [3:0] sum
);

  // Task:
  //
  // Implement a module that adds two signed numbers with saturation.
  //
  // "Adding with saturation" means:
  //
  // When the result does not fit into 4 bits,
  // and the arguments are positive,
  // the sum should be set to the maximum positive number.
  //
  // When the result does not fit into 4 bits,
  // and the arguments are negative,
  // the sum should be set to the minimum negative number.

  logic signed [3:0] signed_a, signed_b;
  logic signed [4:0] full_sum;

  assign signed_a = a;
  assign signed_b = b;
  assign full_sum = signed_a + signed_b;

  assign sum = (full_sum > 7) ? 4'sd7 : (full_sum < -8 ? -4'sd8 : full_sum[3:0]);

endmodule