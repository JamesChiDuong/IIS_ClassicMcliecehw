module mem_single
  #(
    parameter WIDTH = 8,
    parameter DEPTH = 64,
    /* verilator lint_off UNUSEDSIGNAL */
    parameter FILE = "",
    parameter INIT = 0
  )
  (
    input wire                     clock,
    input wire [WIDTH-1:0]         data,
    input wire [(DEPTH)-1:0] address,
    input wire                     wr_en,
    output reg [WIDTH-1:0]         q
  );
  
  reg [WIDTH-1:0] mem [DEPTH-1:0]/* synthesis ramstyle = "M20K" */;
  /* verilator lint_off UNUSEDSIGNAL */ 
  integer file;
  integer scan;
  integer i;
  
  initial
    begin
      // read file contents if FILE is given
      if (FILE != "")
        $readmemb(FILE, mem);
      
      // set all data to 0 if INIT is true
      if (INIT)
        for (i = 0; i < DEPTH; i = i + 1)
          mem[i] = {WIDTH{1'b0}};
    end
  
  always @(posedge clock)
    begin
      if (wr_en)
        begin
          /* verilator lint_off WIDTH */
          mem[address] <= data;
          q <= data;
        end
      q <= mem[address];
    end
  
endmodule
