// // Demonstrate Auto-Connect /*features*/

// Rising edge triggered D Flip Flop
//
module Dff (q, d, clk);
   
  parameter WIDTH = 1;

  input  [WIDTH-1:0] d;   // data in
  input              clk;
  output [WIDTH-1:0] q;   // data out

  reg  [WIDTH-1:0] q;
  
  always @(posedge clk)
      q[WIDTH-1:0] <= d[WIDTH-1:0];

endmodule

/* module DffTester
 *
 */
module DffTester(input q, d, input clk);

output d;

endmodule

module Test;

wire clk;

Dff dff;
DffTester tester(.clk(clk));

endmodule
