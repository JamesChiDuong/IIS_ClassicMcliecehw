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

`timescale 1ns/1ps

module decap_with_support_tb
       #(
           parameter parameter_set =4,


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

           // system parameters
           // key generation
           parameter N_H = T,
           parameter BLOCK_H = T,
           parameter N_R = 2, // N in R elimination
           parameter BLOCK_R = 1, // BLOCK in R elimination

           parameter SIGMA1 = 16, // bit width of random values for generation the polynomial
           parameter SIGMA2 = 32, // bit width of integer used in sort module

           parameter MEM_WIDTH = 32,
           parameter K = N,
           parameter L = M*T,
           parameter K_H_elim = N_H*((K+N_H-1)/N_H),
           parameter K_R_elim = N_R*((T+1+N_R-1)/N_R),
           parameter PG_WIDTH = M*(T+1),

           parameter BAUD_RATE = 115200,
           parameter CLOCK_FPGA = 100000000


       )
       (
           input wire  clk,
           input wire  rst,
           //input wire  start,
           //output reg  loading_done = 1'b0,
           output wire done_decap,
           output wire support_gen_done
       );

// input
//reg clk = 1'b0;
//reg rst = 1'b0;
reg s_valid = 1'b0;
wire [32-1:0] seed_from_ram;
reg  [32-1:0] delta;

// output
//wire done;
//wire support_gen_done;

//ram controls
reg [4:0] addr_s = 0;


//shake interfaces
wire          shake_din_valid_d;
wire          shake_din_ready_d;
wire [31:0]   shake_din_d;
wire          shake_dout_ready_d;
wire [31:0]   shake_dout_scramble;
wire          shake_force_done_d;
wire          shake_dout_valid_d;

reg host_sk_poly_rd_en = 1'b0;
reg [`CLOG2(T*K_R_elim/N_R)-1:0]   host_sk_poly_rd_addr = 0;
wire [M*N_R-1:0] sk_poly_dout;
wire sk_poly_gen_done;

reg host_perm_rd_en = 1'b0;
reg [M-1:0] host_perm_rd_addr = 0;
wire [M-1:0] perm_dout;
wire perm_done;

reg host_pk_rd_en = 0;
reg [`CLOG2(L*K_H_elim/N_H)-1:0] host_pk_rd_addr = 0;
wire [N_H-1:0] pk_dout;
wire pk_gen_done;
reg pk_gen_fail = 0;

//Decapsulation signals
reg [`CLOG2((L + (32-L%32)%32)/32) -1 : 0]addr_C0 = 0;
wire [31:0]C0_in;
reg C0_valid = 0;

wire C1_ready;
   reg C1_valid = 0;
wire [31:0]C1_in;
   reg [2:0]addr_C1 = 0;

   reg [`CLOG2((PG_WIDTH + (32-PG_WIDTH%32)%32)/32) -1 : 0]addr_pg = 0;
wire [31:0]poly_g_in;
   reg poly_g_valid = 0;
wire poly_g_ready;

   reg rd_K = 0;
   reg [2:0]K_addr = 0;
wire [31:0]K_out;

reg start_decap = 0;
//wire done_decap;
//assign done = done_decap;

keccak_top shake_instance
           (
               .rst(rst),
               .clk(clk),
               .din_valid(shake_din_valid_d),
               .din_ready(shake_din_ready_d),
               .din(shake_din_d),
               .dout_valid(shake_dout_valid_d),
               .dout_ready(shake_dout_ready_d),
               .dout(shake_dout_scramble),
               .force_done(0)
           );

decap_with_support # (.parameter_set(parameter_set), .M(M), .T(T), .N(N), .N_H(N_H), .BLOCK_H(BLOCK_H), .N_R(N_R), .BLOCK_R(BLOCK_R), .SIGMA1(SIGMA1), .SIGMA2(SIGMA2), .MEM_WIDTH(MEM_WIDTH))
                   DUT  (
                       .clk(clk),
                       .rst(rst),
                       .delta_valid(s_valid),
                       .delta(delta),
                       .done(done),
                       .start_decap(start_decap),
                       .done_decap(done_decap),
                       .support_gen_done(support_gen_done),

                       //shake interface
                       .shake_din_valid_d(shake_din_valid_d),
                       .shake_din_ready_d(shake_din_ready_d),
                       .shake_din_d(shake_din_d),
                       .shake_dout_ready_d(shake_dout_ready_d),
                       .shake_dout_scrambled_d(shake_dout_scramble),
                       .shake_force_done_d(shake_force_done_d),
                       .shake_dout_valid_d(shake_dout_valid_d),

                       .C0_valid(C0_valid),
                       .C0_in(C0_in),
                       .C0_ready(C0_ready),

                       .C1_valid(C1_valid),
                       .C1_in(C1_in),
                       .C1_ready(C1_ready),

                       .poly_g_valid(poly_g_valid),
                       .poly_g_in(poly_g_in),
                       .poly_g_ready(poly_g_ready),

                       .rd_K(rd_K),
                       .K_addr(K_addr),
                       .K_out(K_out)

                       //    .pk_gen_fail(pk_gen_fail)
                   );

// ------------------------------------------------------

initial
begin
    $dumpfile(`FILE_VCD);
    $dumpvars();
end

// Memory loading procedure
reg [31:0] ctr = 0;
//reg loading_done = 0;

integer SIZE_S = 8;
integer SIZE_C1 = 8;
integer SIZE_C0 = ((L + (32-L%32)%32)/32);
integer SIZE_POLY = ((PG_WIDTH + (32-PG_WIDTH%32)%32)/32);

integer START_S = 0;
integer STOP_S = SIZE_S + 2;
integer START_C1 = STOP_S + 1;
integer STOP_C1 = START_C1 + SIZE_C1;
integer START_C0 = STOP_C1;
integer STOP_C0 = START_C0 + SIZE_C0;
integer START_POLY = STOP_C0;
integer STOP_POLY = START_POLY + SIZE_POLY + 1;

integer SIZE_TOTAL = STOP_POLY;//SIZE_S + SIZE_C0 + SIZE_C1 + SIZE_POLY;

always @(posedge clk)
begin
    if (rst)
    begin
        ctr <= 0;
        addr_C1 <= 0;
        addr_C0 <= 0;
        addr_s <= 0;
        addr_pg <= 0;
        s_valid <= 1'b0;
        C0_valid <= 1'b0;
        C1_valid <= 1'b0;
        poly_g_valid <= 1'b0;
        //done_error <= 1'b0;
        //loading_done <= 1'b0;
    end
    else
    begin
        // Wait until the field ordering module is done.
        if(ctr >= SIZE_TOTAL+1 || ctr == STOP_S && support_gen_done == 1'b0)
        begin
            ctr <= ctr;
        end
        else
            // Count until all memory is written.
            if (ctr < SIZE_TOTAL+1)
            begin
                ctr <= ctr + 1;
            end
    end
end

integer i;

always @(posedge clk)
begin
    // reset for one cycle
    //rst <= (ctr == 5) ? 1'b1 : 1'b0;
    delta <= seed_from_ram;
    start_decap <= 1'b0;

    // loading s
    if (ctr >= START_S && ctr < STOP_S)
    begin
        addr_s <= addr_s + 1;
			 if (ctr > START_S)
         s_valid <= 1'b1;
    end
    else
    begin
        addr_s <= addr_s;
        s_valid <= 1'b0;
    end
    // loading C1
    if (ctr > START_C1 && ctr <= STOP_C1)
    begin
        addr_C1 <= addr_C1 + 1;
        C1_valid <= 1'b1;
    end
    else
    begin
        addr_C1 <= addr_C1;
        C1_valid <= 1'b0;
    end
    // loading C0
    if (ctr > START_C0 && ctr <= STOP_C0)
    begin
        addr_C0 <= addr_C0 + 1;
        C0_valid <= 1'b1;
    end
    else
    begin
        addr_C0 <= addr_C0;
        C0_valid <= 1'b0;
    end
    // loading g
    if (ctr > START_POLY && ctr < STOP_POLY)
    begin
        addr_pg <= addr_pg + 1;
        poly_g_valid <= 1'b1;
    end
    else
    begin
        addr_pg <= addr_pg;
        poly_g_valid <= 1'b0;
    end
    // start decapsulation
    if (ctr == SIZE_TOTAL)
    begin
        start_decap <= 1'b1;
    end
end


/* Clock cycle count profiling */
integer f_cycles_profile;
time    time_decap_start;
time    time_field_ordering_start;
time time_field_ordering;

reg [17*8-1:0] prefix;

initial
begin
    f_cycles_profile = $fopen(`FILE_CYCLES_PROFILE,"w");
    $sformat(prefix, "[mceliece%0d%0d]", DUT.N, DUT.T);
end

always @(posedge DUT.start_fo)
begin
    time_field_ordering_start <= $time;
   $display("%s FieldOrdering module started.", (prefix));
    $fflush();
end

always @(posedge DUT.done_fo)
begin
    time_field_ordering = ($time-time_field_ordering_start)/2;
   $display("%s FieldOrdering finished. (%0d cycles)", prefix, time_field_ordering);
//($time-time_field_ordering_start)/2);
    $fwrite(f_cycles_profile, "field_ordering %0d %0d\n", time_field_ordering_start/2, ($time-time_field_ordering_start)/2);
    $fflush();
end

always @(posedge start_decap)
begin
    time_decap_start = $time;
    $display("%s Decapsulation module started.", (prefix));
    $fflush();
end

always @(posedge done_decap)
begin
    $display("%s Decapsulation module finished. (%0d cycles) [re-encrypt %s]", prefix, ($time-time_decap_start)/2, DUT.DECAPSULATION.decryption_module.decryption_fail ? "failed" : "succeeded");
    $display("%s FieldOrdering and Decapsulation require %0d cycles.", prefix, time_field_ordering+($time-time_decap_start)/2);
    $fwrite(f_cycles_profile, "decap %0d %0d\n", time_decap_start/2, ($time-time_decap_start)/2);
    $fwrite(f_cycles_profile, "total %0d %0d\n", time_field_ordering_start/2, time_field_ordering+($time-time_decap_start)/2);
    $fflush();
end

// integer f;
// error check
// always @(posedge DUT.decryption_module.done)
// begin
//     f = $fopen(`FILE_ERROR_OUT,"w");
//     for (integer h = 0; h<n; h=h+1) begin
//         $fwrite(f,"%b",DUT.decryption_module.error_recovered[n-1:0]);
//     end
// end

// output file for K
always @(posedge DUT.done_decap)
begin
    $writememb(`FILE_K_OUT, DUT.DECAPSULATION.hash_mem.mem,0,7);
    $fflush();
end

mem_single #(.WIDTH(32), .DEPTH(8), .FILE(`FILE_DELTA) ) mem_init_seed
           (
               .clock(clk),
               .data(0),
               .address(addr_s),
               .wr_en(0),
               .q(seed_from_ram)
           );

mem_single #(.WIDTH(32), .DEPTH(8), .FILE(`FILE_C1)) C1_input_mem
           (
               .clock(clk),
               .data(0),
               .address(addr_C1),
               .wr_en(0),
               .q(C1_in)
           );

mem_single #(.WIDTH(32), .DEPTH(((L + (32-L%32)%32)/32)), .FILE(`FILE_C0) ) C0_input_mem
           (
               .clock(clk),
               .data(0),
               .address(addr_C0),
               .wr_en(0),
               .q(C0_in)
           );

mem_single #(.WIDTH(32), .DEPTH(((PG_WIDTH + (32-PG_WIDTH%32)%32)/32)), .FILE(`FILE_POLYG) ) pg_input_mem
           (
               .clock(clk),
               .data(0),
               .address(addr_pg),
               .wr_en(0),
               .q(poly_g_in)
           );

//------------------------------------------------------------


// integer start_time, start_decap_time, support_gen_time, decap_done_time;

// initial
// begin
//     rst <= 1'b1;
//     addr   = 0;
//     rd_K <= 0;
//     addr_C1 <= 0;
//     addr_C0 <= 0;
//     addr_pg <= 0;
//     C0_valid <= 1'b0;
//     C1_valid <= 1'b0;
//     poly_g_valid <= 1'b0;
//     start_decap <= 1'b0;


//     # 20;
//     rst <= 1'b0;
//     #100
//      start_time = $time;

//     delta <= seed_from_ram; addr <= 1; delta_valid = 1'b1; #10
//     delta <= seed_from_ram; addr <= 2; delta_valid = 1'b1; #10
//     delta <= seed_from_ram; addr <= 3; delta_valid = 1'b1; #10
//     delta <= seed_from_ram; addr <= 4; delta_valid = 1'b1; #10
//     delta <= seed_from_ram; addr <= 5; delta_valid = 1'b1; #10
//     delta <= seed_from_ram; addr <= 6; delta_valid = 1'b1; #10
//     delta <= seed_from_ram; addr <= 7; delta_valid = 1'b1; #10
//     delta <= seed_from_ram;            delta_valid = 1'b1; #10
//     delta_valid <= 1'b0;

//     @(posedge support_gen_done)
//      support_gen_time = ($time-start_time);
//     $display("\n total runtime for Support Generation: %0d cycles\n", (($time-start_time)/10));
//     #100

//      #100


//      //   loading C1
//      #10
//      for (integer j=0; j <= 7; j = j+1) begin
//          #10; addr_C1 <= addr_C1 + 1; C1_valid <= 1'b1;
//      end

//      //   loading C0
//      #10

//       C1_valid <= 1'b0;
//     for (integer i=0; i < ((L + (32-L%32)%32)/32); i = i+1) begin
//         #10; addr_C0 <= addr_C0 + 1; C0_valid <= 1'b1;
//     end

//     //   loading C0
//     #10

//      C0_valid <= 1'b0;
//     for (integer i=0; i < ((PG_WIDTH + (32-PG_WIDTH%32)%32)/32); i = i+1) begin
//         #10; addr_pg <= addr_pg + 1; poly_g_valid <= 1'b1;
//     end


//     #10
//      poly_g_valid <= 1'b0;
//     start_decap <= 1'b1;
//     start_decap_time = $time;

//     #10
//      start_decap <= 1'b0;




//     @(posedge done_decap);
//     decap_done_time = ($time-start_decap_time);
//     $display("\n total runtime for Decapsulation: %0d cycles\n", (($time-start_decap_time)/10));
//     $display("\n total runtime for Support Gen + Decapsulation: %0d cycles\n", ((support_gen_time+decap_done_time)/10));
//     $fflush();

//     $finish;
// end




// always
//     # 5 clk = !clk;

// parameter  delta_mem = (parameter_set == 1)?  "delta_1.in":
//            (parameter_set == 2)? "delta_2.in":
//            (parameter_set == 3)? "delta_3.in":
//            (parameter_set == 4)? "delta_4.in":
//            "delta_5.in";

// mem_single #(.WIDTH(32), .DEPTH(8), .FILE(delta_mem) ) mem_init_seed
//            (
//                .clock(clk),
//                .data(0),
//                .address(addr),
//                .wr_en(0),
//                .q(seed_from_ram)
//            );



// parameter C1_file = (parameter_set == 1)? "C1_1.in":
//           (parameter_set == 2)? "C1_2.in":
//           (parameter_set == 3)? "C1_3.in":
//           (parameter_set == 4)? "C1_4.in":
//           "C1_5.in";

// mem_single #(.WIDTH(32), .DEPTH(8), .FILE(C1_file) ) C1_input_mem
//            (
//                .clock(clk),
//                .data(0),
//                .address(addr_C1),
//                .wr_en(0),
//                .q(C1_in)
//            );


// parameter C0_file =(parameter_set == 1)? "C0_1.in":
//           (parameter_set == 2)? "C0_2.in":
//           (parameter_set == 3)? "C0_3.in":
//           (parameter_set == 4)? "C0_4.in":
//           "C0_5.in";

// mem_single #(.WIDTH(32), .DEPTH(((L + (32-L%32)%32)/32)), .FILE(C0_file) ) C0_input_mem
//            (
//                .clock(clk),
//                .data(0),
//                .address(addr_C0),
//                .wr_en(0),
//                .q(C0_in)
//            );



// parameter poly_g_file =(parameter_set == 1)? "poly_g_1.in":
//           (parameter_set == 2)? "poly_g_2.in":
//           (parameter_set == 3)? "poly_g_3.in":
//           (parameter_set == 4)? "poly_g_4.in":
//           "poly_g_5.in";

// mem_single #(.WIDTH(32), .DEPTH(((PG_WIDTH + (32-PG_WIDTH%32)%32)/32)), .FILE(poly_g_file) ) pg_input_mem
//            (
//                .clock(clk),
//                .data(0),
//                .address(addr_pg),
//                .wr_en(0),
//                .q(poly_g_in)
//            );

endmodule








