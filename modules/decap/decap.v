`timescale 1ns / 1ps
/*
 * This file is dencapsulation module.
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

module decap#(

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
           parameter PG_WIDTH = m*(t+1),
           parameter PG_WIDTH_EXT = PG_WIDTH+(32 - PG_WIDTH%32)%32,
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

           parameter mem_width = (parameter_set == 1 || parameter_set == 3 || parameter_set == 5 )? 16: 32, // memory width in add_FFT (mem_A/B)
           parameter mul_sec_BM = 20, // number of multipliers inside vec_mul_multi in BM module
           parameter mul_sec_BM_step = 20, // number of multipliers inside vec_mul_multi in BM module

           parameter eva_mem_WIDTH = 2*m*mem_width, //memory width in the add_FFT module, sum of mem_A and mem_B
           parameter eva_mem_WIDTH_bits = `CLOG2(mem_width)+1,
           parameter eva_mem_DEPTH = (1 << (`CLOG2(t))), //memory depth in the add_FFT module
           parameter eva_mem_DEPTH_bits = `CLOG2(t)

       )
       (
           input 										clk,
           input 										rst,
           output 										done,

           input 										start,

           input 										s_wr_en,
           input [31:0] 								s_in,
           input [`CLOG2((n + (32-n%32)%32)/32) -1 : 0] s_addr,

           input 										C0_valid,
           input [31:0] 								C0_in,
           output reg 									C0_ready,

           input 										C1_valid,
           input [31:0] 								C1_in,
           output reg 									C1_ready,

           input 										poly_g_valid,
           input [31:0] 								poly_g_in,
           output reg 									poly_g_ready,

           input wire [m-1:0] 							P_dout,
           output wire 									P_rd_en,
           output wire [m-1:0] 							P_rd_addr,

           input 										rd_K,
           input [2:0] 									K_addr,
           output [31:0] 								K_out,
`ifdef SHARED
		   //shared ADD FFT ports 
		   output wire 									fft_eva_start_dec,
		   output wire [m*(t+1)-1:0] 					fft_coeff_in_dec,
		   output wire 									fft_rd_en_dec,
		   output wire [`CLOG2(t+1)-1:0] 				fft_rd_addr_dec,
		   input wire [eva_mem_WIDTH-1:0] 				fft_eva_dout_dec,
		   input wire 									fft_eva_done_dec,
`endif
           //shake interface
           output 										din_valid_shake_dec,
           output [31:0] 								din_shake_dec,
           output 										dout_ready_shake_dec,
           input 										din_ready_shake,
           input 										dout_valid_shake,
           input [31:0] 								dout_shake
       );


wire seed_ready_internal;
wire  [31:0] din_shake;
wire [31:0] dout_shake_scrambled;
wire dout_valid_sh_internal;

wire [32-1:0] rev_error_1;
reg [32-1:0] rev_error_1_reg = 0;


reg [2:0] sel_in_shake = 0;
reg din_valid = 0;
reg din_valid_h = 0;

reg start_hash = 0;
reg reg_en_er = 0;
reg [2:0]sel_hram = 0;
reg [1:0]sel_ec = 0;
reg sel_k = 0;
parameter [7:0] byte_2 = 8'h02;
parameter [7:0] byte_1 = 8'h01;

wire [31:0] C0, C1;
reg [31:0] C0_reg = 0, C1_reg = 0;
wire [31:0] cipher;
reg first_C0 = 0, first_C1 = 0, last_C1 = 0;

reg [`CLOG2((l + (32-l%32)%32)/32) -1 : 0] addr_rd_c = 0;
reg rd_en_c = 0;
reg C1_read_ready = 0;
reg dont_capture_shake = 0;
reg dont_capture_C0 = 0;
reg [`CLOG2(HASH_RAM_DEPTH):0] count_hash_in = 0;

wire [31:0] change01;
wire [31:0] e_to_ram;
wire [31:0] h_data_0, h_data_1;
wire [31:0] q_0, q_1;
reg	h_wren_0 = 0, h_wren_1 = 0;
reg [`CLOG2(HASH_RAM_DEPTH):0] h_addr_0 = 0, h_addr_1 = 0;
reg [`CLOG2(HASH_RAM_DEPTH):0] total_contents = 0;
wire [31:0] C0_to_ram, C1_to_ram;

wire [31:0] C1_from_ram;

reg [2:0]C1_addr = 0;
reg wr_en_C1 = 0, load_C1 = 0;
reg [2:0]C1_addr_h = 0;
reg [3:0]C1_correct_count = 0;


reg [`CLOG2((n + (32-n%32)%32)/32) -1 : 0] s_addr_h = 0;
reg wr_en_s = 0, load_s = 0;
wire [31:0]s_from_ram;

wire [31:0]error_or_s;
reg dec_fail_reg = 0;
reg C1_not_verified = 0;

   reg [`CLOG2((l + (32-l%32)%32)/32) -1 : 0] C0_addr = 0;
   reg wr_en_C0 = 0, load_C0 = 0;
   reg [`CLOG2((l + (32-l%32)%32)/32) -1 : 0]C0_addr_internal = 0;
   reg C0_shift = 0, C0_en = 0;
   reg [l+(32 - l%32)%32 - 1 : 0] C0_reg_to_decrypt = 0;

   reg [`CLOG2((PG_WIDTH + (32-PG_WIDTH%32)%32)/32) -1 : 0]pg_count = 0;
   reg pg_shift = 0, pg_en = 0;
   reg [PG_WIDTH+(32 - PG_WIDTH%32)%32 - 1 : 0] poly_g_reg = 0;


   reg e_en = 0, e_shift = 0;
wire done_error;
wire decryption_fail;
wire [n-1:0]error;
   reg [n-1:0]error_reg = 0;
   reg C0_loaded = 0, C1_loaded = 0, poly_g_loaded = 0;
   reg start_dec = 0;


//shake interface signals
assign din_valid_shake_dec = din_valid_h;
assign seed_ready_internal = din_ready_shake;
assign din_shake_dec = din_shake;
assign dout_valid_sh_internal = dout_valid_shake;
assign dout_ready_shake_dec = C1_read_ready;
assign dout_shake_scrambled = dout_shake;

//================================================================
//decryption
//================================================================

main  decryption_module(
          .clk(clk),
		  .start(start_dec),
          .cipher(C0_reg_to_decrypt[l+(32 - l%32)%32 - 1: (32 - l%32)%32]),
          .poly_g(poly_g_reg[PG_WIDTH+(32 - PG_WIDTH%32)%32 - 1: (32 - PG_WIDTH%32)%32]),
          .error_recovered(error),
          .done(done_error),
          .P_dout(P_dout),
          .P_rd_en(P_rd_en),
          .P_rd_addr(P_rd_addr),
`ifdef SHARED
		  //shared fft signals
		  .fft_eva_start_dec(fft_eva_start_dec),
          .fft_coeff_in_dec(fft_coeff_in_dec),
          .fft_rd_en_dec(fft_rd_en_dec),      
		  .fft_rd_addr_dec(fft_rd_addr_dec),  
          .fft_eva_dout_dec(fft_eva_dout_dec),
          .fft_eva_done_dec(fft_eva_done_dec),
`endif
          .decryption_fail(decryption_fail)
      );


assign K_out = q_0;

always@(posedge clk)
begin
    if (e_en) begin
        error_reg <= error;
    end
    else if (e_shift) begin
        error_reg <= {error_reg[n-32-1:0], {32{1'b0}}};
    end
end

assign error_or_s = (dec_fail_reg | C1_not_verified)? s_from_ram : error_reg[n-1:n-32];

rearrange_vector e_in_arrange(.vector_in(error_or_s),.vector_out(rev_error_1));




 mem_single #(.WIDTH(32), .DEPTH( ((n + (32-n%32)%32)/32) )) s_mem
 (
        .clock(clk),
        .data(s_in),
        .address(s_wr_en? s_addr: s_addr_h),
        .wr_en(s_wr_en),
        .q(s_from_ram)
 );
 
wire test_s_equal_e;
assign test_s_equal_e= (s_from_ram == (error_reg[n-1:n-32]))? 1'b1 : 1'b0;
//================================================================

//================================================================
//C1_loading
//================================================================
reg [2:0] state_C1 = 0;
parameter s_wait_valid_C1      =   0;
parameter s_loading_C1     =   1;
parameter s_wait_done_C1            =   2;

always@(posedge clk)
begin

    if (rst) begin
        state_C1 <= s_wait_valid_C1;
        C1_addr <= 0;
        C1_ready <= 1'b0;
    end

    else begin
        if (state_C1 == s_wait_valid_C1) begin
            C1_ready <= 1'b1;
            if (C1_valid) begin
                C1_addr <= C1_addr + 1;
                state_C1 <= s_loading_C1;
            end
            else begin
                C1_addr <= 0;
            end
        end

        else if (state_C1 == s_loading_C1) begin
            if (C1_addr == 7) begin
                state_C1 <=  s_wait_done_C1;
                C1_addr <= 0;
                C1_ready <= 1'b0;
            end
            else begin
                if (C1_valid) begin
                    state_C1 <= s_loading_C1;
                    C1_addr <= C1_addr + 1;
                    C1_ready <= 1'b1;
                end
            end
        end

        else if (state_C1 == s_wait_done_C1) begin
            if (done_r) begin
                state_C1 <= s_wait_valid_C1;
                C1_ready <= 1'b1;
            end
        end


    end

end

always@(state_C1 or C1_valid)
begin
    case (state_C1)
        s_wait_valid_C1: begin
            C1_loaded <= 1'b0;
            if (C1_valid) begin
                load_C1 <= 1'b1;
                wr_en_C1 <= 1'b1;

            end
            else begin
                load_C1 <= 1'b0;
                wr_en_C1 <= 1'b0;
            end
        end

        s_loading_C1: begin
            C1_loaded <= 1'b0;
            if (C1_valid) begin
                load_C1 <= 1'b1;
                wr_en_C1 <= 1'b1;

            end
            else begin
                wr_en_C1 <= 1'b0;
            end
        end

        s_wait_done_C1: begin
            load_C1 <= 1'b0;
            wr_en_C1 <= 1'b0;
            C1_loaded <= 1'b1;
        end


        default: begin
            load_C1 <= 1'b0;
            wr_en_C1 <= 1'b0;
        end

    endcase
end

rearrange_vector C1_arrange(.vector_in(C1_from_ram),.vector_out(C1));

mem_single #(.WIDTH(32), .DEPTH(8) ) C1_mem
           (
               .clock(clk),
               .data(C1_in),
               .address(load_C1? C1_addr: C1_addr_h),
               .wr_en(wr_en_C1),
               .q(C1_from_ram)
           );

//verifying if C1 == C1prime
wire C1_eq_C1prime;
assign C1_eq_C1prime = (C1 == dout_shake_scrambled)? 1'b1 : 1'b0;

//================================================================



//================================================================
//C0_loading
//================================================================
reg [2:0] state_C0 = 0;
parameter s_wait_valid_C0      =   0;
parameter s_loading_C0     =   1;
parameter s_wait_done_C0            =   2;

always@(posedge clk)
begin

    if (rst) begin
        state_C0 <= s_wait_valid_C0;
        C0_addr <= 0;
        C0_ready <= 1'b0;
    end

    else begin
        if (state_C0 == s_wait_valid_C0) begin
            C0_ready <= 1'b1;
            if (C0_valid) begin
                C0_addr <= C0_addr + 1;
                state_C0 <= s_loading_C0;
            end
            else begin
                C0_addr <= 0;
            end
        end

        else if (state_C0 == s_loading_C0) begin
            if (C0_addr == ((l + (32-l%32)%32)/32) -1) begin
                state_C0 <=  s_wait_done_C0;
                C0_addr <= 0;
                C0_ready <= 1'b0;
            end
            else begin
                if (C0_valid) begin
                    state_C0 <= s_loading_C0;
                    C0_addr <= C0_addr + 1;
                    C0_ready <= 1'b1;
                end
            end
        end

        else if (state_C0 == s_wait_done_C0) begin
            if (done_r) begin
                state_C0 <= s_wait_valid_C0;
                C0_ready <= 1'b1;
            end
        end


    end

end

always@(state_C0 or C0_valid)
begin
    case (state_C0)
        s_wait_valid_C0: begin
            C0_loaded <= 1'b0;
            if (C0_valid) begin
                load_C0 <= 1'b1;
                wr_en_C0 <= 1'b1;
                C0_en <= 1'b1;
                C0_shift <= 1'b0;


            end
            else begin
                load_C0 <= 1'b0;
                wr_en_C0 <= 1'b0;
                C0_en <= 1'b0;
                C0_shift <= 1'b0;
            end
        end

        s_loading_C0: begin
            C0_loaded <= 1'b0;
            if (C0_valid) begin
                load_C0 <= 1'b1;
                wr_en_C0 <= 1'b1;
                C0_shift <= 1'b1;
                C0_en <= 1'b0;

            end
            else begin
                wr_en_C0 <= 1'b0;
                C0_shift <= 1'b0;
                C0_en <= 1'b0;
            end
        end

        s_wait_done_C0: begin
            load_C0 <= 1'b0;
            wr_en_C0 <= 1'b0;
            C0_shift <= 1'b0;
            C0_en <= 1'b0;
            C0_loaded <= 1'b1;
        end


        default: begin
            load_C0 <= 1'b0;
            wr_en_C0 <= 1'b0;
        end

    endcase
end

rearrange_vector C0_arrange(.vector_in(cipher),.vector_out(C0));
mem_single #(.WIDTH(32), .DEPTH(((l + (32-l%32)%32)/32)) ) C0_mem
           (
               .clock(clk),
               .data(C0_in),
               .address(load_C0?C0_addr:addr_rd_c),
               .wr_en(wr_en_C0),
               .q(cipher)
           );

always@(posedge clk)
begin
    if (C0_en) begin
        C0_reg_to_decrypt <= {{(l+ (32-l%32)%32 -32){1'b0}},C0_in};;
    end
    else if (C0_shift) begin
        C0_reg_to_decrypt <= {C0_reg_to_decrypt[l + (32-l%32)%32 -32 -1:0], C0_in};
    end
end

//================================================================


//================================================================
//================================================================
//poly_g_loading
//================================================================
reg [2:0] state_pg = 0;
parameter s_wait_valid_pg  =   0;
parameter s_loading_pg     =   1;
parameter s_wait_done_pg   =   2;

always@(posedge clk)
begin

    if (rst) begin
        state_pg <= s_wait_valid_pg;
        pg_count <= 0;
        poly_g_ready <= 1'b0;
    end

    else begin
        if (state_pg == s_wait_valid_pg) begin
            poly_g_ready <= 1'b1;
            if (poly_g_valid) begin
                pg_count <= pg_count + 1;
                state_pg <= s_loading_pg;
            end
            else begin
                pg_count <= 0;
            end
        end

        else if (state_pg == s_loading_pg) begin
            if (pg_count == ((PG_WIDTH + (32-PG_WIDTH%32)%32)/32) -1) begin
                state_pg <=  s_wait_done_pg;
                pg_count <= 0;
                poly_g_ready <= 1'b0;
            end
            else begin
                if (poly_g_valid) begin
                    state_pg <= s_loading_pg;
                    pg_count <= pg_count + 1;
                    poly_g_ready <= 1'b1;
                end
            end
        end

        else if (state_pg == s_wait_done_pg) begin
            if (done_r) begin
                state_pg <= s_wait_valid_pg;
                poly_g_ready <= 1'b1;
            end
        end


    end

end

always@(state_pg or poly_g_valid)
begin
    case (state_pg)
        s_wait_valid_pg: begin
            poly_g_loaded <= 1'b0;
            if (poly_g_valid) begin
                pg_en <= 1'b1;
                pg_shift <= 1'b0;

            end
            else begin
                pg_en <= 1'b0;
                pg_shift <= 1'b0;
            end
        end

        s_loading_pg: begin
            poly_g_loaded <= 1'b0;
            if (poly_g_valid) begin
                pg_shift <= 1'b1;
                pg_en <= 1'b0;

            end
            else begin
                pg_shift <= 1'b0;
                pg_en <= 1'b0;
            end
        end

        s_wait_done_pg: begin
            pg_shift <= 1'b0;
            pg_en <= 1'b0;
            poly_g_loaded <= 1'b1;
        end


        default: begin
            pg_shift <= 1'b0;
            pg_en <= 1'b0;
        end

    endcase
end

always@(posedge clk)
begin
    if (pg_en) begin
        poly_g_reg <= {{PG_WIDTH_EXT-32{1'b0}},poly_g_in};;
    end
    else if (pg_shift) begin
        poly_g_reg <= {poly_g_reg[PG_WIDTH_EXT-32-1:0], poly_g_in};
    end
end

//================================================================











always@(posedge clk)
begin
    if (!dont_capture_C0) begin
        C0_reg <= C0;
    end
    if ((!dont_capture_shake)) begin
        C1_reg <= C1;
    end
end


always@(posedge clk)
begin
    if (reg_en_er) begin
        rev_error_1_reg <= rev_error_1;
    end
end







assign din_shake = q_0;




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

parameter s_verify_c1               =   21;
parameter s_check_last_block        =   22;
parameter s_stall_to_check          =   23;
parameter s_replace_es              =   24;
parameter s_stall_ram_es            =   25;
parameter s_load_es_ram             =   26;
parameter s_load_domain_sep_es      =   27;
parameter s_done_load_es            =   28;
parameter s_start_decryption        =   29;

parameter s_done_decryption        =   30;



reg done_r=0;


assign done = done_r;

// Hash RAM control logic
always@(posedge clk)
begin

    if (rst) begin
        state_hr <= s_start_decryption;
        s_addr_h <= 0;
        h_addr_1 <= 0;
        addr_rd_c <= 0;
        C1_read_ready <= 1'b0;
        count_hash_in <= 0;
        C1_addr_h <= 0;
        C1_correct_count <= 0;
        C1_not_verified <= 0;
    end

    else begin

        if (state_hr == s_start_decryption) begin
            addr_rd_c <= 0;
            C1_read_ready <= 1'b0;
            C1_addr_h <= 0;
            count_hash_in <= 0;
            s_addr_h <= 0;
            C1_not_verified <= 0;
		   if (C0_loaded && poly_g_loaded) begin
                state_hr <= s_done_decryption;
            end
        end

        else if (state_hr == s_done_decryption) begin
            if (done_error) begin
                state_hr <= s_first_block;
                if (decryption_fail) begin
                    dec_fail_reg <= 1'b1;
                end
            end
            else begin
                dec_fail_reg <= 1'b0;
            end
        end

        else if (state_hr == s_first_block) begin
            addr_rd_c <= 0;
            C1_read_ready <= 1'b0;
            C1_addr_h <= 0;
            count_hash_in <= 0;
            s_addr_h <= 0;
            C1_not_verified <= 0;

            //            if ((C1_loaded && s_loaded)) begin
            if (C1_loaded) begin
                h_addr_1 <= h_addr_1 + 1;
                state_hr <= s_second_block;
            end
        end

        else if (state_hr == s_second_block) begin
            h_addr_1 <= h_addr_1 + 1;
            count_hash_in <= count_hash_in + 1;
            state_hr <= s_wait_for_error_done;

        end

        else if (state_hr == s_wait_for_error_done) begin
            state_hr <= s_stall_for_ram;
            s_addr_h <= s_addr_h + 1;

        end

        else if (state_hr == s_stall_for_ram) begin
            state_hr <= s_load_data_to_ram;
            h_addr_1 <= h_addr_1 + 1;
            s_addr_h <= s_addr_h + 1;
            count_hash_in <= count_hash_in + 1;
        end

        else if (state_hr == s_load_data_to_ram) begin
            if (h_addr_1 > E_HASH_DEPTH - 1) begin
                state_hr <= s_done_loading;
                s_addr_h <= 0;
            end
            else begin
                h_addr_1 <= h_addr_1 + 1;
                count_hash_in <= count_hash_in + 1;

                if (s_addr_h> 0 && s_addr_h % 34 == 0) begin
                    state_hr <= s_load_domain_seperator;
                end
                else begin
                    state_hr <= s_load_data_to_ram;
                    if (s_addr_h < ((n + (32-n%32)%32)/32)-1) begin
                        s_addr_h <= s_addr_h + 1;
                    end
                end
            end
        end

        else if (state_hr == s_load_domain_seperator) begin
            state_hr <= s_load_data_to_ram;
            h_addr_1 <= h_addr_1 + 1;
            s_addr_h <= s_addr_h + 1;

        end

        else if (state_hr == s_done_loading) begin
            h_addr_1 <= 2;
            C1_read_ready <= 1'b1;
            if (dout_valid_sh_internal) begin

                state_hr <= s_verify_c1;
                C1_addr_h <= C1_addr_h + 1;
                if (C1_eq_C1prime) begin
                    C1_correct_count <= C1_correct_count + 1;
                end
            end
            else begin
                state_hr <= s_done_loading;
            end
        end

        else if (state_hr == s_verify_c1) begin
            if (C1_addr_h == 7) begin
                C1_addr_h <= 0;
                state_hr <= s_check_last_block;
                C1_read_ready <= 1'b0;

            end
            else begin
                if (dout_valid_sh_internal) begin
                    C1_addr_h <= C1_addr_h + 1;
                    state_hr <= s_verify_c1;
                    if (C1_eq_C1prime) begin
                        C1_correct_count <= C1_correct_count + 1;
                    end
                end
            end
        end

        else if (state_hr == s_check_last_block) begin
            state_hr <= s_stall_to_check;
            if (dout_valid_sh_internal) begin
                if (C1_eq_C1prime) begin
                    C1_correct_count <= C1_correct_count + 1;
                end
            end
        end

        else if (state_hr == s_stall_to_check) begin
            state_hr <= s_replace_es;
            if (C1_correct_count == 8) begin
                C1_not_verified <= 1'b0;
            end
            else begin
                C1_not_verified <= 1'b1;
            end
        end

        else if (state_hr == s_replace_es) begin
            state_hr <= s_stall_ram_es;
            s_addr_h <= s_addr_h + 1;
        end

        else if (state_hr == s_stall_ram_es) begin
            state_hr <= s_load_es_ram;
            h_addr_1 <= h_addr_1 + 1;
            s_addr_h <= s_addr_h + 1;
        end

        else if (state_hr == s_load_es_ram) begin
            if (h_addr_1 > E_HASH_DEPTH - 1) begin
                state_hr <= s_done_load_es;
                h_addr_1 <= 2;
                s_addr_h <= 0;
            end
            else begin
                h_addr_1 <= h_addr_1 + 1;

                if (s_addr_h> 0 && s_addr_h % 34 == 0) begin
                    state_hr <= s_load_domain_sep_es;
                end
                else begin
                    state_hr <= s_load_es_ram;
                    if (s_addr_h < ((n + (32-n%32)%32)/32)-1) begin
                        s_addr_h <= s_addr_h + 1;
                    end
                end
            end
        end

        else if (state_hr == s_load_domain_sep_es) begin
            state_hr <= s_load_es_ram;
            h_addr_1 <= h_addr_1 + 1;
            s_addr_h <= s_addr_h + 1;
        end

        else if (state_hr == s_done_load_es) begin
            h_addr_1 <= 2;
            C1_read_ready <= 1'b1;
            state_hr <= s_update_01;

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

            state_hr <= s_load_enc_to_ram;
            count_hash_in <= count_hash_in - 1;

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
            C1_addr_h <= C1_addr_h + 1;
        end

        else if (state_hr == s_first_load_C1) begin
            C1_read_ready <= 1'b0;
            h_addr_1 <= h_addr_1 + 1;
            state_hr <= s_load_C1;
            count_hash_in <= count_hash_in + 1;
            C1_addr_h <= C1_addr_h + 1;
        end

        else if (state_hr == s_load_C1) begin
            if (h_addr_1 == HASH_RAM_DEPTH-2) begin
                state_hr <= s_load_last_C1;
                h_addr_1 <= h_addr_1 + 1;
            end
            else if (h_addr_1 == HASH_RAM_DEPTH - HASH_RAM_DEPTH%34 + SH_DOM_SEP -1) begin
                state_hr <= s_load_domain_sep_2;
                h_addr_1 <= h_addr_1 + 1;
            end
            else begin
                h_addr_1 <= h_addr_1 + 1;
                count_hash_in <= count_hash_in + 1;

                C1_addr_h <= C1_addr_h + 1;
            end
        end

        else if (state_hr == s_load_domain_sep_2) begin
            h_addr_1 <= h_addr_1 + 1;
            state_hr <= s_load_C1;
            count_hash_in <= count_hash_in + 1;
            C1_addr_h <= C1_addr_h + 1;
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
            state_hr <= s_start_decryption;
            C1_read_ready <= 1'b0;
            done_r <= 1'b0;
            C1_not_verified <= 1'b0;
            dec_fail_reg <= 1'b0;
        end

    end

end


always@(state_hr or done_error or h_addr_1 or addr_rd_c or dout_valid_sh_internal or C1_not_verified or C0_loaded or C1_loaded or poly_g_loaded)
begin
    case (state_hr)
        s_start_decryption: begin
            dont_capture_C0 <= 1'b0;
            sel_hram <= 3'b001;
            reg_en_er <= 1'b1;
            start_hash <= 1'b0;
            rd_en_c <= 1'b0;
            sel_ec <= 2'b00;
            first_C0 <= 1'b0;
            first_C1 <= 1'b0;
            last_C1 <= 1'b0;
            dont_capture_shake <= 1'b0;
            total_contents <= 0;
            sel_k <= 1'b0;;
            e_shift <= 1'b0;

		   if (C0_loaded && poly_g_loaded) begin
                start_dec <= 1'b1;
            end
            else begin
                start_dec <= 1'b0;
            end

        end


        s_done_decryption: begin
            start_dec <= 1'b0;
            if (done_error) begin
                e_en <= 1'b1;
            end
            else begin
                e_en <= 1'b0;
            end
        end


        s_first_block: begin
            start_dec <= 1'b0;
            dont_capture_C0 <= 1'b0;
            sel_hram <= 3'b001;
            reg_en_er <= 1'b1;

            start_hash <= 1'b0;
            rd_en_c <= 1'b0;
            sel_ec <= 2'b00;
            first_C0 <= 1'b0;
            first_C1 <= 1'b0;
            last_C1 <= 1'b0;
            dont_capture_shake <= 1'b0;
            total_contents <= 0;
            sel_k <= 1'b0;
            e_shift <= 1'b0;
            e_en <= 1'b0;

            //                      if (C1_loaded && s_loaded) begin
            if (C1_loaded) begin
                h_wren_1 <=  1'b1;
            end
            else begin
                h_wren_1 <=  1'b0;
            end
        end

        s_second_block: begin
            start_dec <= 1'b0;
            dont_capture_C0 <= 1'b0;
            sel_hram <= 3'b010;
            reg_en_er <= 1'b1;
            h_wren_1 <=  1'b1;
            rd_en_c <= 1'b0;
            sel_ec <= 2'b00;
            first_C0 <= 1'b0;
            first_C1 <= 1'b0;
            last_C1 <= 1'b0;
            sel_k <= 1'b0;
            e_en <= 1'b0;
            e_shift <= 1'b0;
        end

        s_wait_for_error_done: begin
            e_shift <= 1'b0;
            rd_en_c <= 1'b0;
            h_wren_1 <=  1'b0;
            reg_en_er <= 1'b1;
        end

        s_stall_for_ram: begin
            e_en <= 1'b0;
            e_shift <= 1'b1;
            rd_en_c <= 1'b0;
            reg_en_er <= 1'b1;
            sel_hram <= 3'b011;
            h_wren_1 <=  1'b1;
        end

        s_load_data_to_ram: begin
            reg_en_er <= 1'b1;
            rd_en_c <= 1'b0;


            if (h_addr_1 <E_HASH_DEPTH) begin
                h_wren_1 <=  1'b1;
                e_shift <= 1'b1;
            end
            else begin
                h_wren_1 <=  1'b0;
                start_hash <= 1'b1;
                total_contents <= E_HASH_DEPTH;
            end

            if (h_addr_1 == E_HASH_DEPTH-1) begin
                sel_hram <= 3'b101;
            end
            else begin
                sel_hram <= 3'b000;
            end

        end

        s_load_domain_seperator: begin
            e_shift <= 1'b0;
            rd_en_c <= 1'b0;
            h_wren_1 <=  1'b1;
            reg_en_er <= 1'b0;
            if (h_addr_1 > (E_HASH_DEPTH - E_HASH_DEPTH%34)) begin
                sel_hram <= 3'b100;
            end
            else begin
                sel_hram <= 3'b010;
            end
        end

        s_done_loading: begin
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
        end

        s_stall_ram_es: begin
            reg_en_er <= 1'b1;
            sel_hram <= 3'b011;
            if (C1_not_verified) begin
                h_wren_1 <=  1'b1;
            end
            else begin
                h_wren_1 <=1'b0;
            end
        end

        s_load_es_ram: begin
            reg_en_er <= 1'b1;

            if (C1_not_verified) begin
                if (h_addr_1 <E_HASH_DEPTH) begin
                    h_wren_1 <=  1'b1;
                end
                else begin
                    h_wren_1 <=  1'b0;
                end
            end
            else begin
                h_wren_1 <=  1'b0;
            end

            if (h_addr_1 == E_HASH_DEPTH-1) begin
                sel_hram <= 3'b101;
            end
            else begin
                sel_hram <= 3'b000;
            end
        end

        s_load_domain_sep_es: begin
            reg_en_er <= 1'b0;
            h_wren_1 <=  1'b0;
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
        end

        s_load_C1: begin
            dont_capture_shake <= 1'b0;
            first_C1 <= 1'b0;
            sel_ec <= 2'b11;
            h_wren_1 <= 1'b1;
        end

        s_load_domain_sep_2: begin
            sel_ec <= 2'b00;
            sel_hram <= 3'b110;
            h_wren_1 <= 1'b1;
            dont_capture_shake <= 1'b1;
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
            start_hash <= 1'b0;
        end

        default: din_valid = 1'b0;

    endcase

end



assign e_to_ram = (sel_hram == 3'b001)? SHAKE_FIRST_IN:
       (sel_hram == 3'b010)? SHAKE_SECOND_IN:
       (sel_hram == 3'b011)? {rev_error_1[32-8-1:0], byte_2}:
       (sel_hram == 3'b100)? E_SHAKE_LAST_IN:
       (sel_hram == 3'b101)? {rev_error_1[23:0], rev_error_1_reg[31:24]}:
       (sel_hram == 3'b110)? SHAKE_LAST_IN:
       {rev_error_1[23:0], rev_error_1_reg[31:24]};


assign C0_to_ram = (first_C0)? {C0[32-C0_w-1:0], q_1[C0_w-1:0]}: {C0[32-C0_w-1:0], C0_reg[31:32-C0_w]} ;


assign C1_to_ram = (first_C1)? {C1[23:0], C0_reg[C1_w_h-1:C1_w_l]}:
       (last_C1)?  {{24{1'b0}}, C1_reg[31:24]}:
       {C1[23:0], C1_reg[31:24]} ;

wire [31:0] K_mem;
wire [7:0] b;
rearrange_vector K_arrange(.vector_in(dout_shake_scrambled),.vector_out(K_mem));

assign b = ((dec_fail_reg == 1'b1)|(C1_not_verified==1'b1))? (8'b00000000) : (8'b00000001);


assign change01 = sel_k ? K_mem : {q_1[31:8],b};

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
