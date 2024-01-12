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

//`timescale 1ns/1ps

module encap_tb
       #(
           parameter parameter_set =1,


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
           parameter e_width = 32, // error_width

           parameter n_elim = col_width*((n+col_width-1)/col_width),
           parameter l_n_elim = l*n_elim,
           parameter KEY_START_ADDR = l*(l/col_width),
           parameter BAUD_RATE = 115200,
           parameter CLOCK_FPGA = 1
       )(
           input wire 	clk,
           input wire 	rst,
           output lcd1,
           output wire done
       );

// input
reg seed_valid = 1'b0;
reg K_col_valid = 1'b0;
wire [col_width - 1:0] PK_col;
wire [32-1:0] seed_from_ram;
reg  [32-1:0] seed;

// output
wire PK_ready;

//ram controls
reg [3:0] addr_seed = 0;
reg [`CLOG2((k+(col_width-k%col_width)%col_width)*l/col_width) - 1:0] addr_h = 0;
reg [`CLOG2(l*k/col_width) - 1:0] addr_rd_c = 0;
reg  rd_en_c = 0;

wire [`CLOG2((l_n_elim +(col_width-l_n_elim%col_width)%col_width)/col_width) - 1:0] addr_PK;
wire 																			   PK_rd;

reg rd_C0;
reg [`CLOG2((l + (32-l%32)%32)/32) -1 : 0]C0_addr;
wire [31:0]C0_out;

reg rd_C1;
reg [2:0]C1_addr;
wire [31:0]C1_out;

reg rd_K;
reg [2:0]K_addr;
wire [31:0]K_out;

//shake interface
wire din_valid_shake_enc;
wire [31:0] din_shake_enc;
wire dout_ready_shake_enc;

wire din_ready_shake;
wire dout_valid_shake;
wire [31:0]dout_shake;
wire force_done_shake;

reg led1;
assign lcd1 = led1;
keccak_top shake_instance
           (
               .rst(rst),
               .clk(clk),
               .din_valid(din_valid_shake_enc),
               .din_ready(din_ready_shake),
               .din(din_shake_enc),
               .dout_valid(dout_valid_shake),
               .dout_ready(dout_ready_shake_enc),
               .dout(dout_shake),
               .force_done(force_done_shake)
           );

encap_seq_gen # (.parameter_set(parameter_set), .m(m), .t(t), .n(n), .e_width(e_width), .col_width(col_width), .KEY_START_ADDR(KEY_START_ADDR))
         DUT  (
             .clk(clk),
             .rst(rst),
             .seed_valid(seed_valid),
             .seed(seed),

             .done(done),

             .PK_addr(addr_PK),
             .PK_col(PK_col),
             .PK_rd(PK_rd),

             .rd_C0(0),
             .C0_addr(C0_addr),
             .C0_out(C0_out),

             .rd_C1(0),
             .C1_addr(C1_addr),
             .C1_out(C1_out),

             .rd_K(0),
             .K_addr(K_addr),
             .K_out(K_out),

             //shake interface
             .din_valid_shake_enc(din_valid_shake_enc),
             .din_ready_shake(din_ready_shake),
             .din_shake_enc(din_shake_enc),
             .dout_valid_shake(dout_valid_shake),
             .dout_ready_shake_enc(dout_ready_shake_enc),
             .dout_shake(dout_shake),
             .force_done_shake(force_done_shake)

         );

initial
begin
    $dumpfile(`FILE_VCD);
    $dumpvars();
end

// Memory loading procedure
reg [31:0] ctr = 0;
//reg loading_done = 0;

parameter SIZE_SEED = 16;
parameter SIZE_PK = k*l/col_width;
parameter SIZE_C0 = (l + (32-l%32)%32)/32;
parameter SIZE_C1 = 8;
parameter SIZE_K = 8;

parameter START_SEED = 0;
parameter STOP_SEED = START_SEED + SIZE_SEED;
parameter START_PK = STOP_SEED + 1;
parameter STOP_PK = START_PK + SIZE_PK;
// integer START_C0 = STOP_PK;
// integer STOP_C0 = START_C0 + SIZE_C0;
// integer START_C1 = STOP_C0;
// integer STOP_C1 = START_C1 + SIZE_C1;

integer SIZE_TOTAL = STOP_SEED;

always @(posedge clk)
begin
    if (rst)
    begin
        ctr <= 0;
	   addr_h = 0;
        addr_seed <= 0;
        //  addr_C0 <= 0;
        //  addr_C1 <= 0;
        // addr_PK <= 0;
        // addr_K <= 0;

        seed_valid <= 1'b0;
        K_col_valid <= 1'b0;
        //  rd_C0 <= 1'b0;
        //  rd_C1 <= 1'b0;
        // rd_K <= 1'b0;

    end
    else
    begin
        // Wait until the field ordering module is done.
        if(ctr >= SIZE_TOTAL+1)// || ctr == STOP_SEED && PK_ready == 1'b0)
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
    seed <= seed_from_ram;

    // loading seed
    if (ctr >= START_SEED && ctr < STOP_SEED)
    begin
        seed_valid <= 1'b1;
        if (ctr > START_SEED)
            addr_seed <= addr_seed + 1;
    end
    else
    begin
        addr_seed <= addr_seed;
        seed_valid <= 1'b0;
    end
    // // loading PK
    // if (ctr >= START_PK && ctr < STOP_PK)
    // begin
    //     K_col_valid <= 1'b1;
    //    if (ctr > START_PK)
    //      addr_PK <= addr_PK + 1;
    // end
    // else
    // begin
    //     addr_PK <= addr_PK;
    // end
    // // reading C0
    // if (ctr > START_C0 && ctr <= STOP_C0)
    //   begin
    //      addr_C0 <= addr_C0 + 1;
    //      rd_C0 <= 1'b1;
    //   end
    // else
    //   begin
    //      addr_C0 <= addr_C0;
    //      rd_C0 <= 1'b0;
    //   end
    // // reading C1
    //  if (ctr > START_C1 && ctr <= STOP_C1)
    //  begin
    //      addr_C1 <= addr_C1 + 1;
    //      rd_C1 <= 1'b1;
    //  end
    //  else
    //  begin
    //      addr_C1 <= addr_C1;
    //      rd_C1 <= 1'b0;
    //  end
    //  // reading K
    //  if (ctr > START_K && ctr < STOP_POLY)
    //  begin
    //      addr_K <= addr_K + 1;
    //      rd_K <= 1'b1;
    //  end
    //  else
    //  begin
    //      addr_K <= addr_K;
    //      rd_K <= 1'b0;
    //  end
end

// always @(posedge DUT.done)
// begin
//     K_col_valid <= 1'b0;
// end

/* Clock cycle count profiling */
integer f_cycles_profile;
time    time_encap_start;
time time_encapsulation;
time time_encrypt_start;
time time_encrypt;
time time_fixedweight_start;
time time_fixedweight;

reg [17*8-1:0] prefix;

initial
begin
    f_cycles_profile = $fopen(`FILE_CYCLES_PROFILE,"w");
    $sformat(prefix, "[mceliece%0d%0d]", DUT.n, DUT.t);
end

// always @(posedge DUT.done)
// begin

//     $writememb(`FILE_K_OUT, DUT.hash_mem.mem,0,7);
//     $writememb(`FILE_CIPHER0_OUT, DUT.encryption_unit.encrypt_mem.mem);
//     $writememb(`FILE_CIPHER1_OUT, DUT.C1_mem.mem);
//     $writememb(`FILE_ERROR_OUT, DUT.error_vector_gen.onegen_instance.mem_dual_B.mem);
//     $fflush();
// end

always @(posedge seed_valid)
begin
    time_encap_start = $time;
    $display("%s Start Encapsulation. (%0d cycles)", prefix, time_encap_start/2);
    $fflush();
end

always @(posedge DUT.done)
begin
    led1 <= 1;
    time_encapsulation = ($time-time_encap_start)/2;
    $display("%s Encapsulation finished. (%0d cycles)", prefix, time_encapsulation);
    $fwrite(f_cycles_profile, "encapsulation %0d %0d\n", time_encap_start/2, time_encapsulation);
    $fflush();
end

always @(negedge rst)
begin
    time_fixedweight_start = $time;
    $display("%s Start FixedWeight. (%0d cycles)", prefix, time_fixedweight_start/2);
    $fflush();
end

always @(posedge DUT.done_error)
begin
    time_fixedweight = ($time-time_fixedweight_start)/2;
    $display("%s FixedWeight finished. (%0d cycles)", prefix, time_fixedweight);
    $fwrite(f_cycles_profile, "fixedweight %0d %0d\n", time_fixedweight_start/2, time_fixedweight);
    $fflush();
end

always @(posedge DUT.done_error)
begin
    time_encrypt_start = $time;
    $display("%s Start Encode. (%0d cycles)", prefix, time_encrypt_start/2);
    $fflush();
end

always @(posedge DUT.done_encrypt)
begin
    time_encrypt = ($time-time_encrypt_start)/2;
    $display("%s Encode finished. (%0d cycles)", prefix, time_encrypt);
    $fwrite(f_cycles_profile, "encode %0d %0d\n", time_encrypt_start/2, time_encrypt);
    $fflush();
end

mem_single #(.WIDTH(col_width), .DEPTH(((l_n_elim+(col_width-l_n_elim%col_width)%col_width)/col_width)), .FILE(`FILE_PK_SLICED) ) publickey
           (
               .clock(clk),
               .data(0),
               .address(addr_PK),
               .wr_en(0),
               .q(PK_col)
           );

mem_single #(.WIDTH(32), .DEPTH(16), .FILE(`FILE_MEM_SEED) ) mem_init_seed
           (
               .clock(clk),
               .data(0),
               .address(addr_seed),
               .wr_en(0),
               .q(seed_from_ram)
           );

endmodule
