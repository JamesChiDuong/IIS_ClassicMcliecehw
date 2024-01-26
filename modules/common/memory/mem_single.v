module mem_single
  #(
    parameter WIDTH = 8,
    parameter DEPTH = 64,
    parameter FILE = "",
    parameter INIT = 0
  )
  (
    input wire                     clock,
    input wire [WIDTH-1:0]         data,
    //input wire [`CLOG2(DEPTH)-1:0] address,
    input wire [17-1:0] address,
    input wire                     wr_en,
    output reg [WIDTH-1:0]         q
  );

  
  (* ram_style = "block" *) reg [WIDTH-1:0] mem [0:DEPTH-1] /* synthesis ramstyle = "M20K" */;
  (* ram_style = "block" *) reg [WIDTH-1:0] mem1 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem2 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem3 [0:DEPTH-1];
   
  (* ram_style = "block" *) reg [WIDTH-1:0] mem4 [0:DEPTH-1] /* synthesis ramstyle = "M20K" */;
  (* ram_style = "block" *) reg [WIDTH-1:0] mem5 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem6 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem7 [0:DEPTH-1];
  
  (* ram_style = "block" *) reg [WIDTH-1:0] mem8 [0:DEPTH-1] /* synthesis ramstyle = "M20K" */;
  (* ram_style = "block" *) reg [WIDTH-1:0] mem9 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem10 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem11 [0:DEPTH-1];
   
  (* ram_style = "block" *) reg [WIDTH-1:0] mem12 [0:DEPTH-1] /* synthesis ramstyle = "M20K" */;
  (* ram_style = "block" *) reg [WIDTH-1:0] mem13 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem14 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem15 [0:DEPTH-1];

  (* ram_style = "block" *) reg [WIDTH-1:0] mem16 [0:DEPTH-1] /* synthesis ramstyle = "M20K" */;
  (* ram_style = "block" *) reg [WIDTH-1:0] mem17 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem18 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem19 [0:DEPTH-1];
   
  (* ram_style = "block" *) reg [WIDTH-1:0] mem20 [0:DEPTH-1] /* synthesis ramstyle = "M20K" */;
  (* ram_style = "block" *) reg [WIDTH-1:0] mem21 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem22 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem23 [0:DEPTH-1];
  
  (* ram_style = "block" *) reg [WIDTH-1:0] mem24 [0:DEPTH-1] /* synthesis ramstyle = "M20K" */;
  (* ram_style = "block" *) reg [WIDTH-1:0] mem25 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem26 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem27 [0:DEPTH-1];
   
  (* ram_style = "block" *) reg [WIDTH-1:0] mem28 [0:DEPTH-1] /* synthesis ramstyle = "M20K" */;
  (* ram_style = "block" *) reg [WIDTH-1:0] mem29 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem30 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem31 [0:DEPTH-1];

  (* ram_style = "block" *) reg [WIDTH-1:0] mem32 [0:DEPTH-1] /* synthesis ramstyle = "M20K" */;
  (* ram_style = "block" *) reg [WIDTH-1:0] mem33 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem34 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem35 [0:DEPTH-1];
  
  (* ram_style = "block" *) reg [WIDTH-1:0] mem36 [0:DEPTH-1] /* synthesis ramstyle = "M20K" */;
  (* ram_style = "block" *) reg [WIDTH-1:0] mem37 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem38 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem39 [0:DEPTH-1];
   
  (* ram_style = "block" *) reg [WIDTH-1:0] mem40 [0:DEPTH-1] /* synthesis ramstyle = "M20K" */;
  (* ram_style = "block" *) reg [WIDTH-1:0] mem41 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem42 [0:DEPTH-1];
  (* ram_style = "block" *) reg [WIDTH-1:0] mem43 [0:DEPTH-1];
  
  
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
          if(0 <= address &&  address < DEPTH)
          begin
            mem[address] <= data;
          end
          else if (DEPTH <= address && address < DEPTH*2)
          begin
            mem1[address-DEPTH] <= data;
          end
          else if (DEPTH*2 <= address && address < DEPTH*3)
          begin
            mem2[address-DEPTH*2] <= data;
          end
          else if (DEPTH*3 <= address && address < DEPTH*4)
          begin
            mem3[address-DEPTH*3] <= data;
          end
          else if (DEPTH*4 <= address && address < DEPTH*5)
          begin
            mem4[address-DEPTH*4] <= data;
          end
          else if (DEPTH*5 <= address && address < DEPTH*6)
          begin
            mem5[address-DEPTH*5] <= data;
          end
          else if (DEPTH*6 <= address && address < DEPTH*7)
          begin
            mem6[address-DEPTH*6] <= data;
          end
          else if (DEPTH*7 <= address && address < DEPTH*8)
          begin
            mem7[address-DEPTH*7] <= data;
          end
          else if (DEPTH*8 <= address && address < DEPTH*9)
          begin
            mem8[address-DEPTH*8] <= data;
          end
          else if (DEPTH*9 <= address && address < DEPTH*10)
          begin
            mem9[address-DEPTH*9] <= data;
          end
          else if (DEPTH*10 <= address && address < DEPTH*11)
          begin
            mem10[address-DEPTH*10] <= data;
          end
          else if (DEPTH*11 <= address && address < DEPTH*12)
          begin
            mem11[address-DEPTH*11] <= data;
          end
          else if (DEPTH*12 <= address && address < DEPTH*13)
          begin
            mem12[address-DEPTH*12] <= data;
          end
          else if (DEPTH*13 <= address && address < DEPTH*14)
          begin
            mem13[address-DEPTH*13] <= data;
          end
          else if (DEPTH*14 <= address && address < DEPTH*15)
          begin
            mem14[address-DEPTH*14] <= data;
          end

          else if (DEPTH*15 <= address && address < DEPTH*16)
          begin
            mem15[address-DEPTH*15] <= data;
          end
          else if (DEPTH*16 <= address && address < DEPTH*17)
          begin
            mem16[address-DEPTH*16] <= data;
          end
          else if (DEPTH*17 <= address && address < DEPTH*18)
          begin
            mem17[address-DEPTH*17] <= data;
          end
          else if (DEPTH*18 <= address && address < DEPTH*19)
          begin
            mem18[address-DEPTH*18] <= data;
          end
          else if (DEPTH*19 <= address && address < DEPTH*20)
          begin
            mem19[address-DEPTH*19] <= data;
          end
          else if (DEPTH*20 <= address && address < DEPTH*21)
          begin
            mem20[address-DEPTH*20] <= data;
          end
          else if (DEPTH*21 <= address && address < DEPTH*22)
          begin
            mem21[address-DEPTH*21] <= data;
          end


          else if (DEPTH*22 <= address && address < DEPTH*23)
          begin
            mem22[address-DEPTH*22] <= data;
          end
          else if (DEPTH*23 <= address && address < DEPTH*24)
          begin
            mem23[address-DEPTH*23] <= data;
          end
          else if (DEPTH*24 <= address && address < DEPTH*25)
          begin
            mem24[address-DEPTH*24] <= data;
          end
          else if (DEPTH*25 <= address && address < DEPTH*26)
          begin
            mem25[address-DEPTH*25] <= data;
          end
          else if (DEPTH*26 <= address && address < DEPTH*27)
          begin
            mem26[address-DEPTH*26] <= data;
          end
          else if (DEPTH*27 <= address && address < DEPTH*28)
          begin
            mem27[address-DEPTH*27] <= data;
          end
          else if (DEPTH*28 <= address && address < DEPTH*29)
          begin
            mem28[address-DEPTH*28] <= data;
          end


          else if (DEPTH*29 <= address && address < DEPTH*30)
          begin
            mem29[address-DEPTH*29] <= data;
          end
          else if (DEPTH*30 <= address && address < DEPTH*31)
          begin
            mem30[address-DEPTH*30] <= data;
          end
          else if (DEPTH*31 <= address && address < DEPTH*32)
          begin
            mem31[address-DEPTH*31] <= data;
          end
          else if (DEPTH*32 <= address && address < DEPTH*33)
          begin
            mem32[address-DEPTH*32] <= data;
          end
          else if (DEPTH*33 <= address && address < DEPTH*34)
          begin
            mem33[address-DEPTH*33] <= data;
          end
          else if (DEPTH*34 <= address && address < DEPTH*35)
          begin
            mem34[address-DEPTH*34] <= data;
          end
          else if (DEPTH*35 <= address && address < DEPTH*36)
          begin
            mem35[address-DEPTH*35] <= data;
          end
          else if (DEPTH*36 <= address && address < DEPTH*37)
          begin
            mem36[address-DEPTH*36] <= data;
          end
          else if (DEPTH*37 <= address && address < DEPTH*38)
          begin
            mem37[address-DEPTH*37] <= data;
          end
          else if (DEPTH*38 <= address && address < DEPTH*39)
          begin
            mem38[address-DEPTH*38] <= data;
          end

          else if (DEPTH*39 <= address && address < DEPTH*40)
          begin
            mem39[address-DEPTH*39] <= data;
          end
          else if (DEPTH*40 <= address && address < DEPTH*41)
          begin
            mem40[address-DEPTH*40] <= data;
          end
          else if (DEPTH*41 <= address && address < DEPTH*42)
          begin
            mem41[address-DEPTH*41] <= data;
          end                            
          //q <= data;
        end
      else
        if(0 <= address &&  address < DEPTH)
        begin
          q <= mem[address];
        end
        else if (DEPTH <= address && address < DEPTH*2)
        begin
          q <= mem1[address];
        end
        else if (DEPTH*2 <= address && address < DEPTH*3)
        begin
          q <= mem2[address-DEPTH*2];
        end
        else if (DEPTH*3 <= address && address < DEPTH*4)
        begin
          q <= mem3[address-DEPTH*3];
        end
        else if (DEPTH*4 <= address && address < DEPTH*5)
        begin
          q <= mem4[address-DEPTH*4];
        end

        else if (DEPTH*5 <= address && address < DEPTH*6)
        begin
          q <= mem5[address-DEPTH*5];
        end
        else if (DEPTH*6 <= address && address < DEPTH*7)
        begin
          q <= mem6[address-DEPTH*6];
        end
        else if (DEPTH*7 <= address && address < DEPTH*8)
        begin
          q <= mem7[address-DEPTH*7];
        end
        else if (DEPTH*8 <= address && address < DEPTH*9)
        begin
          q <= mem8[address-DEPTH*8];
        end
        else if (DEPTH*9 <= address && address < DEPTH*10)
        begin
          q <= mem9[address-DEPTH*9];
        end
        else if (DEPTH*10 <= address && address < DEPTH*11)
        begin
          q <= mem10[address-DEPTH*10];
        end
        else if (DEPTH*11 <= address && address < DEPTH*12)
        begin
          q <= mem11[address-DEPTH*11];
        end
        else if (DEPTH*12 <= address && address < DEPTH*13)
        begin
          q <= mem12[address-DEPTH*12];
        end
        else if (DEPTH*13 <= address && address < DEPTH*14)
        begin
          q <= mem13[address-DEPTH*13];
        end
        else if (DEPTH*14 <= address && address < DEPTH*15)
        begin
          q <= mem14[address-DEPTH*14];
        end

        else if (DEPTH*15 <= address && address < DEPTH*16)
        begin
          q <= mem15[address-DEPTH*15];
        end
        else if (DEPTH*16 <= address && address < DEPTH*17)
        begin
          q <= mem16[address-DEPTH*16];
        end
        else if (DEPTH*17 <= address && address < DEPTH*18)
        begin
          q <= mem17[address-DEPTH*17];
        end
        else if (DEPTH*18 <= address && address < DEPTH*19)
        begin
          q <= mem18[address-DEPTH*18];
        end
        else if (DEPTH*19 <= address && address < DEPTH*20)
        begin
          q <= mem19[address-DEPTH*19];
        end
        else if (DEPTH*20 <= address && address < DEPTH*21)
        begin
          q <= mem20[address-DEPTH*20];
        end
        else if (DEPTH*21 <= address && address < DEPTH*22)
        begin
          q <= mem21[address-DEPTH*21];
        end


        else if (DEPTH*22 <= address && address < DEPTH*23)
        begin
          q <= mem22[address-DEPTH*22];
        end
        else if (DEPTH*23 <= address && address < DEPTH*24)
        begin
          q <= mem23[address-DEPTH*23];
        end
        else if (DEPTH*24 <= address && address < DEPTH*25)
        begin
          q <= mem24[address-DEPTH*24] <= data;
        end
        else if (DEPTH*25 <= address && address < DEPTH*26)
        begin
          q <= mem25[address-DEPTH*25];
        end
        else if (DEPTH*26 <= address && address < DEPTH*27)
        begin
          q <= mem26[address-DEPTH*26];
        end
        else if (DEPTH*27 <= address && address < DEPTH*28)
        begin
          q <= mem27[address-DEPTH*27];
        end
        else if (DEPTH*28 <= address && address < DEPTH*29)
        begin
          q <= mem28[address-DEPTH*28];
        end


        else if (DEPTH*29 <= address && address < DEPTH*30)
        begin
          q <= mem29[address-DEPTH*29];
        end
        else if (DEPTH*30 <= address && address < DEPTH*31)
        begin
          q <= mem30[address-DEPTH*30];
        end
        else if (DEPTH*31 <= address && address < DEPTH*32)
        begin
          q <= mem31[address-DEPTH*31];
        end
        else if (DEPTH*32 <= address && address < DEPTH*33)
        begin
          q <= mem32[address-DEPTH*32];
        end
        else if (DEPTH*33 <= address && address < DEPTH*34)
        begin
          q <= mem33[address-DEPTH*33];
        end
        else if (DEPTH*34 <= address && address < DEPTH*35)
        begin
          q <= mem34[address-DEPTH*34];
        end
        else if (DEPTH*35 <= address && address < DEPTH*36)
        begin
          q <= mem35[address-DEPTH*35];
        end
        else if (DEPTH*36 <= address && address < DEPTH*37)
        begin
          q <= mem36[address-DEPTH*36];
        end
        else if (DEPTH*37 <= address && address < DEPTH*38)
        begin
          q <= mem37[address-DEPTH*37];
        end
        else if (DEPTH*38 <= address && address < DEPTH*39)
        begin
          q <= mem38[address-DEPTH*38];
        end

        else if (DEPTH*39 <= address && address < DEPTH*40)
        begin
          q <= mem39[address-DEPTH*39];
        end
        else if (DEPTH*40 <= address && address < DEPTH*41)
        begin
          q <= mem40[address-DEPTH*40];
        end
        else if (DEPTH*41 <= address && address < DEPTH*42)
        begin
          q <= mem41[address-DEPTH*41];
        end                            
        //q <= mem[address];
    end
  
endmodule
// module mem_single
//   #(
//     parameter WIDTH = 8,
//     parameter DEPTH = 64,
//     parameter FILE = "",
//     parameter INIT = 0
//   )
//   (
//     input wire                     clock,
//     input wire [WIDTH-1:0]         data,
//     input wire [`CLOG2(DEPTH)-1:0] address,
//     input wire                     wr_en,
//     output reg [WIDTH-1:0]         q
//   );
  
//   reg [WIDTH-1:0] mem [DEPTH-1:0]/* synthesis ramstyle = "M20K" */;
   
//   integer file;
//   integer scan;
//   integer i;
  
//   initial
//     begin
//       // read file contents if FILE is given
//       if (FILE != "")
//         $readmemb(FILE, mem);
      
//       // set all data to 0 if INIT is true
//       if (INIT)
//         for (i = 0; i < DEPTH; i = i + 1)
//           mem[i] = {WIDTH{1'b0}};
//     end
  
//   always @(posedge clock)
//     begin
//       if (wr_en)
//         begin
//           mem[address] <= data;
//           q <= data;
//         end
//       q <= mem[address];
//     end
  
// endmodule

