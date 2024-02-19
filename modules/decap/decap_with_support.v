`timescale 1ns / 1ps
/*
 * This is decapsulation with support generation without addtive fft 
 * Needs decap_with_support.v to perform decapsulation with support generation operation
 *
 * Copyright (C) 2021
 * Author: Sanjay Deshpande <sanjay.deshpande@yale.edu>
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


module decap_with_support
#( 

    parameter parameter_set = 1,
    
    
    parameter N = (parameter_set == 1)? 3488:
                  (parameter_set == 2)? 4608:
                  (parameter_set == 3)? 6688:
                  (parameter_set == 4)? 6960: 
                                        8192,
                                         
    parameter M = (parameter_set == 1)? 12:13,    
    
    parameter T = (parameter_set == 1)? 64:
                  (parameter_set == 2)? 96:
                  (parameter_set == 3)? 128:
                  (parameter_set == 4)? 119: 
                                        128,    
   
   
   // common parameters
    parameter K = N-M*T,
    parameter L = M*T,
    parameter Q = 2**M,
    parameter SIGMA1 = 16,
    parameter SIGMA2 = 32,
    
    parameter N_H = T, // N in H elimination
    parameter BLOCK_H = 32, // BLOCK in H elimination
    parameter N_R = 2, // N in R elimination
    parameter BLOCK_R = 1, // BLOCK in R elimination

    
    parameter MEM_WIDTH = 32,
   
    parameter K_H_elim = N_H*((K+N_H-1)/N_H),
    parameter K_R_elim = N_R*((T+1+N_R-1)/N_R),

`ifdef SHARED
    // ADD FFT parameters
    parameter fft_mem_width = (parameter_set == 1 || parameter_set == 3 || parameter_set == 5 )? 16: 32, // memory width in add_FFT (mem_A/B)
    parameter mul_sec_BM = 20, // number of multipliers inside vec_mul_multi in BM module
    parameter mul_sec_BM_step = 20, // number of multipliers inside vec_mul_multi in BM module

    parameter eva_mem_WIDTH = 2*M*fft_mem_width, //memory width in the add_FFT module, sum of mem_A and mem_B
    parameter eva_mem_WIDTH_bits = `CLOG2(fft_mem_width)+1,
    parameter eva_mem_DEPTH = (1 << (`CLOG2(T))), //memory depth in the add_FFT module
    parameter eva_mem_DEPTH_bits = `CLOG2(T),
`endif

    parameter SEED_SIZE = 256,
    parameter SEED_RAM_DEPTH = (SEED_SIZE +(32-SEED_SIZE%32)%32)/32,
    parameter fblock = (N == 3488 && T == 64  && M == 12)? 32'h40020DA0:   
                       (N == 4608 && T == 96  && M == 13)? 32'h40041200:
                       (N == 6688 && T == 128 && M == 13)? 32'h40041A20:
//                       (N == 6960 && T == 119 && M == 13)? 32'h40041B30:
                       (N == 6960 && T == 119 && M == 13)? 32'h40041B40:
                       (N == 8192 && T == 128 && M == 13)? 32'h40042000:
                                                           32'hFFFFFFFF //invalid mode
)
(
    input 						   clk,
    input 						   rst,
    input 						   delta_valid,
    input [31:0] 				   delta,
    output reg 					   done,
    output reg 					   support_gen_done,
    
    
    //shake interface ports
    output 						   shake_din_valid_d,
    input 						   shake_din_ready_d,
    output [31:0] 				   shake_din_d,
    output 						   shake_dout_ready_d,
    input [31:0] 				   shake_dout_scrambled_d,
    output 						   shake_force_done_d,
    input 						   shake_dout_valid_d, 
        
    input 						   start_decap,
    output 						   done_decap,
    
    input 						   C0_valid,
    input [31:0] 				   C0_in,
    output 						   C0_ready,
    
    input 						   C1_valid, 
    input [31:0] 				   C1_in,
    output 						   C1_ready,
    
    input 						   poly_g_valid, 
    input [31:0] 				   poly_g_in,
    output 						   poly_g_ready, 
                
`ifdef SHARED
	output reg 					   host_alpha_rand_wr_en, 
	output [M-1:0] 				   host_alpha_rand_wr_addr,
	output [SIGMA2-1:0] 		   host_alpha_rand_data_in,
	output reg 					   start_fo,
	input 						   done_fo,
	input 						   field_ordering_fail,
	output 						   P_rd_en,
	output [M-1:0] 				   P_rd_addr,
	input [M-1:0] 				   P_dout,
//	input  [SIGMA2-1:0]       	perm_rand_out,
	
    //shared ADD FFT ports 
	output wire 				   fft_eva_start_dec,
	output wire [M*(T+1)-1:0] 	   fft_coeff_in_dec,
	output wire 				   fft_rd_en_dec,
	output wire [`CLOG2(T+1)-1:0]  fft_rd_addr_dec,
	input wire [eva_mem_WIDTH-1:0] fft_eva_dout_dec,
	input wire 					   fft_eva_done_dec,
`endif

	input 						   rd_K,
	input [2:0] 				   K_addr, 
	output [31:0] 				   K_out
    );

reg [2:0] state = 0;
// Below are states
parameter s_initialize             =   0;
parameter s_wait_start             =   1;
parameter s_fill_s_mem             =   2;
parameter s_fill_alpha             =   3;
//parameter s_fill_alpha_last        =   4;
parameter s_start_fo               =   4;
parameter s_wait_done_fo           =   5; //also start decap start
parameter s_wait_done_decap        =   6;



// shake signals
reg [2:0] shake_input_type = 0;
wire [31:0] din_shake;

// signals for the seed loading  
wire [31:0]seed_in;
reg [3:0]seed_addr = 0;
reg seed_is_ready = 0;
reg [3:0]l_seed_addr = 0;
reg seed_wr_en = 0;
wire [31:0]seed_q;
reg initial_loading = 0;
wire [3:0]addr_for_seed;
reg shake_dout_ready_kg_nab = 0, shake_dout_ready_kg_deltap = 0;

//s ports
parameter S_RAM_DEPTH = (N+(32-N%32)%32)/32;
wire [`CLOG2(S_RAM_DEPTH):0] s_addr;
reg  [`CLOG2(S_RAM_DEPTH):0] s_wr_addr = 0;
wire [31:0] s_data_in;
reg s_wr_en = 0;

// alpha generation signals
parameter ALPHA_BITS = SIGMA2*Q;
parameter RAND_ALPHA_MAX = (ALPHA_BITS + (32-ALPHA_BITS%32)%32)/32;
reg [M:0] host_alpha_rand_wr_addr_reg = 0;
`ifndef SHARED
reg host_alpha_rand_wr_en = 0;
wire [SIGMA2-1:0] host_alpha_rand_data_in;
`endif
   
// irreducible poly generation signals
parameter IRR_POLY_BITS = SIGMA1*T;
parameter IRR_POLY_MAX = (IRR_POLY_BITS + (16-IRR_POLY_BITS%16)%16)/16;
reg host_beta_rand_wr_en = 0;
reg [`CLOG2(T):0]  host_beta_rand_wr_addr = 0;
reg [`CLOG2(T):0]  beta_counter = 0;
wire [SIGMA1-1:0]  host_beta_rand_data_in; 
wire [SIGMA1-1:0]msb_shake_out;
reg [SIGMA1-1:0]lsb_shake_out  = 0;
reg poly_lsb = 0;
reg shake_dout_valid_kg_reg = 0;
reg beta_load_done = 0;

//KEYGEN signal
reg [31:0] seed_q_reg = 0;
wire [31:0] shake_dout_rearranged;  
reg [31:0] shake_dout_rearranged_reg = 0;
wire [31:0] shake_dout_adjusted;  
wire done_kg;
reg start_kg = 0;

wire [31:0]delta_bytes; 
wire pk_gen_fail;
reg [1:0] request = 0;

`ifndef SHARED
//Field Ordering
reg start_fo = 0;
wire done_fo;
wire [M-1:0] P_dout;                        
wire         P_rd_en;                         
wire [M-1:0] P_rd_addr;
`endif

//SHAKE interface Decap
reg          sel_decap = 0;

wire         shake_din_valid_dec; 
wire         shake_din_ready_dec; 
wire [31:0]  shake_din_dec;       
wire         shake_dout_ready_dec;
wire         shake_force_done_dec;
wire         shake_dout_valid_dec;

//SHAKE interface Secret Key support gen
reg         shake_din_valid_kg = 0;
wire        shake_din_ready_kg; 
wire [31:0] shake_din_kg;       
wire        shake_dout_ready_kg;
reg         shake_force_done_kg = 0;
wire        shake_dout_valid_kg;


`ifdef SHARED
assign host_alpha_rand_wr_addr = host_alpha_rand_wr_addr_reg[M-1:0];
`endif
assign shake_din_valid_d = sel_decap ? shake_din_valid_dec : shake_din_valid_kg;
assign shake_din_d = sel_decap ? shake_din_dec: shake_din_kg;
assign shake_dout_ready_d = sel_decap ? shake_dout_ready_dec : shake_dout_ready_kg;
assign shake_force_done_d = 1'b0;

assign shake_din_ready_kg   = sel_decap? 1'b0: shake_din_ready_d;
assign shake_din_ready_dec  = sel_decap?  shake_din_ready_d : 1'b0;
assign shake_dout_valid_kg  = sel_decap? 1'b0: shake_dout_valid_d;
assign shake_dout_valid_dec = sel_decap? shake_dout_valid_d : 1'b0;

assign shake_din_kg = din_shake;
assign  seed_in = (initial_loading)? delta: shake_dout_rearranged; 
assign addr_for_seed = (seed_wr_en)? l_seed_addr[3:0]: seed_addr[3:0]; 

genvar j;
generate
            for (j=0; j<8; j =j+1) begin 
                assign delta_bytes[j] = seed_in[7-j]; 
                assign delta_bytes[8+j] = seed_in[15-j]; 
                assign delta_bytes[16+j] = seed_in[23-j]; 
                assign delta_bytes[24+j] = seed_in[31-j]; 
            end    
endgenerate


 mem_single #(.WIDTH(32), .DEPTH(SEED_RAM_DEPTH) ) mem_single_seed
 (
        .clock(clk),
        .data({delta_bytes[7:0],delta_bytes[15:8],delta_bytes[23:16],delta_bytes[31:24]}),
        .address(addr_for_seed),
        .wr_en(seed_wr_en),
        .q(seed_q)
 );
 
 
 assign shake_dout_ready_kg = shake_dout_ready_kg_nab |  shake_dout_ready_kg_deltap; //nab = N value, alpha, beta
                                                                                                      
 assign din_shake = (shake_input_type == 2'b001)? fblock: //including the generation of next seed  
                    (shake_input_type == 2'b010)? 32'h80000108: //seed length
                    (shake_input_type == 2'b011)? {seed_q[23:0],8'h40}: // appending 0x40 in the MSB of the delta value
                    (shake_input_type == 2'b000)? {seed_q[23:0], seed_q_reg[31:24]}:
                                                  {24'h000000, seed_q_reg[31:24]}; 
 
 always@(posedge clk)
 begin
    seed_q_reg <= seed_q;
 end 
 
 
 rearrange_vector SHAKE_dout_rearrange(.vector_in(shake_dout_scrambled_d),.vector_out(shake_dout_rearranged));
 
 always@(posedge clk)
 begin
    if (shake_dout_valid_kg) begin
        shake_dout_rearranged_reg <= shake_dout_rearranged;
    end
 end
 assign shake_dout_adjusted = (N%32 == 0)? shake_dout_rearranged: {shake_dout_rearranged_reg[15:0],shake_dout_rearranged[31:16]};
 
 //alpha rand in
 wire [SIGMA2-1:0] host_alpha_rand_data_in_rev;

 assign host_alpha_rand_data_in_rev = shake_dout_adjusted;
genvar i;
generate
            for (i=0; i<SIGMA2; i =i+1) begin 
                assign host_alpha_rand_data_in[i] = host_alpha_rand_data_in_rev[SIGMA2-i-1];
            end    
endgenerate


    
// Support distribution control logic    
always@(posedge clk)
begin
    if (rst) begin
        state <= s_initialize;
        shake_force_done_kg <= 1'b0;
        seed_is_loaded_in_shake_off <= 1'b0;
        s_wr_addr <= 0;
        host_alpha_rand_wr_addr_reg <= 0;
        host_beta_rand_wr_addr <= IRR_POLY_MAX - 1;
        done <= 1'b0;
        support_gen_done <= 1'b0;        
    end
    
    else begin     
        if (state == s_initialize) begin
            done <= 1'b0;
            s_wr_addr <= 0;
            host_alpha_rand_wr_addr_reg <= 0;
            host_beta_rand_wr_addr <= IRR_POLY_MAX - 1;
            shake_force_done_kg <= 1'b0;
            support_gen_done <= 1'b0;
            if (seed_is_loaded_in_shake) begin
                state <= s_wait_start;
                seed_is_loaded_in_shake_off <= 1'b1;
            end
        end       
        
        else if (state == s_wait_start) begin        
            if (shake_dout_valid_kg) begin
               state <= s_fill_s_mem;
               seed_is_loaded_in_shake_off <= 1'b1;
               s_wr_addr <= s_wr_addr+1;
            end
        end 
        
        else if (state == s_fill_s_mem) begin
            seed_is_loaded_in_shake_off <= 1'b0;
            if (s_wr_addr <= S_RAM_DEPTH - 1) begin
                if (shake_dout_valid_kg) begin
                    s_wr_addr <= s_wr_addr + 1;
                    state <= s_fill_s_mem;
                end
            end
            else begin
                state <= s_fill_alpha;
                s_wr_addr <= 0;
            end
       end
       
       else if (state == s_fill_alpha) begin
           seed_is_loaded_in_shake_off <= 1'b0;
           if (host_alpha_rand_wr_addr_reg <= RAND_ALPHA_MAX - 1) begin
                if (shake_dout_valid_kg) begin
                    host_alpha_rand_wr_addr_reg <= host_alpha_rand_wr_addr_reg + 1;
                    state <= s_fill_alpha;
                end
            end
            
            else begin
                state <= s_start_fo;
                host_alpha_rand_wr_addr_reg <= 0;
            
            end       
       end
       
     
            
       else if (state == s_start_fo) begin
            state <= s_wait_done_fo;
            done <= 1'b1;
            support_gen_done <= 1'b0;
       end
       
       else if (state == s_wait_done_fo) begin
            if (done_fo) begin
                support_gen_done <= 1'b1;          
            end
            // /*Adjust the FSM by James Ngo*/
            // if(done_decap)
            // begin
            //     state <= s_wait_done_decap;
            // end
       end
       
       else if (state == s_wait_done_decap) begin
            if (done_decap) begin
                state <= s_initialize;
            end
            // state <= s_initialize;
       end
                      
        
    end 
    shake_dout_valid_kg_reg <= shake_dout_valid_kg;
end 

always@(state or shake_dout_valid_kg or shake_dout_valid_kg_reg  or delta_valid or seed_addr or s_wr_addr or done_fo or host_beta_rand_wr_addr, beta_counter) 
begin
    case (state)
     s_initialize: begin
                    s_wr_en <= 1'b0;
                    host_alpha_rand_wr_en <= 1'b0;
//                    host_beta_rand_wr_en <= 1'b0;
                    poly_lsb <= 1'b0;
                     start_kg <= 1'b0;
                     request <= 2'b11;
                     start_fo <= 1'b0;
                     sel_decap <= 1'b0;
                  end 
            
      
      s_wait_start: begin
                        sel_decap <= 1'b0;
                        shake_dout_ready_kg_nab <= 1'b1;
                        if (shake_dout_valid_kg) begin
                            s_wr_en <= 1'b1;
                        end
                       
                    end
      s_fill_s_mem: begin 
                        shake_dout_ready_kg_nab <= 1'b1;
                        if (shake_dout_valid_kg) begin
                            s_wr_en <= 1'b1;
                        end
                        else begin
                            s_wr_en <= 1'b0;
                        end
                        
                    end
      
      s_fill_alpha: begin 
                        shake_dout_ready_kg_nab <= 1'b1;          
                        if (shake_dout_valid_kg) begin
                            host_alpha_rand_wr_en <= 1'b1;
                        end
                        else begin
                            host_alpha_rand_wr_en <= 1'b0;
                        end
                    end
       

       
       s_start_fo: begin
                        start_fo <= 1'b1;
                        s_wr_en <= 1'b0;
                        shake_dout_ready_kg_nab <= 1'b0;
                        host_alpha_rand_wr_en <= 1'b0;
                    end
       
       s_wait_done_fo: begin
                        start_fo <= 1'b0;
                            if (done_fo) begin
                                sel_decap <= 1'b1;
                            end
                        end
       s_wait_done_decap : begin
                    sel_decap <= 1'b0;
                    start_fo <= 1'b0;
                    s_wr_en <= 1'b0;
                    shake_dout_ready_kg_nab <= 1'b0;
                    host_beta_rand_wr_en <= 1'b0;
                end
      default: begin
                    start_fo <= 1'b0;
                    s_wr_en <= 1'b0;
                    host_alpha_rand_wr_en <= 1'b0;
               end
    endcase

end 

//seed loading

reg [2:0] state_loading = 0;
parameter s_wait_new_load           = 0;
parameter s_loading_seed            = 1;
parameter s_wait_for_internal_seed  = 2;
parameter s_load_seed_shake         = 3;
parameter s_stall_load              = 4;
parameter s_wait_decap                = 5;



always@(posedge clk)
begin
    if (rst) begin
        state_loading <= s_wait_new_load;
        l_seed_addr <= 0;
        seed_is_ready <= 1'b0;
        shake_dout_ready_kg_deltap <= 1'b0;
    end
    
    else begin
        if (state_loading == s_wait_new_load) begin
            shake_dout_ready_kg_deltap <= 1'b0;
            if (delta_valid) begin   
                state_loading <= s_loading_seed;   
                l_seed_addr <= l_seed_addr + 1;
            end
        end
        
        else if (state_loading == s_loading_seed) begin
            if (l_seed_addr == SEED_RAM_DEPTH) begin
                l_seed_addr <= 0;
                state_loading <= s_wait_for_internal_seed;
                seed_is_ready <= 1'b1;
            end
            else begin
                if (delta_valid) begin 
                    state_loading <= s_loading_seed; 
                    l_seed_addr <= l_seed_addr + 1;  
                end
            end
        end
        

        
        else if (state_loading == s_wait_decap) begin
            if (done_decap)  begin
                state_loading <= s_wait_new_load;
            end
        end        
      end
    
end

always@(state_loading or shake_dout_valid_kg or delta_valid or seed_addr) 
begin
    case (state_loading)
     s_wait_new_load: begin 
                        
                        initial_loading <= 1'b1;
                        if  (delta_valid == 1'b1) begin
                            seed_wr_en <= 1'b1;
                        end
                        else begin
                            seed_wr_en <= 1'b0;
                        end
                      end
     
     s_loading_seed: begin
                        if  (delta_valid == 1'b1) begin
                            seed_wr_en <= 1'b1;
                        end
                        else begin
                            seed_wr_en <= 1'b0;
                        end
                      end
     

                       
      s_wait_decap: begin
                 end
                  
      default: seed_wr_en <= 1'b0;
    endcase

end 


reg [2:0] state_shake = 0;
parameter s_init_shake                  =   0;
parameter s_wait_for_shake_out_ready    =   1;
parameter s_shake_out_w                 =   2;
parameter s_shake_in_w                  =   3;
parameter s_load_new_seed               =   4;
parameter s_stall_0                     =   5;
parameter s_append_40                   =   6;
parameter s_last_delta                  =   7;

reg [1:0] count_steps = 0;
reg  seed_is_loaded_in_shake = 0;
reg  seed_is_loaded_in_shake_off = 0;

//shake parallel processing loading
always@(posedge clk)
begin

     if (rst) begin
        state_shake <= s_init_shake;
        seed_addr <= 0;
        seed_is_loaded_in_shake <= 1'b0;
    end
    else begin
       
        if (state_shake == s_init_shake) begin
            count_steps <= 0;
            seed_addr <= 0;
            seed_is_loaded_in_shake <= 1'b0;
            if (seed_is_ready && shake_din_ready_kg) begin
                state_shake <= s_shake_out_w;
            end
        end 
        
        else if (state_shake == s_shake_out_w) begin
                if (count_steps == 1) begin
                    state_shake <= s_shake_in_w;
                    count_steps <= 0;
                end 
                else begin
                    state_shake <= s_shake_out_w;
                    count_steps <= count_steps + 1;
                end
        end
        
        else if (state_shake == s_shake_in_w) begin

                if (count_steps == 1) begin
                    state_shake <= s_append_40;
                    count_steps <= 0;
                end 
                else begin
                    state_shake <= s_shake_in_w;
                    count_steps <= count_steps + 1;
                end
        end
       
       
        else if (state_shake == s_append_40) begin
                state_shake <= s_stall_0;
                seed_addr <= seed_addr + 1;
        end
        
        else if (state_shake == s_load_new_seed) begin

                if (seed_addr == SEED_RAM_DEPTH) begin
                    state_shake <= s_last_delta;
                    seed_addr <= seed_addr + 1;
                    seed_is_loaded_in_shake <= 1'b0;
                end 
                else begin
                    state_shake <= s_stall_0;
                    seed_addr <= seed_addr + 1;
                end
        end
        
        else if (state_shake == s_stall_0) begin
              if (seed_addr == SEED_RAM_DEPTH) begin
                    state_shake <= s_last_delta;
                    seed_is_loaded_in_shake <= 1'b0;
              end 
              else
                state_shake <= s_load_new_seed;
              end
        
        else if (state_shake == s_last_delta) begin

                state_shake <= s_wait_for_shake_out_ready;
                seed_addr <= 0;
                seed_is_loaded_in_shake <= 1'b1;
        end
       
       else if (state_shake == s_wait_for_shake_out_ready) begin
            if (done_decap) begin          
                state_shake <= s_init_shake;
            end 
       end
 
    end 
end 
 
 
always@(state_shake or count_steps or seed_addr or shake_dout_valid_kg) 
begin
    case (state_shake)
     s_init_shake: begin
                    shake_din_valid_kg <= 1'b0; 
                    shake_input_type <= 3'b000;
                    
                  end 
            
     s_shake_out_w: begin
                       if (count_steps == 0) begin
                           shake_input_type <= 3'b001;
                           shake_din_valid_kg <= 1'b1;
                       end 
                       else begin
                           shake_din_valid_kg <= 1'b0; 
                       end 
                    end
     
     
     s_shake_in_w: begin
                       if (count_steps == 0) begin
                           shake_input_type <= 3'b010;
                           shake_din_valid_kg <= 1'b1;
                       end 
                       else begin
                           shake_din_valid_kg <= 1'b0; 
                       end 
                    end
      
      s_append_40: begin
                            shake_input_type <= 3'b011;
                            if (seed_addr < SEED_RAM_DEPTH) begin
                                shake_din_valid_kg <= 1'b1;
                            end
                            else begin
                                shake_din_valid_kg <= 1'b0;
                            end
                       end
                       
      s_load_new_seed: begin
                            shake_input_type <= 3'b000;
                            if (seed_addr < SEED_RAM_DEPTH) begin
                                shake_din_valid_kg <= 1'b1;
                            end
                            else begin
                                shake_din_valid_kg <= 1'b0;
                            end
                       end
       
       s_last_delta: begin
                            shake_input_type <= 3'b111;
                            shake_din_valid_kg <= 1'b1;
                            
                       end
      
      s_wait_for_shake_out_ready: begin
                            shake_din_valid_kg <= 1'b0;
                       end 
                      
      s_stall_0: begin
                            shake_din_valid_kg <= 1'b0;
                       end 
      default: shake_din_valid_kg <= 1'b0;
      
    endcase

end  


`ifndef SHARED
   field_ordering #(.M(M), .SIGMA2(SIGMA2)) FIELDORDERING (
    .clk(clk),
    .wr_en(host_alpha_rand_wr_en),  
    .wr_addr(host_alpha_rand_wr_addr_reg[M-1:0]),
    .rand_in(host_alpha_rand_data_in),
    .start(start_fo),
    .done(done_fo),
    .index_out(P_dout),
    .rd_en(P_rd_en),
    .rd_addr(P_rd_addr)
//    .rand_dout(P_dout)
  );
`endif
 
  //s memory
 assign s_addr = s_wr_addr;
 assign s_data_in = ((N%32 != 0) && (s_addr == S_RAM_DEPTH-1))? {shake_dout_rearranged[31:N%32], 16'h0000}: shake_dout_rearranged;
   
   
   
  decap # (.parameter_set(parameter_set), .m(M), .t(T), .n(N))
 DECAPSULATION  (
    .clk(clk),
    .rst(rst),
    
    .done(done_decap),
    
    .start (start_decap),
    
    .s_wr_en(s_wr_en),
    .s_in(s_data_in),
    .s_addr(s_addr),

    .C0_valid(C0_valid),
    .C0_in(C0_in),
    .C0_ready(C0_ready),
    
    .C1_valid(C1_valid),
    .C1_in(C1_in),
    .C1_ready(C1_ready),
    
    .poly_g_valid(poly_g_valid),
    .poly_g_in(poly_g_in),
    .poly_g_ready(poly_g_ready),
    
    .P_dout(P_dout),
    .P_rd_en(P_rd_en),
    .P_rd_addr(P_rd_addr),
    
    .rd_K(rd_K),
    .K_addr(K_addr),
    .K_out(K_out),

`ifdef SHARED
	//shared fft signals
	.fft_eva_start_dec(fft_eva_start_dec),
	.fft_coeff_in_dec(fft_coeff_in_dec),
	.fft_rd_en_dec(fft_rd_en_dec),
	.fft_rd_addr_dec(fft_rd_addr_dec),
	.fft_eva_dout_dec(fft_eva_dout_dec),
	.fft_eva_done_dec(fft_eva_done_dec),
`endif

    //shake interface
    .din_valid_shake_dec(shake_din_valid_dec),
    .din_ready_shake(shake_din_ready_dec),
    .din_shake_dec(shake_din_dec),
    .dout_valid_shake(shake_dout_valid_dec),
    .dout_ready_shake_dec(shake_dout_ready_dec),
    .dout_shake(shake_dout_scrambled_d)
    );

endmodule
