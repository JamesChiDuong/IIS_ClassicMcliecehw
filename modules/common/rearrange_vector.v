// This file is part of the Classic McEliece hardware source code.
// 
// Copyright (C) 2022
//
// Authors: Sanjay Deshpande <sanjay.deshpande@yale.edu>
// 
// This source code is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option) any
// later version.
// 
// This source code is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
// 
// You should have received a copy of the GNU General Public License along with
// this source code. If not, see <https://www.gnu.org/licenses/>. 

module rearrange_vector(
    input [31:0] vector_in,
    output [31:0] vector_out
    );
    
    
 wire [31:0]  initial_arrange;
 
genvar i, j;
generate
    for (i=0; i<32/8; i=i+1) begin
        for (j=0; j<8; j =j+1) begin 
            assign initial_arrange[8*i+j] = vector_in[8*(i+1)-j-1]; 
        end    
    end
endgenerate

assign  vector_out[7:0]  = initial_arrange[31:24];
assign  vector_out[15:8] = initial_arrange[23:16];
assign  vector_out[23:16]= initial_arrange[15:8];
assign  vector_out[31:24]= initial_arrange[7:0];

endmodule

