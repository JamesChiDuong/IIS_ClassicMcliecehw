/*
 * This file is the encryption module.
 *
 * Copyright (C) 2021
 * Authors: Sanjay Deshpande <sanjay.deshpande@yale.edu>
 *          
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
*/

module encrypt_col_block
 #(
    parameter parameter_set = 1,
    
    
    parameter n = (parameter_set == 1)? 3488:
                  (parameter_set == 2)? 4608:
                  (parameter_set == 3)? 6688:
                  (parameter_set == 4)? 6960: 
                                        8192,
                                         
    parameter m = (parameter_set == 1)? 12:13,    
    
    parameter t = (parameter_set == 1)? 64:
                  (parameter_set == 2)? 96:
                  (parameter_set == 3)? 128:
                  (parameter_set == 4)? 119: 
                                        128,
   
   // Key column should be equal to error vector width
//   parameter col_width = 32, // Key column width
//   parameter e_width = 32,  // error vector width
//   parameter col_width = 128, // Key column width
//   parameter e_width = 128,  // error vector width
   parameter col_width = 160, // Key column width
   parameter e_width = 160,  // error vector width
//   parameter col_width = 256, // Key column width
//   parameter e_width = 256,  // error vector width
   
   parameter k = n-m*t,
   parameter l = m*t,
   parameter ram_depth = (l + (32-l%32)%32)/32,
   parameter lm32 = (32-l%32)%32,
   parameter lme = l%e_width, //(e_width-l%e_width)%e_width
   
   parameter n_elim = col_width*((n+col_width-1)/col_width),
   parameter l_n_elim = l*n_elim,
   parameter KEY_START_ADDR = l*(l/col_width)                                                                            
 )
  (
    input wire clk,
    input wire rst,
    input wire start,
    
    output reg  rd_e,
    output reg  [`CLOG2((n+(e_width-n%e_width)%e_width)/e_width):0] e_addr,
    input wire [e_width-1:0] error,
    
    output reg  rd_k,
    output reg  [`CLOG2((l_n_elim +(col_width-l_n_elim%col_width)%col_width)/col_width) - 1:0] k_addr,
    input wire [col_width-1:0] K_col, // public keys are fed in column major fashion
//    input wire K_col_valid,

    input wire rd_en_c,
    input wire [`CLOG2((l + (32-l%32)%32)/32) -1 : 0] addr_rd_c,
    output wire [32-1:0] cipher,
//    output reg K_ready,
    output wire done
  );

reg en_er_reg;
reg shift_error;
reg shift_e_bits;
reg [e_width-1:0]error_reg;
wire error_bit;


reg done_r;
reg init_k;

// ram signals 
reg [`CLOG2((l + (32-l%32)%32)/32) -1 : 0]addr_0, addr_1;
wire [`CLOG2((l + (32-l%32)%32)/32) -1 : 0]addr_1_mux;
wire [32-1 : 0] data_0;
wire [32-1 : 0] data_1;
reg wren_0, wren_1;
wire [32-1 : 0] q_0, q_1;


reg init_ram;
reg [32-1:0]e_col;
reg [32-1:0]xored_K_and_e;
reg init_e_col;


reg [(e_width-l%e_width)%e_width-1:0]error_carry_over;
wire [e_width-1:0] error_mux;
reg error_capt;
reg [`CLOG2(((l + (e_width-l%e_width)%e_width) + (k + (32-(k)%e_width)%e_width))/e_width):0] e_addr_reg;


wire [col_width-1:0]  K_col_rev;

genvar i;
generate
    for (i=0; i < col_width; i=i+1) begin
            assign K_col_rev[i] = K_col[col_width-i-1]; 
    end
endgenerate

assign data_0 = ((l%32 != 0) && (addr_0 == ram_depth-1) && (count_k == l))? {xored_K_and_e[l%32:0], {lm32{1'b0}}} ^ q_1:
                                                                             xored_K_and_e ^ q_1; 

assign data_1 = ((l%32 != 0) && (addr_1 == ram_depth-1)) ? {e_col[(32-l%32-1)%32: 0], {lm32{1'b0}}}: 
                                                            e_col;  
                                                                                                                                                           

always@(posedge clk)
begin
   if (error_capt) begin
        error_carry_over <= error[(e_width-l%e_width - 1)%e_width:0];
   end   
end

always@(posedge clk)
begin
        e_addr_reg <= e_addr;
end

assign error_mux = (l%e_width == 0)       ? error : 
                                          {error_carry_over,error[e_width-1:(e_width-l%e_width)%e_width]};
                                          


always@(posedge clk)
begin
      if (init_k == 1'b1) begin
          xored_K_and_e <= {32{1'b0}};
      end
      else if (shift_error) begin
          xored_K_and_e <= {xored_K_and_e[32-2:0] , ^(K_col_rev & error_mux)};
      end
end

    mem_dual #(.WIDTH(32), .DEPTH((l + (32-l%32)%32)/32)) encrypt_mem (
    .clock(clk),
    .data_0(data_0),
    .data_1(data_1),
    .address_0(addr_0),
    .address_1(addr_1_mux),
    .wren_0(wren_0),
    .wren_1(wren_1),
    .q_0(q_0),
    .q_1(q_1)
  );

assign addr_1_mux = rd_en_c? addr_rd_c : addr_1;

assign cipher = q_1;

always@(posedge clk)
begin
        if (en_er_reg) begin
            error_reg <= error;  
        end
        else if (shift_e_bits) begin
            error_reg <= {error_reg[e_width-2:0] , 1'b0};
        end
end
assign error_bit = error_reg[e_width-1];

always@(posedge clk)
begin
      if (init_e_col == 1'b1) begin
          e_col <= {32{1'b0}};
      end
      else if (en_er_reg || shift_e_bits) begin
          e_col <= {e_col[32-2:0] , error_bit};
      end
end

reg [2:0] state;
parameter s_wait_e_ready            =   0;
parameter s_stall_0                 =   1;
parameter s_load_e_to_reg           =   2;
parameter s_load_e_to_ram           =   3;
parameter s_k_and_e                 =   4;
parameter s_stall_1                 =   5;
parameter s_stall_2                 =   6;
parameter s_done                    =   7;




reg [`CLOG2(n):0]count_e;
reg [`CLOG2(l*k/col_width):0]count_k;

assign done = done_r;

always@(posedge clk)
begin

    if (rst) begin
        state <= s_wait_e_ready;
        e_addr <= 0;
        count_k <= 0;
        rd_e <= 1'b0;
        addr_0 <= 0;
        addr_1 <= 0;
    end
    
    else begin
        
        if (state == s_wait_e_ready) begin
            e_addr <= 0;
            k_addr <= KEY_START_ADDR;
            addr_0 <= 0;
            if (start) begin
                state <= s_stall_0;
                done_r <= 1'b0;
                count_e <= 0;
                count_k <= 0;
                rd_e <= 1'b1;
                
                rd_k <= 1'b1;
                
            end
            else begin
                rd_e <= 1'b0;
                rd_k <= 1'b0;
            end
        end 
        
        
         
        else if  (state == s_stall_0) begin
           state <= s_load_e_to_reg;
           rd_e <= 1'b1;
           
           rd_k <= 1'b1;
        end
        
        
        else if  (state == s_load_e_to_reg) begin
                state <= s_load_e_to_ram;
                rd_e <= 1'b1;
                
                rd_k <= 1'b1;
        end
        
        else if  (state == s_load_e_to_ram) begin
            if (count_e > l-1) begin
                addr_0  <= 0;
                addr_1  <= 0;
               state <= s_stall_2;
               count_k <= 0;
            end
            else begin 
                count_e <= count_e + 1;
                if (count_e == l) begin
                    addr_0 <= 0;
                end
                else if ((count_e>1) && (count_e % 32 == 0)) begin
                   addr_1 <= addr_1 + 1;
                end
                              
                if (((count_e % e_width) == e_width-3) || (l%e_width !=0 && count_e == l-3)) begin
                    e_addr <= e_addr + 1;
                end
            end            
        end
        


        else if  (state == s_stall_2) begin
            k_addr <= k_addr + 1;
            state <= s_k_and_e;
        end 
        
        else if  (state == s_k_and_e) begin
            if (e_addr < ((l + (e_width-l%e_width)%e_width) + (k + (e_width-(k)%e_width)%e_width))/e_width) begin
                k_addr <= k_addr + 1;
                 
                if (count_k == l) begin
                    count_k <= 1;
                end
                else begin
                    count_k <= count_k + 1;
                end

                if (count_k > 0 && count_k == l-2) begin
                    e_addr <= e_addr + 1;
                end
                
                if (addr_0 == ram_depth) begin
                    addr_0 <= 0;
                end
                else if ((count_k > 0 && count_k%32 == 0) || (addr_0 == ram_depth-1 && count_k == l)) begin 
                    addr_0 <= ((addr_0 + 1) );//% ((l+(32-l%32)%32)/32)); 
                end
                
                if (addr_1 == ram_depth) begin
                    addr_1 <= 0;
                end
                else if ((count_k > 0 && count_k%32 == 32-1)|| (addr_1 == ram_depth-1 && count_k == l-1)) begin
                    addr_1 <= ((addr_1 + 1) );//% ((l+(32-l%32)%32)/32)); 
                end
                    
            end
            else begin
                state <= s_stall_1;
                rd_e <= 1'b1;
                count_k <= count_k + 1;
                rd_k <= 1'b1;
            end
        end
        
        else if  (state == s_stall_1) begin
            state <= s_done;
            done_r <= 1'b1;
        end

               
        else if  (state == s_done) begin
            state <= s_wait_e_ready;
            done_r <= 1'b0;
            rd_e <= 1'b0;
            e_addr <= 0;
            count_e <= 0;
            
            rd_k <= 1'b0;
            k_addr <= KEY_START_ADDR;
        end   
        
        
     end 
end 
 
 
always@(negedge clk) 
begin
    if(state || start||count_e||count_k||addr_0||addr_1||e_addr)
    begin
    case (state)
                    
     s_wait_e_ready: begin
                    error_capt <=1'b0;
                    wren_0 <= 1'b0;
                    wren_1 <= 1'b0;
                    init_e_col <= 1'b0;
                    en_er_reg <= 1'b0;
                    shift_error <= 1'b0;
                    shift_e_bits <= 1'b0;
                    if (start) begin
                        init_k <= 1'b1;
                    end 
                    else begin
                        init_k <= 1'b0;
                    end
                  end 
     
          
    s_stall_0: begin
                 error_capt <=1'b0;
                 init_e_col <= 1'b0;
                 init_k <= 1'b0;
               end
 
                              

     
     s_k_and_e: begin
                    wren_1 <= 1'b0;
                    shift_error <= 1'b1;
                    if ((count_k > 0 && count_k%32 == 0)|| (addr_0 == ram_depth-1 && count_k == l)) begin
                        wren_0 <= 1'b1;
                    end
                    else begin
                        wren_0 <= 1'b0;
                    end    

                    
                    if (e_addr < ((l + (e_width-l%e_width)%e_width) + (k + (e_width-(k)%e_width)%e_width))/col_width ) begin
                        if (count_k == l-1) begin
                            error_capt <=1'b1;
                        end
                        else begin
                            error_capt <=1'b0;
                        end
                    end
                    else begin
                        error_capt <=1'b0;
                    end
                end
 
        s_stall_1: begin
                   wren_0 <= 1'b1;
                   end
                   
    s_load_e_to_reg: begin
                      init_k <= 1'b0;
                      en_er_reg <= 1'b1;
                      shift_e_bits <= 1'b0;
                     end
                     
        s_stall_2: begin
                        wren_1 <= 1'b0;
                   end
                                   
    s_load_e_to_ram: begin
                        init_e_col <= 1'b0;
                        if ((count_e > 0 && count_e%32 == 0) || count_e == l) begin
                            wren_1 <= 1'b1;
                        end
                        else begin
                            wren_1 <= 1'b0;
                        end
                        
                        if (count_e%e_width == e_width-1) begin
                            shift_e_bits <= 1'b0;
                            en_er_reg   <= 1'b1; 
                        end
                        else begin
                            shift_e_bits <= 1'b1;
                            en_er_reg   <= 1'b0;
                        end

                        if (((count_e % e_width) == e_width-3) || (l%e_width !=0 && count_e == l-3)) begin
                            error_capt <=1'b1;
                        end
                        else begin
                            error_capt <=1'b0;
                        end
                        
                     end

                          
     s_done: begin
                    en_er_reg <= 1'b0;
                    shift_error <= 1'b0;
                    shift_e_bits <= 1'b0;
                    wren_0 <= 1'b0;
                    wren_1 <= 1'b0;
                   end
            
   default: en_er_reg <= 1'b0;
      
    endcase  
    end

end  

endmodule

