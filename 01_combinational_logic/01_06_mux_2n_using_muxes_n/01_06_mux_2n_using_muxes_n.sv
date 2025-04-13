//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux_2_1
(
  input  [3:0] d0, d1,
  input        sel,
  output [3:0] y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module mux_4_1
(
  input  [3:0] d0, d1, d2, d3,
  input  [1:0] sel,
  output [3:0] y
);
  logic [3:0] res [1:0];
  // Task:
  // Implement mux_4_1 using three instances of mux_2_1
  mux_2_1 inst1(
    .d0(d0),
    .d1(d1),
    .sel(sel[0]),
    .y(res[0])
  );

  mux_2_1 inst2(
    .d0(d2),
    .d1(d3),
    .sel(sel[0]),
    .y(res[1])
  );

  mux_2_1 inst3(
    .d0(res[0]),
    .d1(res[1]),
    .sel(sel[1]),
    .y(y)
  );



endmodule
