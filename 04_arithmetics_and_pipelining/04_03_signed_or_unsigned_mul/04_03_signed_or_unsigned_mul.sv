//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

// A non-parameterized module
// that implements the signed multiplication of 4-bit numbers
// which produces 8-bit result

module signed_mul_4
(
  input  signed [3:0] a, b,
  output signed [7:0] res
);

  assign res = a * b;

endmodule

// A parameterized module
// that implements the unsigned multiplication of N-bit numbers
// which produces 2N-bit result

module unsigned_mul
# (
  parameter n = 8
)
(
  input  [    n - 1:0] a, b,
  output [2 * n - 1:0] res
);

  assign res = a * b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

// Task:
//
// Implement a parameterized module
// that produces either signed or unsigned result
// of the multiplication depending on the 'signed_mul' input bit.

module signed_or_unsigned_mul
# (
  parameter n = 8
)
(
  input  [    n - 1:0] a, b,
  input                signed_mul,
  output [2 * n - 1:0] res
);

  logic signed [n-1:0]   a_signed, b_signed;
  logic signed [2*n-1:0] res_signed;
  logic [2*n-1:0]        res_unsigned;
  logic [2*n-1:0]        res_saved;

  always_comb begin
    a_signed      = a;
    b_signed      = b;
    res_signed    = a_signed * b_signed;
    res_unsigned  = a * b;
    res_saved     = signed_mul ? res_signed : res_unsigned;
  end

  assign res = res_saved;

endmodule