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


module onegen_mw_op
    #(
//    parameter m = 12,
//    parameter WIDTH = 32,
//    parameter TAU   = 128,
//    parameter DEPTH = 128,
//    parameter FILE = "",
//    parameter LOGW = `CLOG2(DEPTH)
    
    parameter m = 13,
    
    parameter E0_WIDTH = 32,
    parameter E0_DEPTH = 4608/32,
    parameter LOGE0W = `CLOG2(E0_DEPTH),
    parameter E0_FILE = "",
    
    parameter WIDTH = 32,
    parameter DEPTH = 4608/32,
    parameter LOGW = `CLOG2(DEPTH),
    parameter FILE = "",
    
    parameter TAU   = 96,
    parameter LOGTAU   = `CLOG2(TAU)
    
    )
    (
    input clk,
    input rst,
    input init_mem,
    input [(m-1):0] location,
    
    output reg [LOGTAU-1:0] rd_addr,
    output reg rd_en,
    input start,
    output collision,
    output ready,
    output valid,
    output done,
    
    output [E0_WIDTH-1:0] error_0,
    input rd_e_0, 
    input [LOGE0W -1:0]rd_addr_e_0,
    
    output [WIDTH-1:0] error_1,
    input rd_e_1, 
    input [LOGW -1:0]rd_addr_e_1
    );
    
wire [WIDTH-1:0] gen_one;
wire [WIDTH-1:0] gen_one_reg_rev;
reg  [WIDTH-1:0] gen_one_reg;
wire [WIDTH-1:0] data_0, data_1;
reg  [LOGW -1:0] addr_0, addr_1;
wire [LOGW -1:0] decode_addr;
wire [LOGW -1:0] addr_1_mux;
wire [LOGW -1:0] addr_read;
wire [WIDTH-1:0] q_0, q_1;
reg  wren_0, wren_1;


// Second RAM signals
wire [E0_WIDTH-1:0] E0_gen_one;
wire [E0_WIDTH-1:0] E0_gen_one_reg_rev;
reg  [E0_WIDTH-1:0] E0_gen_one_reg;
wire [E0_WIDTH-1:0] E0_data_0, E0_data_1;
reg  [LOGE0W-1:0]   E0_addr_0, E0_addr_1;
wire [LOGE0W-1:0]   E0_decode_addr;
wire [LOGE0W-1:0]   E0_addr_1_mux;
wire [LOGE0W-1:0]   E0_addr_read;
wire [E0_WIDTH-1:0] E0_q_0, E0_q_1;
wire E0_wren_0, E0_wren_1;



reg ready_s;
reg valid_s;
reg done_s;
reg init;
reg reading_out;

// Below are states
parameter s_wait_for_init_mem      =   0;//
parameter s_initialize             =   1;//
parameter s_init_done              =   2;//
parameter s_wait_start             =   3;//
parameter s_load_loc               =   4;//
parameter s_wait_last_2            =   5;//
parameter s_read_out               =   6;//
parameter s_done                   =   7;//
parameter s_stall_for_ram          =   8;//
parameter s_stall_for_ram_2        =   9;//

reg [3:0] state     = 0;
reg [LOGTAU:0] count_reg;

assign ready = ready_s;
assign valid = valid_s;
assign done = done_s;



  genvar i;
  generate
    for (i = 0; i < WIDTH; i=i+1) begin:vector_gen
        assign gen_one[i] = (i == location % WIDTH) ? 1'b1 : 1'b0; 
    end
  endgenerate
  
  always@(posedge clk)
  begin
    gen_one_reg = gen_one;
  end 
  
  assign data_0 = 0;
  
  assign decode_addr = location/WIDTH;
  
  reg collision_s;
  
 //collision detection
 always@(posedge clk)
 begin
    if (init|start) begin
        collision_s = 1'b0;
    end
    else if (wren_1) begin
        if (q_0 == data_1) begin
            collision_s = 1'b1;
        end
    end
 end 

assign collision = collision_s;

  assign data_1 = (q_0 | gen_one_reg_rev); 
  
  
  genvar j;
  generate
    for (j = 0; j < WIDTH; j=j+1) begin:data_inverse
        assign gen_one_reg_rev[j] = gen_one[WIDTH-j-1]; 
    end
  endgenerate
  


    mem_dual #(.WIDTH(WIDTH), .DEPTH(DEPTH), .FILE(FILE)) mem_dual_A (
    .clock(clk),
    .data_0(data_0),
    .data_1(data_1),
    .address_0(addr_read),
    .address_1(addr_1_mux),
    .wren_0(wren_0),
    .wren_1(wren_1),
    .q_0(q_0),
    .q_1(q_1)
  );
 

assign addr_read = reading_out? addr_0: decode_addr;

assign addr_1_mux = rd_e_1? rd_addr_e_1: addr_1;

assign error_1 = q_1;


 //======================================================================================
 //Logic for second RAM 
 
 
 
  genvar k;
  generate
    for (k = 0; k < E0_WIDTH; k=k+1) begin:E0_vector_gen
        assign E0_gen_one[k] = (k == location % E0_WIDTH) ? 1'b1 : 1'b0; 
    end
  endgenerate
  
  
  assign E0_data_0 = 0;
  
  assign E0_decode_addr = location/E0_WIDTH; 
  
  
  assign E0_data_1 = (E0_q_0 | E0_gen_one_reg_rev); 
    
  
  genvar o;
  generate
    for (o = 0; o < E0_WIDTH; o=o+1) begin:E0_data_inverse 
        assign E0_gen_one_reg_rev[o] = E0_gen_one[E0_WIDTH-o-1]; 
    end
  endgenerate
     
     assign E0_wren_0 = wren_0;
     assign E0_wren_1 = wren_1;
     
     // second memory with width matching the column width from encrypt operation
     mem_dual #(.WIDTH(E0_WIDTH), .DEPTH(E0_DEPTH), .FILE(E0_FILE)) mem_dual_B (
    .clock(clk),
    .data_0(E0_data_0),
    .data_1(E0_data_1),
    .address_0(E0_addr_read),
    .address_1(E0_addr_1_mux),
    .wren_0(E0_wren_0),
    .wren_1(E0_wren_1),
    .q_0(E0_q_0),
    .q_1(E0_q_1)
  );
  
 wire data_test_0;
 wire data_test_1;
 wire location_test;
 assign data_test_0 = (E0_addr_1 == addr_1)? 1'b0 : 1'b1; 
 assign data_test_1 = (E0_addr_0 == addr_0)? 1'b0 : 1'b1;
 assign location_test = (E0_decode_addr == decode_addr)? 1'b0 : 1'b1;
  
assign E0_addr_read =   reading_out? E0_addr_0: E0_decode_addr;

assign E0_addr_1_mux = rd_e_0? rd_addr_e_0: E0_addr_1;
assign error_0 = E0_q_1;


 //======================================================================================
 


always@(posedge clk)
begin
    if (rst) begin
//        state = s_initialize;
        state <= s_wait_for_init_mem;
        addr_0 <= 0;
        count_reg <= 0;
        addr_1 <= 0;
        ready_s <= 1'b0;
        
        E0_addr_0 <= 0;
        E0_addr_1 <= 0;
        
    end
    else begin
        if (state == s_wait_for_init_mem) begin
            done_s <= 1'b0;
            valid_s <= 1'b0;
            done_s <= 1'b0;
            addr_1 <= 0;
            addr_0 <= 0;
            rd_addr <= 0;
            count_reg <= 0;
            ready_s <= 1'b0;
            
            E0_addr_0 <= 0;
            E0_addr_1 <= 0;
            
            if (init_mem) begin
                state <= s_initialize;
            end
            
        end
        
        else if (state == s_initialize) begin
            valid_s <= 1'b0;
            done_s <= 1'b0;
            addr_1 <= 0;
            addr_0 <= 0;
            rd_addr <= 0;
            count_reg <= 0;
            state <= s_init_done;
            ready_s <= 1'b0;
            
            E0_addr_0 <= 0;
            E0_addr_1 <= 0;
        end 
        
        else if (state == s_init_done) begin
            if (addr_0 == DEPTH - 1) begin
                addr_0 <= 0;
                E0_addr_0 <= 0;
                state <= s_wait_start;
                ready_s <= 1'b1;
            end
            else begin
                addr_0 <= addr_0+1;
                E0_addr_0 <= E0_addr_0+1;
                state <= s_init_done;
            end
         end
         
         else if (state == s_wait_start) begin
            if (start) begin
                ready_s <= 1'b0;
                rd_addr <= 0;
                state <= s_load_loc;
                count_reg <= 0;
            end
         end
         
         else if (state == s_load_loc) begin
            if (~collision_s) begin       
                if (rd_addr == TAU-1) begin
                    rd_addr <= 0;
                    state <= s_wait_last_2;
                    addr_1 <= decode_addr;
                    E0_addr_1 <= E0_decode_addr;
                    count_reg <= count_reg + 1;
                end
                else begin
                    state <= s_stall_for_ram;
                    rd_addr <= rd_addr + 1;
                    addr_0 <= decode_addr;
                    addr_1 <= decode_addr;
                    
                    E0_addr_0 <= E0_decode_addr;
                    E0_addr_1 <= E0_decode_addr;
                    
                    count_reg <= count_reg + 1;
                end 
             end
            else begin 
                state <= s_initialize;
            end  
         end
         
         else if (state == s_stall_for_ram) begin
            if (~collision_s) begin  
                state <= s_load_loc;
            end
            else begin 
                state <= s_initialize;
            end
         end
         
         else if (state == s_wait_last_2) begin
            if (~collision_s) begin
                if (count_reg == TAU+2-1) begin
                    count_reg <= 0;
                    state <= s_done;
                    addr_0 <= 0;
                    E0_addr_0 <= 0;
                end
                else begin
                    state <= s_wait_last_2;
                    count_reg <= count_reg + 1;
                    addr_1 <= decode_addr;
                    E0_addr_1 <= E0_decode_addr;
                end
             end
            else begin 
                state <= s_initialize;
            end 
         end 
         
 
         
         else if (state == s_read_out) begin
            valid_s <= 1'b1;
            if (addr_0 == DEPTH-1) begin
                state <= s_done;
                addr_0 <= 0;
            end
            else begin
                state <= s_read_out;
                addr_0 <= addr_0 + 1;
            end 
         end        
              
        else if (state == s_done) begin
            done_s <= 1'b1;
            valid_s <= 1'b0;
            state <= s_wait_for_init_mem;
        end
    end 
  
end 

always@(state or addr_0 or count_reg or start)
begin
    case (state)
      s_initialize: begin
                     wren_0 <= 1'b1;
                     wren_1 <= 1'b0;
                     init <= 1'b1;
                     rd_en <= 1'b0;
                     reading_out <= 1'b1;
                    end
      
                   
      s_init_done: begin 
                    wren_0 <= 1'b1;
                    wren_1 <= 1'b0; 
                    init <= 1'b0;
                    
                   end  
      
      s_wait_start: begin
                        wren_0 <= 1'b0;
                        reading_out <= 1'b0;
                        if (start) begin
                            rd_en <= 1'b1;
                        end
                        else begin
                            rd_en <= 1'b0;
                        end
                    end  
                    
      s_load_loc: begin
                    rd_en <= 1'b1;
                    wren_1 <= 1'b0;
                  end 
                  
      s_stall_for_ram: begin
                            wren_1 <= 1'b1;
                       end

                      
      s_wait_last_2: begin
                    rd_en <= 1'b0;
                    if (count_reg < TAU+1) begin
                        wren_1 <= 1'b1;
                    end
                    else begin
                        wren_1 <= 1'b0;
                    end
                  end 

      s_read_out: begin
                    wren_1 <= 1'b0;
                    reading_out <= 1'b1;
                  end     
                  
      s_done:      begin 
                    wren_0 <= 1'b0; 
                    wren_1 <= 1'b0;
                    reading_out <= 1'b0;
                   end     
   
      default: wren_0 <= 1'b0;
    endcase

end     
endmodule
