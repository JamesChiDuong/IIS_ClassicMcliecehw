`timescale 1ns / 1ps
/*
 * 
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

//    parameter fblock = 32'h40000900, //    parameter tau = 128,//p1
//    parameter fblock = 32'h40000d00, //    parameter tau = 192,//p2
//    parameter fblock = 32'h40001100, //    parameter tau = 256,//p3
//    parameter fblock = 32'h40000fe0, //    parameter tau = 238,//p4
//    parameter fblock = 32'h40000900, //    parameter tau = 128,//p5

module fixed_weight_no_shake_mw
#( 

    parameter parameter_set = 4,
    
    
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
   
   
   // common parameters
    parameter q = 2**m,
    parameter tau = (n < q)? 2*t : t,
    parameter sigma1 = 16,
    parameter rb_chunks = (tau*sigma1)/32,  // division by 32 because SHAKE outputs 32 bits in one cycle
    parameter logrb = `CLOG2(rb_chunks),
    parameter logt = `CLOG2(t),
    parameter logtau = `CLOG2(tau),
    parameter E0_WIDTH = 160,
    parameter E1_WIDTH = 32,
    parameter SEED_SIZE = 512
)
(
    input clk,
    input rst,
    input seed_valid,
    input [31:0] seed,
    output done,
    output valid_vector,
    
    output [E0_WIDTH-1:0] error_0, 
    input rd_e_0, 
    input [`CLOG2((n+(E0_WIDTH - n%E0_WIDTH)%E0_WIDTH)/E0_WIDTH) - 1 : 0]rd_addr_e_0,
    
    input rd_e_1, 
    input [`CLOG2((n+(E1_WIDTH - n%E1_WIDTH)%E1_WIDTH)/E1_WIDTH) - 1 : 0]rd_addr_e_1,
    output [E1_WIDTH-1:0] error_1, 
    
    //shake signals
    output reg seed_valid_internal,
    input wire seed_ready_internal,
    output wire [31:0] din_shake,
    output reg shake_out_capture_ready,
    input wire [31:0] dout_shake_scrambled,
    output reg force_done_shake,
    input wire dout_valid_sh_internal
    
    );

reg init;     
reg wr_en_ms;   
reg [logt:0] wr_addr_ms;
wire [(m-1):0] data_in_ms;    
wire rd_en_ms;    
wire [(logt - 1):0]rd_addr_ms;   
wire [(m-1):0]data_out_ms;    
wire collision_ms;    

wire dout_valid_sh       = 1'b0;    
reg shift_shake_op       = 1'b0;    

wire bml_not; //not of beyond_max_limit

reg [2:0] state = 0;
// Below are states
parameter s_initialize             =   0;
parameter s_wait_start             =   1;
parameter s_load_shake             =   2;
parameter s_stall_1                =   3;
parameter s_wait_sort              =   4;
parameter s_wait_onegen            =   5;


reg [(logrb-1):0] count_reg = 0;
wire [31:0] dout_shake;
wire [15:0] dout_shake_h1;
wire [15:0] dout_shake_h2;
wire [15:0] dout_shake_h1_rev;
wire [15:0] dout_shake_h2_rev;
reg [(m-1):0] shake_out_capture;

// shake signals
reg [1:0] shake_input_type;
//wire [31:0] din_shake;
wire [31:0] fblock;

// onegen signals
wire ready_onegen;
wire done_onegen;
reg start_onegen;
wire [(m-1):0]location;

// signals for the seed loading  
wire [31:0]seed_in;

reg [4:0]seed_addr;
reg seed_wr_en;
wire [31:0]seed_q;
reg initial_loading;
wire [3:0]addr_for_seed;
  


assign  seed_in = (initial_loading)? seed: dout_shake_scrambled;
  
 assign addr_for_seed = (seed_wr_en)? l_seed_addr[3:0]: seed_addr[3:0]; 
// mem_single #(.WIDTH(32), .DEPTH(8) ) mem_single_seed
 mem_single #(.WIDTH(32), .DEPTH(SEED_SIZE/32) ) mem_single_seed
 (
        .clock(clk),
        .data(seed_in),
        .address(addr_for_seed),
        .wr_en(seed_wr_en),
        .q(seed_q)
 );
 

//assign fblock = (n == 3488 && t == 64  && m == 12)? 32'h40000900:
//                (n == 4608 && t == 96  && m == 13)? 32'h40000d00:
//                (n == 6688 && t == 128 && m == 13)? 32'h40001100:
//                (n == 6960 && t == 119 && m == 13)? 32'h40000fe0:
//                (n == 8192 && t == 128 && m == 13)? 32'h40000900:
//                                                    32'h00000000;
                                                    
assign fblock = (n == 3488 && t == 64  && m == 12)? 32'h40000a00:
                (n == 4608 && t == 96  && m == 13)? 32'h40000e00:
                (n == 6688 && t == 128 && m == 13)? 32'h40001200:
                (n == 6960 && t == 119 && m == 13)? 32'h400010e0:
                (n == 8192 && t == 128 && m == 13)? 32'h40000a00:
                                                    32'h00000000; 
                                                                                                      
 assign din_shake = (shake_input_type == 2'b01)? fblock: //including the generation of next seed  
                    (shake_input_type == 2'b10)? 32'h80000200: //seed length
                    seed_q;
    


assign dout_shake = {dout_shake_scrambled[7:0], dout_shake_scrambled[15:8], dout_shake_scrambled[23:16], dout_shake_scrambled[31:24]};

assign dout_shake_h1 = dout_shake[31:16];
assign dout_shake_h2 = dout_shake[15:0];

  genvar i;
  generate
    for (i = 0; i < 16; i=i+1) begin:rev_bits
        assign dout_shake_h1_rev[i] = dout_shake_h1[15-i]; 
        assign dout_shake_h2_rev[i] = dout_shake_h2[15-i]; 
    end
  endgenerate

//reg

always@(posedge clk)
begin
    if (dout_valid_sh_internal) begin
        shake_out_capture = dout_shake_h2_rev[(m-1):0];
    end
end  


assign bml_not = (data_in_ms < n)? 1'b1 : 1'b0;


assign data_in_ms = shift_shake_op? shake_out_capture: 
                                    dout_shake_h1_rev[(m-1):0];
  

 wire [logt-1 : 0]loca_addr;
 assign loca_addr = rd_en_ms ? rd_addr_ms : wr_addr_ms[(logt - 1):0];
 
 mem_single #(.WIDTH(m), .DEPTH(t) ) loca_mem
 (
        .clock(clk),
        .data(data_in_ms),
        .address(loca_addr),
        .wr_en(wr_en_ms),
        .q(data_out_ms)
 );



  assign location = data_out_ms;
 
 reg init_mem_onegen; 
  
  onegen_mw_op #(.m(m), .WIDTH(E1_WIDTH),  .DEPTH((n+(E1_WIDTH-n%E1_WIDTH)%E1_WIDTH)/E1_WIDTH), .E0_WIDTH(E0_WIDTH), .E0_DEPTH((n+(E0_WIDTH-n%E0_WIDTH)%E0_WIDTH)/E0_WIDTH), .TAU(t)) onegen_instance (
    .clk(clk),
    .rst(rst),
    .init_mem(init_mem_onegen),
    .location(location),
    .start(start_onegen),
    .rd_addr(rd_addr_ms),
    .rd_en(rd_en_ms),
    .collision(collision_ms),
    .valid(valid_vector),
    .ready(ready_onegen),
    .done(done_onegen),
    
    .error_0(error_0),
    .rd_e_0(rd_e_0), 
    .rd_addr_e_0(rd_addr_e_0),
    
    .error_1(error_1),
    .rd_e_1(rd_e_1), 
    .rd_addr_e_1(rd_addr_e_1)
    );
    
assign done = done_onegen;

//weight counter
reg weight_counter_init;
reg [logt:0] weight_count;
always@(posedge clk)
begin
    if (weight_counter_init) begin
        weight_count = 0;
    end
    else if (wr_en_ms) begin
        weight_count = weight_count + 1;
    end
end
    
always@(posedge clk)
begin
    if (rst) begin
        state <= s_initialize;
        force_done_shake <= 1'b0;
        seed_is_loaded_in_shake_off <= 1'b0;
    end
    else begin

        
        if (state == s_initialize) begin
            count_reg <= 0;
            wr_addr_ms <= 0;
            force_done_shake <= 1'b0;

            if (seed_is_loaded_in_shake) begin
                state <= s_wait_start;
                seed_is_loaded_in_shake_off <= 1'b1;
            end

        end 
        
        
        if (state == s_wait_start) begin
            
            if (dout_valid_sh_internal) begin
               state <= s_load_shake;
               count_reg <= 0;
               seed_is_loaded_in_shake_off <= 1'b1;
               if ((bml_not) && (wr_addr_ms < t)) begin
                   wr_addr_ms <= wr_addr_ms+1;
               end
               
            end
        end 
        
        else if (state == s_load_shake) begin
            seed_is_loaded_in_shake_off <= 1'b0;
            if (count_reg == rb_chunks - 1) begin
                count_reg <= 0;
                state <= s_wait_sort;

            end
            else begin
                state <= s_stall_1;
                count_reg <= count_reg + 1;
                
                if ((bml_not) && (wr_addr_ms < t)) begin
                    wr_addr_ms <= wr_addr_ms+1;
                end
                
            end
        end 
        
        else if (state == s_stall_1) begin
            if (dout_valid_sh_internal) begin
                state <= s_load_shake;
                
                if ((bml_not) && (wr_addr_ms < t)) begin
                    wr_addr_ms <= wr_addr_ms+1;
                end
                
            end 
        end

 
         else if (state == s_wait_sort) begin           
            count_reg <= 0;
            if (weight_count == t) begin // here we check for if the error weight is correct
                state <= s_wait_onegen;
                wr_addr_ms <= 0;
            end
            else begin
                state <= s_initialize;
                wr_addr_ms <= 0;
                
            end 
            
        end 
        
        else if (state == s_wait_onegen) begin
            if (collision_ms || done_onegen) begin
                state <= s_initialize;
            end
            
            if (done_onegen) begin
                force_done_shake <= 1'b1;
            end
            
        end 
        
    end 
end 

always@(state or dout_valid_sh_internal or count_reg  or done_onegen or ready_onegen or wr_addr_ms or bml_not or collision_ms or seed_valid or seed_addr or weight_count or l_seed_addr) 
begin
    case (state)
     s_initialize: begin
                    init <= 1'b1;
                   
                    wr_en_ms <= 1'b0;
                    start_onegen <= 1'b0;
                    weight_counter_init <= 1'b1;
                    
                  end 
            
      
      s_wait_start: begin
                        init <= 1'b0;
                        weight_counter_init <= 1'b0;
                        shake_out_capture_ready <= 1'b1;
                        shift_shake_op <= 1'b0;
                        if (dout_valid_sh_internal) begin
                            if ((bml_not) && (wr_addr_ms < t)) begin
                               wr_en_ms <= 1'b1;
                            end
                            else begin
                                wr_en_ms <= 1'b0;
                            end
                        end
                        else begin
                           wr_en_ms <= 1'b0; 
                        end
                    end
      s_load_shake: begin 
                        if (count_reg == rb_chunks - 1) begin
                            shift_shake_op <= 1'b1;
                        end
                        else begin
                            shake_out_capture_ready <= 1'b0;
                            shift_shake_op <= 1'b1;
                            if ((bml_not) && (wr_addr_ms < t)) begin
                                wr_en_ms <= 1'b1;
                            end
                            else begin
                                wr_en_ms <= 1'b0;
                            end
                        end
                    end
               
      s_stall_1: begin
                       shake_out_capture_ready <= 1'b1;
                       shift_shake_op <= 1'b0;
                       
                       if (dout_valid_sh_internal) begin
                           if ((bml_not) && (wr_addr_ms < t)) begin 
                                wr_en_ms <= 1'b1;
                           end
                           else begin
                                wr_en_ms <= 1'b0;
                            end
                       end
                       else begin
                           wr_en_ms <= 1'b0; 
                       end
                 end   
       
       
       s_wait_sort: begin
                        wr_en_ms <= 1'b0;
                        if (weight_count == t && ready_onegen) begin 
                            start_onegen <= 1'b1;
                            
                        end 
                    end
       
       s_wait_onegen: begin
                        
                        start_onegen <= 1'b0;
                        if (l_seed_addr == SEED_SIZE/32) begin
                            shake_out_capture_ready <= 1'b0;
                        end
                      end  
                    
      default: start_onegen <= 1'b0;
    endcase

end 

//seed loading

reg [2:0] state_loading = 0;
parameter s_wait_new_load           = 0;
parameter s_loading_seed            = 1;
parameter s_wait_for_internal_seed  = 2;
parameter s_load_seed_shake         = 3;
parameter s_stall_load              = 4;

reg seed_is_ready;
reg [4:0]l_seed_addr;

always@(posedge clk)
begin
    if (rst) begin
        state_loading <= s_wait_new_load;
        l_seed_addr <= 0;
        seed_is_ready = 1'b0;
    end
    
    else begin
        if (state_loading == s_wait_new_load) begin
            if (seed_valid) begin   
                state_loading <= s_loading_seed;   
                l_seed_addr <= l_seed_addr + 1;
            end
        end
        
        else if (state_loading == s_loading_seed) begin
             if (done_onegen) begin
                state_loading <= s_wait_new_load;
                seed_is_ready = 1'b0;
            end
            else begin 
                if (l_seed_addr == SEED_SIZE/32) begin
                    l_seed_addr <= 0;
                    state_loading <= s_wait_for_internal_seed;
                    seed_is_ready = 1'b1;
                end
                else begin
                    if (seed_valid) begin 
                        state_loading <= s_loading_seed; 
                        l_seed_addr <= l_seed_addr + 1;  
                    end
                end
            end
        end
        
        else if (state_loading == s_wait_for_internal_seed) begin
            seed_is_ready = 1'b0;
            if (done_onegen) begin
                state_loading <= s_wait_new_load;
            end 
            else if (count_reg == rb_chunks - 1) begin
                state_loading <= s_load_seed_shake;
            end      
        end

        else if (state_loading == s_load_seed_shake) begin
            if (done_onegen) begin
                state_loading <= s_wait_new_load;
                seed_is_ready = 1'b0;
            end
            else begin
                if (l_seed_addr == SEED_SIZE/32) begin
                    state_loading <= s_wait_for_internal_seed; 
                    seed_is_ready = 1'b1;
                    l_seed_addr <= 0;
                end
                else begin
                    state_loading <= s_stall_load;              
                end
            end
        end 
        
        else if (state_loading == s_stall_load) begin
            if (done_onegen) begin
                state_loading <= s_wait_new_load;
                seed_is_ready = 1'b0;
            end
            else begin
                if (dout_valid_sh_internal) begin
                    state_loading <= s_load_seed_shake; 
                    l_seed_addr <= l_seed_addr+1;   
                end 
            end    
        end
                
      end
    
end

always@(state_loading or dout_valid_sh_internal or seed_valid or seed_addr) 
begin
    case (state_loading)
     s_wait_new_load: begin 
                        
                        initial_loading <= 1'b1;
                        if  (seed_valid == 1'b1) begin
                            seed_wr_en <= 1'b1;
                            init_mem_onegen <= 1'b1;
                        end
                        else begin
                            seed_wr_en <= 1'b0;
                            init_mem_onegen <= 1'b0;
                        end
                      end
     
     s_loading_seed: begin
                        init_mem_onegen <= 1'b0;
                        if  (seed_valid == 1'b1) begin
                            seed_wr_en <= 1'b1;
                        end
                        else begin
                            seed_wr_en <= 1'b0;
                        end
                      end
     
     s_wait_for_internal_seed: begin
                                    initial_loading <= 1'b0;
                               end
     
     s_stall_load: begin
                        if  (dout_valid_sh_internal == 1'b1) begin
                            seed_wr_en <= 1'b1;
                        end
                        else begin
                            seed_wr_en <= 1'b0;
                        end
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

reg [1:0] count_steps;
reg  seed_is_loaded_in_shake;
reg  shake_result_ready;
reg  seed_is_loaded_in_shake_off;

//shake parallel processing loading
always@(posedge clk)
begin

 //================start feeding the SHAKE with seed============================
     if (rst) begin
        state_shake <= s_init_shake;
        seed_addr <= 0;
        seed_is_loaded_in_shake <= 1'b0;
        shake_result_ready <= 1'b0;
    end
    else begin
       
        if (state_shake == s_init_shake) begin
            count_steps <= 0;
            seed_addr <= 0;
            seed_is_loaded_in_shake <= 1'b0;
            if (seed_is_ready) begin
                state_shake <= s_shake_out_w;
                shake_result_ready <= 1'b0;
            end
        end 
        
        else if (state_shake == s_shake_out_w) begin
             if (done_onegen) begin
                state_shake <= s_init_shake;
                seed_is_loaded_in_shake <= 1'b0;
             end
             else begin
                if (count_steps == 1) begin
                    state_shake <= s_shake_in_w;
                    count_steps <= 0;
                end 
                else begin
                    state_shake <= s_shake_out_w;
                    count_steps <= count_steps + 1;
                end
             end
        end
        
        else if (state_shake == s_shake_in_w) begin
            if (done_onegen) begin
                state_shake <= s_init_shake;
                seed_is_loaded_in_shake <= 1'b0;
            end
             else begin
                if (count_steps == 1) begin
                    state_shake <= s_load_new_seed;
                    count_steps <= 0;
                end 
                else begin
                    state_shake <= s_shake_in_w;
                    count_steps <= count_steps + 1;
                end
             end
        end
        
        else if (state_shake == s_load_new_seed) begin
            if (done_onegen) begin
                state_shake <= s_init_shake;
                seed_is_loaded_in_shake <= 1'b0;
            end
            else begin
                if (seed_addr == SEED_SIZE/32) begin
                    state_shake <= s_wait_for_shake_out_ready;
                    seed_addr <= 0;
                    seed_is_loaded_in_shake <= 1'b1;
                end 
                else begin
                    state_shake <= s_stall_0;
                    seed_addr <= seed_addr + 1;
                end
            end
        end
        
        else if (state_shake == s_stall_0) begin
              if (done_onegen) begin
                state_shake <= s_init_shake;
                seed_is_loaded_in_shake <= 1'b0;
              end
              else begin
                state_shake <= s_load_new_seed;
              end
        end
       
       else if (state_shake == s_wait_for_shake_out_ready) begin
            if (done_onegen) begin
                seed_is_loaded_in_shake <= 1'b0;
                state_shake <= s_init_shake;
            end
            else if (dout_valid_sh_internal) begin
                shake_result_ready <= 1'b1;
                
                if (seed_is_loaded_in_shake_off) begin
                    seed_is_loaded_in_shake <= 1'b0;
                    state_shake <= s_init_shake;
                end
            end 
       end
 //================end feeding the SHAKE with seed============================
 
    end 
end 
 
 
always@(state_shake or count_steps or seed_addr or dout_valid_sh_internal) 
begin
    case (state_shake)
     s_init_shake: begin
                    seed_valid_internal <= 1'b0; 
                    shake_input_type <= 2'b00;
                    
                  end 
            
     s_shake_out_w: begin
                       if (count_steps == 0) begin
                           shake_input_type <= 2'b01;
                           seed_valid_internal <= 1'b1;
                       end 
                       else begin
                           seed_valid_internal <= 1'b0; 
                       end 
                    end
     
     
     s_shake_in_w: begin
                       if (count_steps == 0) begin
                           shake_input_type <= 2'b10;
                           seed_valid_internal <= 1'b1;
                       end 
                       else begin
                           seed_valid_internal <= 1'b0; 
                       end 
                    end

      s_load_new_seed: begin
                            shake_input_type <= 2'b00;
                            if (seed_addr < SEED_SIZE/32) begin
                                seed_valid_internal <= 1'b1;
                            end
                            else begin
                                seed_valid_internal <= 1'b0;
                            end
                       end
                       
      s_stall_0: begin
                            seed_valid_internal <= 1'b0;
                       end 
      default: seed_valid_internal <= 1'b0;
      
    endcase

end  
    
endmodule
