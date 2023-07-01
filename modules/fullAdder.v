module fullAdder (
    input wire [7:0] number1,
    input wire [7:0] number2,
    /* verilator lint_off WIDTH */
    input cin,
    output wire [7:0] sum,
    output wire cout
);
  assign {cout, sum} = number1 + number2 + cin;  
endmodule
