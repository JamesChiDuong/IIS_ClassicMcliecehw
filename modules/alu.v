module alu (
    input clk,
    input wire [7:0] number1,
    input wire [7:0] number2,
    input  [2:0] sel,
    /* verilator lint_off WIDTH */
    output reg [15:0] alu_out
);
always@(posedge clk)
  case (sel)
    /* verilator lint_off WIDTH */
    3'b001 :  	alu_out <= (number1 + number2);
    3'b010 :  	alu_out <= (number1 - number2);
    3'b011 :  	alu_out <= number1 * number2;
    3'b100 :  	alu_out <= number1 / number2;
    default:	  alu_out <= 0;
  endcase  
endmodule
