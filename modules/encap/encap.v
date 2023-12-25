`timescale 1ns / 1ps
/*
 * This file is the key encapsulation mechanism module.
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

module encap_seq_gen#( 

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
   
   
   
   parameter k = n-m*t,
   parameter l = m*t,
   
   parameter col_width = 32,
   parameter e_width = 32,
   
//   parameter col_width = 160,
//   parameter e_width   = 160,
   
   
   // SHAKE256 related parameters
   parameter SHAKE_FIRST_IN  =  32'h40000100, //0x4 in MSB means operating with SHAKE256, 0x100 = 256 bits of output requested from keccak module
   parameter SHAKE_SECOND_IN =  32'h00000440, //0x440 = 1088 which is rate/full-block size for SHAKE256
   
    
   //0x8 in MSB signifies last block and other LSB signify last block size for Hash(2,e)
   parameter E_SHAKE_LAST_IN = (parameter_set == 1)?  32'h800000e8:
                               (parameter_set == 2)?  32'h80000108:
                               (parameter_set == 3)?  32'h800000a8:
                               (parameter_set == 5)?  32'h80000248:
                                                      32'h800001b8,
                                                      
   //0x8 in MSB signifies last block and other LSB signify last block size for Hash(1,e,C)                                                   
   parameter SHAKE_LAST_IN   =  (parameter_set == 1)? 32'h800000a8:
                                (parameter_set == 2)? 32'h800002a8:
                                (parameter_set == 3)? 32'h800003e8:
                                (parameter_set == 5)? 32'h80000148:
                                                      32'h80000048,
   
   //Width Calculations for Hash(1,e,C), this also takes in to account the domain seperators required for SHAKE256
   parameter hash_bits = n + l + 256 + 8,
   parameter hb_by_32 = (hash_bits + (32-hash_bits%32)%32)/32,
   parameter SH_DOM_SEP = (hb_by_32 + (34-hb_by_32%34)%34)/34, // sh_dom_sep: total domain seperators required, 34 because 34*32 = 1088 and it is the rate for SHAKE256 
   parameter HASH_RAM_DEPTH =  hb_by_32 + 1 + SH_DOM_SEP, // 32 because SHAKE module accepts only 32 bit inputs
   
   //Width Calculations for Hash(2,e), this also takes in to account the domain seperators required for SHAKE256
   parameter e_hash_bits = n + 8,
   parameter e_hb_by_32 = (e_hash_bits + (32-e_hash_bits%32)%32)/32,
   parameter E_SH_DOM_SEP = (e_hb_by_32 + (34-e_hb_by_32%34)%34)/34,
   parameter E_HASH_DEPTH = e_hb_by_32 + 1 + E_SH_DOM_SEP,
   
   parameter C0_w = (parameter_set == 4) ? 24 : 8,
   parameter C1_w_h = (parameter_set == 4)? 16 : 32, 
   parameter C1_w_l = (parameter_set == 4)? 8 : 24,
  
   parameter n_elim = col_width*((n+col_width-1)/col_width),
   parameter l_n_elim = l*n_elim,
   parameter KEY_START_ADDR = l*(l/col_width)
   
  ) 
(
    input clk,
    input rst,
    input seed_valid,

    output PK_rd,
    output [`CLOG2((l_n_elim +(col_width-l_n_elim%col_width)%col_width)/col_width) - 1:0] PK_addr,
    input [col_width-1:0] PK_col,
    input [31:0] seed,
    output done,
    
    
    input rd_C0,
    input [`CLOG2((l + (32-l%32)%32)/32) -1 : 0]C0_addr, 
    output [31:0]C0_out,
    
    input rd_C1,
    input [2:0]C1_addr, 
    output [31:0]C1_out,
    
    input rd_K,
    input [2:0]K_addr, 
    output [31:0]K_out,
    
    //shake interface
    output din_valid_shake_enc,
    output [31:0] din_shake_enc,
    output dout_ready_shake_enc,
    output force_done_shake,   
    input din_ready_shake,
    input dout_valid_shake,
    input [31:0]dout_shake
    );

wire done_error;
wire [e_width-1:0] error_0;
wire rd_e_0;
wire [32-1:0] error_1;
reg rd_e_1 = 1'b0;
reg [`CLOG2((n+(32-n%32)%32)/32) - 1:0]rd_addr_e_1;
wire [`CLOG2((n+(e_width-n%e_width)%e_width)/e_width) - 1:0]rd_addr_e_0;

wire K_ready_internal; 

wire seed_valid_internal;
wire seed_ready_internal;
wire  [31:0] din_shake;
wire shake_out_capture_ready;
wire [31:0] dout_shake_scrambled;
//wire force_done_shake;
wire dout_valid_sh_internal;

wire [32-1:0] arrange_error_1;

wire [32-1:0] rev_error_1;
reg [32-1:0] rev_error_1_reg;





wire seed_valid_internal_fw;
wire seed_ready_internal_fw;
wire  [31:0] din_shake_fw;
wire shake_out_capture_ready_fw;
wire [31:0] dout_shake_scrambled_fw;
wire force_done_shake_fw;
wire dout_valid_sh_internal_fw;


reg [2:0] sel_in_shake;
reg din_valid;
reg din_valid_h;

reg start_hash;
reg reg_en_er;
reg [2:0]sel_hram;
reg [1:0]sel_ec;
reg sel_k;
parameter [7:0] byte_2 = 8'h02;
parameter [7:0] byte_1 = 8'h01;

wire [31:0] C0, C1;
reg [31:0] C0_reg, C1_reg;
wire [31:0] cipher;
wire done_encrypt;
reg first_C0, first_C1, last_C1;

reg [`CLOG2((l + (32-l%32)%32)/32) -1 : 0] addr_rd_c;
reg rd_en_c;
reg C1_read_ready;
reg dont_capture_shake;
reg dont_capture_C0;
reg [`CLOG2(HASH_RAM_DEPTH):0]count_hash_in;

wire [31:0] change01;
wire [31:0] e_to_ram;
wire [31:0] h_data_0, h_data_1;
wire [31:0] q_0, q_1;
reg h_wren_0, h_wren_1;
reg [`CLOG2(HASH_RAM_DEPTH):0] h_addr_0, h_addr_1;
reg [`CLOG2(HASH_RAM_DEPTH):0] total_contents;
wire [31:0] C0_to_ram, C1_to_ram;

wire [31:0] C1_rearrange, C1_from_ram;
reg wr_en_C1;
reg [2:0]C1_addr_internal;



//shake interface signals
assign din_valid_shake_enc = seed_valid_internal;
assign seed_ready_internal = din_ready_shake;
assign din_shake_enc = din_shake;
assign dout_valid_sh_internal = dout_valid_shake;
assign dout_ready_shake_enc = shake_out_capture_ready | C1_read_ready;
assign dout_shake_scrambled = dout_shake;


assign C0_out = cipher;
assign C1_out = C1_from_ram;
assign K_out = q_1;

//  keccak_top shake_instance
// (
//    .rst(rst),
//    .clk(clk),
//    .din_valid(seed_valid_internal),
//    .din_ready(seed_ready_internal),
//    .din(din_shake),
//    .dout_valid(dout_valid_sh_internal),
//    .dout_ready(shake_out_capture_ready | C1_read_ready),
//    .dout(dout_shake_scrambled),
//    .force_done(force_done_shake)
//);
rearrange_vector C1_arrange(.vector_in(dout_shake_scrambled),.vector_out(C1_rearrange));

 mem_single #(.WIDTH(32), .DEPTH(8) ) C1_mem
 (
        .clock(clk),
        .data(C1_rearrange),
        .address(rd_C1?C1_addr:C1_addr_internal),
        .wr_en(wr_en_C1),
        .q(C1_from_ram)
 );
 
   fixed_weight_no_shake_mw #(.parameter_set(parameter_set), .n(n), .m(m), .t(t), .E1_WIDTH(32), .E0_WIDTH(e_width)) error_vector_gen
    (
    .clk(clk),
    .rst(rst),
    .seed_valid(seed_valid),
    .seed(seed),
    .done(done_error),
    
    
    // read port for error 1
    .rd_e_0(rd_e_0),
    .rd_addr_e_0(rd_addr_e_0),
    .error_0(error_0),
    
    // read port for error 2
    .rd_e_1(rd_e_1),
    .rd_addr_e_1(rd_addr_e_1),
    .error_1(error_1),
    
    
    //shake signals
    .seed_valid_internal(seed_valid_internal_fw),
    .seed_ready_internal(seed_ready_internal_fw),
    .din_shake(din_shake_fw),
    .shake_out_capture_ready(shake_out_capture_ready_fw),
    .dout_shake_scrambled(dout_shake_scrambled_fw),
    .force_done_shake(force_done_shake),
    .dout_valid_sh_internal(dout_valid_sh_internal_fw)
    
  );
  
  
    

encrypt_col_block # (.parameter_set(parameter_set), .m(m), .t(t), .n(n), .l(l), .e_width(e_width), .col_width(col_width), .KEY_START_ADDR(KEY_START_ADDR)) encryption_unit  
  (
    .clk(clk),
    .rst(rst),
    .start(done_error),
    .rd_k(PK_rd),
    .k_addr(PK_addr),
    .K_col(PK_col),
    .rd_e(rd_e_0),
    .e_addr(rd_addr_e_0),
    .error(error_0),
    .done(done_encrypt),
    .addr_rd_c(rd_C0?C0_addr:addr_rd_c),
    .rd_en_c(rd_C0?1'b1:rd_en_c),
    .cipher(cipher)
    ); 

rearrange_vector e_in_arrange(.vector_in(error_1),.vector_out(rev_error_1));

rearrange_vector c_out_arrange(.vector_in(cipher),.vector_out(C0));


assign C1 = dout_shake_scrambled;

always@(posedge clk)
begin
    if (!dont_capture_C0) begin
        C0_reg <= C0;
    end    
    if (dout_valid_sh_internal && (!dont_capture_shake)) begin
        C1_reg <= C1;
    end
end


always@(posedge clk)
begin
    if (reg_en_er) begin
        rev_error_1_reg <= rev_error_1;
    end
end

 

assign seed_valid_internal = seed_valid_internal_fw | din_valid_h;
assign seed_ready_internal = seed_ready_internal_fw;


assign shake_out_capture_ready = shake_out_capture_ready_fw;
assign dout_shake_scrambled_fw = dout_shake_scrambled;
assign dout_valid_sh_internal_fw = dout_valid_sh_internal;




assign din_shake = (sel_in_shake == 3'b001)? q_0:
                                             din_shake_fw;




reg [4:0] state_hr = 0;
parameter s_first_block             =   0;
parameter s_second_block            =   1;
parameter s_wait_for_error_done     =   2;
parameter s_stall_for_ram           =   3;
parameter s_load_data_to_ram        =   4;
parameter s_load_domain_seperator   =   5;
parameter s_done_loading            =   6;
parameter s_update_01               =   7;
parameter s_update_e_domain         =   8;
parameter s_wait_encrypt_done       =   9;
parameter s_load_enc_to_ram         =   10;
parameter s_load_last_C0            =   11;
parameter s_load_domain_sep_3       =   12;
parameter s_first_load_C1           =   13;
parameter s_load_C1                 =   14;
parameter s_load_domain_sep_2       =   15;
parameter s_load_last_C1            =   16;
parameter s_calculate_K             =   17;
parameter s_wait_K_done             =   18;
parameter s_save_K                  =   19;
parameter s_done                    =   20;

reg done_r=0;


assign done = done_r;

//Loading Hash RAM
always@(posedge clk)
begin

     if (rst) begin
        state_hr <= s_first_block;
        rd_addr_e_1 <= 0;
        h_addr_1 <= 0;
        addr_rd_c <= 0;
        C1_read_ready <= 1'b0;
        count_hash_in <= 0;
        C1_addr_internal <= 0;
     end
     
     else begin
        if (state_hr == s_first_block) begin
            h_addr_1 <= h_addr_1 + 1;
            count_hash_in <= 0;
            state_hr <= s_second_block;
            addr_rd_c <= 0;
            C1_read_ready <= 1'b0;
            C1_addr_internal <= 0;

        end
        
        else if (state_hr == s_second_block) begin
            h_addr_1 <= h_addr_1 + 1;
            count_hash_in <= count_hash_in + 1;
            state_hr <= s_wait_for_error_done;
            
        end
        
        else if (state_hr == s_wait_for_error_done) begin
            
            if (done_error) begin    
                state_hr <= s_stall_for_ram;
                rd_addr_e_1 <= 0;
                rd_addr_e_1 <= rd_addr_e_1 + 1;
            end
            
        end
        
         else if (state_hr == s_stall_for_ram) begin
              state_hr <= s_load_data_to_ram;
              h_addr_1 <= h_addr_1 + 1;
              rd_addr_e_1 <= rd_addr_e_1 + 1;
              count_hash_in <= count_hash_in + 1;
         end
         
         else if (state_hr == s_load_data_to_ram) begin
            if (h_addr_1 > E_HASH_DEPTH - 1) begin
                state_hr <= s_done_loading;
                rd_addr_e_1 <= 0;
            end
            else begin
                h_addr_1 <= h_addr_1 + 1;
                count_hash_in <= count_hash_in + 1;
                
                if (rd_addr_e_1> 0 && rd_addr_e_1 % 34 == 0) begin
                    state_hr <= s_load_domain_seperator;
                end
                else begin
                    state_hr <= s_load_data_to_ram;
                    rd_addr_e_1 <= rd_addr_e_1 + 1;
                    
                end 
            end
         end 
         
        else if (state_hr == s_load_domain_seperator) begin
            state_hr <= s_load_data_to_ram;
            h_addr_1 <= h_addr_1 + 1;
            rd_addr_e_1 <= rd_addr_e_1 + 1;
            
        end
        
        else if (state_hr == s_done_loading) begin
            h_addr_1 <= 2;
            if (dout_valid_sh_internal) begin
                state_hr <= s_update_01;
            end
            else begin
                state_hr <= s_done_loading;
            end
        end
        
        else if (state_hr == s_update_01) begin
            h_addr_1 <= E_HASH_DEPTH - E_HASH_DEPTH%34 + 1 + E_SH_DOM_SEP - 1;
            state_hr <= s_update_e_domain;
        end
        
        else if (state_hr == s_update_e_domain) begin
            h_addr_1 <= E_HASH_DEPTH-1;
            state_hr <= s_wait_encrypt_done;
        end
        
        else if (state_hr == s_wait_encrypt_done) begin
            h_addr_1 <= E_HASH_DEPTH-1;
            
            if (done_encrypt) begin
                state_hr <= s_load_enc_to_ram;
                count_hash_in <= count_hash_in - 1;
            end
            else begin
                state_hr <= s_wait_encrypt_done;
            end
        end
        
        else if (state_hr == s_load_enc_to_ram) begin
            if (addr_rd_c == (l + (32-l%32)%32)/32 -1) begin
                state_hr <= s_load_last_C0;
                h_addr_1 <= h_addr_1 + 1;
                count_hash_in <= count_hash_in + 1;
            end
            else begin
                if (count_hash_in%34 == 0) begin
                    state_hr <= s_load_domain_sep_3;
                    h_addr_1 <= h_addr_1 + 1;
                end
                else begin
                    addr_rd_c <= addr_rd_c+1;
                    state_hr <= s_load_enc_to_ram;
                    if (addr_rd_c > 0) begin
                        h_addr_1 <= h_addr_1 + 1;
                        count_hash_in <= count_hash_in + 1;
                    end
                end
            end
        end
        
        else if (state_hr == s_load_domain_sep_3) begin
            h_addr_1 <= h_addr_1 + 1;
            state_hr <= s_load_enc_to_ram;
            addr_rd_c <= addr_rd_c+1;
            count_hash_in <= count_hash_in + 1;
        end
        
        else if (state_hr == s_load_last_C0) begin
            h_addr_1 <= h_addr_1 + 1;
            state_hr <= s_first_load_C1;
            C1_read_ready <= 1'b1;
            count_hash_in <= count_hash_in + 1;
        end
        
        else if (state_hr == s_first_load_C1) begin
            h_addr_1 <= h_addr_1 + 1;
            state_hr <= s_load_C1; 
            count_hash_in <= count_hash_in + 1; 
            C1_addr_internal <= C1_addr_internal + 1;  
        end
        
        else if (state_hr == s_load_C1) begin
            if (h_addr_1 == HASH_RAM_DEPTH-1) begin
                state_hr <= s_load_last_C1;    
            end
            else if (h_addr_1 == HASH_RAM_DEPTH - HASH_RAM_DEPTH%34 + SH_DOM_SEP) begin
              state_hr <= s_load_domain_sep_2;
              C1_read_ready <= 1'b0;
            end
            else begin
               if (dout_valid_sh_internal) begin
                   h_addr_1 <= h_addr_1 + 1;
                   count_hash_in <= count_hash_in + 1;
                   
                   C1_addr_internal <= C1_addr_internal + 1;
               end
            end
        end
        
        else if (state_hr == s_load_domain_sep_2) begin
            C1_read_ready <= 1'b1;
            h_addr_1 <= h_addr_1 + 1;
            state_hr <= s_load_C1;
            count_hash_in <= count_hash_in + 1;
        end
        
        else if (state_hr == s_load_last_C1) begin
            h_addr_1 <= 0;
            state_hr <= s_calculate_K;
            C1_read_ready <= 1'b0;
        end
        
        else if (state_hr == s_calculate_K) begin 
            state_hr <= s_wait_K_done;
        end
        
        else if (state_hr == s_wait_K_done) begin
            C1_read_ready <= 1'b1;
            if (dout_valid_sh_internal) begin
                state_hr <= s_save_K;
                h_addr_1 <= h_addr_1 + 1;
            end
        end
        
        else if (state_hr == s_save_K) begin
           if (h_addr_1 == 8) begin
                h_addr_1 <= 0;
                state_hr <= s_done;
                done_r <= 1'b1;
           end
           else begin
               if (dout_valid_sh_internal) begin
                    h_addr_1 <= h_addr_1 + 1;
               end
           end
        end
        
        else if (state_hr == s_done) begin
            if (seed_valid) begin
                state_hr <= s_first_block;
            end
            C1_read_ready <= 1'b0;
            done_r <= 1'b0;
        end
          
     end

end 
 
 
always@(state_hr or done_error or h_addr_1 or done_encrypt or addr_rd_c or dout_valid_sh_internal) 
begin
    case (state_hr)
     s_first_block: begin
                      dont_capture_C0 <= 1'b0;
                      sel_hram <= 3'b001;
                      reg_en_er <= 1'b1;
                      h_wren_1 <=  1'b1;
                      start_hash <= 1'b0;
                      rd_en_c <= 1'b0;
                      sel_ec <= 2'b00;
                      first_C0 <= 1'b0;
                      first_C1 <= 1'b0;
                      last_C1 <= 1'b0;
                      dont_capture_shake <= 1'b0;
                      total_contents <= 0;
                      wr_en_C1 <= 1'b0;
                      sel_k <= 1'b0;
                    end 
     
     s_second_block: begin
                       dont_capture_C0 <= 1'b0;
                       sel_hram <= 3'b010;
                       reg_en_er <= 1'b1;
                       h_wren_1 <=  1'b1;
                       rd_en_c <= 1'b0;
                       sel_ec <= 2'b00;
                       first_C0 <= 1'b0;
                       first_C1 <= 1'b0;
                       last_C1 <= 1'b0;
                       wr_en_C1 <= 1'b0;
                       sel_k <= 1'b0;
                     end
     
     s_wait_for_error_done: begin
                            rd_en_c <= 1'b0;
                            h_wren_1 <=  1'b0;
                            reg_en_er <= 1'b1;
                              if (done_error) begin
                                rd_e_1 <= 1'b1;
                              end
                            end
                
     s_stall_for_ram: begin
                        rd_en_c <= 1'b0;
                        reg_en_er <= 1'b1;
                        sel_hram <= 3'b011;
                        h_wren_1 <=  1'b1;
                      end
                      
     s_load_data_to_ram: begin
                          rd_e_1 <= 1'b1;
                          reg_en_er <= 1'b1;
                          rd_en_c <= 1'b0;
                          
                          
                          if (h_addr_1 <E_HASH_DEPTH) begin
                            h_wren_1 <=  1'b1;
                          end
                          else begin
                            h_wren_1 <=  1'b0;
                            start_hash <= 1'b1;
                            total_contents <= E_HASH_DEPTH;
                          end
                          
                          if (h_addr_1 == E_HASH_DEPTH-1) begin
                            if (n%32 == 16) begin
                                sel_hram <= 3'b111;
                            end
                            else begin
                                sel_hram <= 3'b101;
                            end 
                          end
                          else begin
                            sel_hram <= 3'b000;
                          end
                         
                         end
      
      s_load_domain_seperator: begin
                               rd_en_c <= 1'b0;
                               h_wren_1 <=  1'b1;
                               reg_en_er <= 1'b0;
                               rd_e_1 <= 1'b1;
                                if (h_addr_1 > (E_HASH_DEPTH - E_HASH_DEPTH%34)) begin
                                    sel_hram <= 3'b100;
                                end
                                else begin  
                                    sel_hram <= 3'b010;
                                end
                                end 
       
      s_done_loading: begin
                          rd_e_1 <= 1'b0;
                          h_wren_1 <=  1'b0;
                          start_hash <= 1'b0;
                          
                          
                           
                         end
      
      s_update_01: begin
                        h_wren_1 <=  1'b1;
                        sel_ec <= 2'b01;
                   end
      
      s_update_e_domain: begin
                            h_wren_1 <=  1'b1;
                            sel_ec <= 2'b00;
                            sel_hram <= 3'b010;
                         end
                         
      s_wait_encrypt_done: begin
                           dont_capture_C0 <= 1'b0;
                           h_wren_1 <=  1'b0;
                              if (done_encrypt) begin
                                    rd_en_c <= 1'b1;
                              end
                              else begin
                                    rd_en_c <= 1'b0;
                              end 
                          end
                                                
      s_load_enc_to_ram: begin
                            dont_capture_C0 <= 1'b0;
                            rd_en_c <= 1'b1;
                            sel_ec <= 2'b10;
                            if (addr_rd_c == 1) begin
                                first_C0 <= 1'b1;
                            end
                            else begin
                                first_C0 <= 1'b0;
                            end 
                            
                            if (addr_rd_c > 0) begin
                                h_wren_1 <=  1'b1;
                            end                   
                            else begin
                                h_wren_1 <=  1'b0;
                            end               
                         end
      
    s_load_domain_sep_3: begin
                         sel_ec <= 2'b00;
                         if (h_addr_1 >= HASH_RAM_DEPTH - 34) begin 
                            sel_hram <= 3'b110;
                         end
                         else begin
                            sel_hram <= 3'b010;
                         end
                         h_wren_1 <= 1'b1;
                         dont_capture_C0 <= 1'b1;
                       end 
       
      s_load_last_C0: begin
                        dont_capture_C0 <= 1'b0;
                        h_wren_1 <=  1'b1;
                        sel_ec <= 2'b10;
                      end
                      
      s_first_load_C1: begin
                    first_C1 <= 1'b1;
                    h_wren_1 <=  1'b1;
                    sel_ec <= 2'b11;
                    wr_en_C1 <= 1'b1;
                 end
      
      s_load_C1: begin
                     dont_capture_shake <= 1'b0;
                     first_C1 <= 1'b0;
                     sel_ec <= 2'b11;
                     if (dout_valid_sh_internal) begin
                        h_wren_1 <= 1'b1;
                        wr_en_C1 <= 1'b1;
                     end
                     else begin
                        h_wren_1 <= 1'b0;
                        wr_en_C1 <= 1'b0;
                     end
                 end                
      
      s_load_domain_sep_2: begin
                                sel_ec <= 2'b00;
                                sel_hram <= 3'b110;
                                h_wren_1 <= 1'b1;
                                dont_capture_shake <= 1'b1;
                                wr_en_C1 <= 1'b0; 
                           end 
      
      s_load_last_C1: begin
                        h_wren_1 <= 1'b1;
                        sel_ec <= 2'b11;
                        last_C1 <= 1'b1;
                      end
      
      s_calculate_K: begin
                        h_wren_1 <= 1'b0;
                        start_hash <= 1'b1;
                        total_contents <= HASH_RAM_DEPTH;
                     end
      
      s_wait_K_done: begin
                        start_hash <= 1'b0;
                        total_contents <= HASH_RAM_DEPTH;
                        sel_k <= 1'b1;
                        if (dout_valid_sh_internal) begin
                            h_wren_1 <= 1'b1;
                            sel_ec <= 2'b01;
                        end
                        else begin
                            h_wren_1 <= 1'b0;
                        end
                     end
                     
      s_save_K: begin
                     sel_k <= 1'b1;
                     sel_ec <= 2'b01;
                     if (dout_valid_sh_internal) begin
                        h_wren_1 <= 1'b1;
                     end
                     else begin
                        h_wren_1 <= 1'b0;
                     end
                
                end
                                                       
      s_done: begin
                sel_k <= 1'b0;
                sel_ec <= 2'b00;
                rd_en_c <= 1'b0;
                h_wren_1 <=  1'b0;
                first_C1 <= 1'b0;
                last_C1 <= 1'b0;
              end
                         
      default: din_valid <= 1'b0;
      
    endcase

end  



assign e_to_ram = (sel_hram == 3'b001)? SHAKE_FIRST_IN:
                  (sel_hram == 3'b010)? SHAKE_SECOND_IN:
                  (sel_hram == 3'b011)? {rev_error_1[32-8-1:0], byte_2}: 
                  (sel_hram == 3'b100)? E_SHAKE_LAST_IN:
                  (sel_hram == 3'b101)? {24'h000000,rev_error_1_reg[31:24]}:
                  (sel_hram == 3'b110)? SHAKE_LAST_IN:
                                        {rev_error_1[23:0], rev_error_1_reg[31:24]};

                                        
assign C0_to_ram = (first_C0)? {C0[32-C0_w-1:0], q_1[C0_w-1:0]}: {C0[32-C0_w-1:0], C0_reg[31:32-C0_w]} ;


assign C1_to_ram = (first_C1)? {C1[23:0], C0_reg[C1_w_h-1:C1_w_l]}: 
                   (last_C1)?  {{24{1'b0}}, C1_reg[31:24]}:          
                               {C1[23:0], C1_reg[31:24]} ;
                                             
assign change01 = sel_k ? C1_rearrange : (q_1 & (32'hffffff00) | (32'h00000001));  

assign h_data_1 = (sel_ec == 2'b01) ? change01 : 
                  (sel_ec == 2'b10) ? C0_to_ram :
                  (sel_ec == 2'b11) ? C1_to_ram :
                                      e_to_ram;

    mem_dual #(.WIDTH(32), .DEPTH(HASH_RAM_DEPTH)) hash_mem (
    .clock(clk),
    .data_0(h_data_0),
    .data_1(h_data_1),
    .address_0(rd_K? K_addr: h_addr_0),
    .address_1(h_addr_1),
    .wren_0(0),
    .wren_1(h_wren_1),
    .q_0(q_0),
    .q_1(q_1)
  );

reg [2:0] state = 0;
parameter s_wait_error_done      =   0;
parameter s_wait_shake_ready     =   1;
parameter s_shake_fir            =   2;
parameter s_shake_sec            =   3;
parameter s_shake_proc           =   4;
parameter s_stall_0              =   5;

//Hash 1
always@(posedge clk)
begin

     if (rst) begin
        state <= s_wait_error_done;
        h_addr_0 <= 0;
     end
     
     else begin
        if (state == s_wait_error_done) begin
            if (start_hash) begin
                state <= s_wait_shake_ready;
                h_addr_0 <= 0;
            end
        end
        
        if (state == s_wait_shake_ready) begin
            if (seed_ready_internal) begin
                state <= s_shake_fir;
                h_addr_0 <= h_addr_0+1;
            end
        end
        
        if (state == s_shake_fir) begin
            state <= s_shake_sec;
            h_addr_0 <= h_addr_0+1;
        end
        
        if (state == s_shake_sec) begin
            state <= s_shake_proc;
        end
        
        if (state == s_shake_proc) begin
            if (h_addr_0  < total_contents) begin
                state <= s_stall_0;
            end
            else begin
                state <= s_wait_error_done;
            end
        end
        
        if (state == s_stall_0) begin
             if (seed_ready_internal) begin
                    h_addr_0 <= h_addr_0 + 1;
                    state <= s_shake_proc;
             end
        end
          
     end

end 
 
 
always@(state or dout_valid_sh_internal or done_error or seed_ready_internal) 
begin
    case (state)
     s_wait_error_done: begin
                            sel_in_shake <= 3'b000;
                            din_valid_h <= 1'b0;
                            h_wren_0 <= 1'b0;
                        end
                        
     s_wait_shake_ready: begin
                    din_valid_h <= 1'b0;
                    if (seed_ready_internal) begin
                        sel_in_shake <= 3'b001;
                    end 
                  end 
     
                  
     
     s_shake_sec: begin
                    sel_in_shake <= 3'b001;
                    din_valid_h <= 1'b1;
                  end
     
     s_shake_fir: begin
                    sel_in_shake <= 3'b001;
                    din_valid_h <= 1'b1;
                  end
     
                
     s_shake_proc: begin
                      sel_in_shake <= 3'b001;
                      din_valid_h <= 1'b0;
                   end
     
     s_stall_0: begin
                    sel_in_shake <= 3'b001;
                    if (seed_ready_internal) begin
                        din_valid_h <= 1'b1;
                      end
                      else begin
                        din_valid_h <= 1'b0;
                      end
                 end        
    
      default: din_valid_h <= 1'b0;
      
    endcase

end

endmodule

