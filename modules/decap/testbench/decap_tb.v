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

module decap_tb
       #(
           parameter parameter_set =4,


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

           parameter col_width = 128,
           parameter e_width = 128 // error_width



       )
       (
           input wire  clk,
           input wire  rst,
           input wire  start,
           output reg loading_done = 1'b0,
           output wire done
       );

//ram controls
reg [2:0] addr;

reg [`CLOG2((n + (32-n%32)%32)/32) -1 : 0]addr_s = 0, s_addr_reg = 0;
wire [31:0]s_in;
reg s_valid = 0;

reg [`CLOG2((l + (32-l%32)%32)/32) -1 : 0] addr_C0  = 0;
wire [31:0]C0_in;
reg C0_valid = 0;

wire C1_ready;
reg C1_valid = 0;
wire [31:0]C1_in;
reg [2:0] addr_C1  = 0;

reg [`CLOG2((PG_WIDTH + (32-PG_WIDTH%32)%32)/32) -1 : 0]addr_pg = 0;
wire [31:0]poly_g_in;
reg poly_g_valid = 0;
wire poly_g_ready;

reg rd_K;
reg [2:0]K_addr;
wire [31:0]K_out;

reg [n-1:0]error;
reg done_error;
reg decryption_fail;
//reg start;

wire [m-1:0] P_dout,P_dout_rev;
wire P_rd_en;
wire [m-1:0] P_rd_addr;

//shake interface
wire din_valid_shake_dec;
wire [31:0] din_shake_dec;
wire dout_ready_shake_dec;

wire din_ready_shake;
wire dout_valid_shake;
wire [31:0]dout_shake;

keccak_top shake_instance
           (
               .rst(rst),
               .clk(clk),
               .din_valid(din_valid_shake_dec),
               .din_ready(din_ready_shake),
               .din(din_shake_dec),
               .dout_valid(dout_valid_shake),
               .dout_ready(dout_ready_shake_dec),
               .dout(dout_shake),
               .force_done(0)
           );

decap # (.parameter_set(parameter_set), .m(m), .t(t), .n(n))
      DUT  (
          .clk(clk),
          .rst(rst),

          .done(done),

          .start (start),

          .s_wr_en(s_valid),
          .s_in(s_in),
          .s_addr(s_addr_reg),

          .C0_valid(C0_valid),
          .C0_in(C0_in),
          .C0_ready(C0_ready),

          .C1_valid(C1_valid),
          .C1_in(C1_in),
          .C1_ready(C1_ready),

          .poly_g_valid(poly_g_valid),
          .poly_g_in(poly_g_in),
          .poly_g_ready(poly_g_ready),

          .P_dout(P_dout_rev),
          .P_rd_en(P_rd_en),
          .P_rd_addr(P_rd_addr),

          .rd_K(rd_K),
          .K_addr(K_addr),
          .K_out(K_out),

          //shake interface
          .din_valid_shake_dec(din_valid_shake_dec),
          .din_ready_shake(din_ready_shake),
          .din_shake_dec(din_shake_dec),
          .dout_valid_shake(dout_valid_shake),
          .dout_ready_shake_dec(dout_ready_shake_dec),
          .dout_shake(dout_shake)
      );

genvar i;
generate
    for (i=0; i<m; i=i+1) begin
        assign P_dout_rev[i] = P_dout[m-i-1];
    end
endgenerate

always@(posedge clk)
begin
    s_addr_reg <= addr_s;
end

assign done_error = DUT.done_error;

reg [31:0] ctr = 0;
//reg loading_done = 0;

integer SIZE_S = (n + (32-n%32)%32)/32 -1;
integer SIZE_C1 = 8;
integer SIZE_C0 = ((l + (32-l%32)%32)/32);
integer SIZE_POLY = ((PG_WIDTH + (32-PG_WIDTH%32)%32)/32);

integer START_S = 0;
integer STOP_S = SIZE_S + 2;
integer START_C1 = STOP_S + 1;
integer STOP_C1 = START_C1 + SIZE_C1;
integer START_C0 = STOP_C1;
integer STOP_C0 = START_C0 + SIZE_C0;
integer START_POLY = STOP_C0;
integer STOP_POLY = START_POLY + SIZE_POLY + 1;

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
        loading_done <= 1'b0;
    end
    else
    begin
        if (ctr < SIZE_S + SIZE_C0 + SIZE_C1 + SIZE_POLY)
        begin
            ctr <= ctr + 1;
            loading_done <= 1'b0;
        end
        else
            if (ctr == 255)
            begin
                ctr <= ctr + 1;
                loading_done <= 1'b1;
            end
            else
            begin
                ctr <= ctr;
                loading_done <= 1'b0;
            end
    end
end

always @(posedge clk)
begin
    // reset for one cycle
    //rst <= (ctr == 5) ? 1'b1 : 1'b0;

    //delta <= seed_from_ram;
    // loading s
    if (ctr > START_S && ctr <= STOP_S)
    begin
        addr_s <= addr_s + 1;
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
end

integer start_time;
integer clk_cnt = 0;

initial
begin
    $dumpfile(`FILE_VCD);
    $dumpvars();
end

/* Clock cycle count profiling */
integer f_cycles_profile;
time    time_start;
reg [17*8-1:0] prefix;

initial
begin
    f_cycles_profile = $fopen(`FILE_CYCLES_PROFILE,"w");
    $sformat(prefix, "[mceliece%0d%0d]", DUT.n, DUT.t);
end

always @(posedge clk)
begin
    clk_cnt++;
    if(DUT.state_hr == DUT.s_start_decryption && DUT.C0_loaded && DUT.poly_g_loaded)
    begin
        time_start <= clk_cnt;
        $display("%s Decapsulation module started.", (prefix));
        $fflush();
    end
end

always @(posedge DUT.done)
begin
    $display("%s Decapsulation module finished. (%0d cycles) [re-encrypt %s]", prefix, (clk_cnt-time_start), DUT.decryption_module.decryption_fail ? "failed" : "succeeded");
    $fwrite(f_cycles_profile, "total %0d %0d\n", time_start, (clk_cnt-time_start));
    $fflush();
end

integer f;
// error check
always @(posedge DUT.decryption_module.done)
begin
    f = $fopen(`FILE_ERROR_OUT,"w");
    for (integer h = 0; h<n; h=h+1) begin
        $fwrite(f,"%b",DUT.decryption_module.error_recovered[n-1:0]);
    end
end

// output file for K
always @(posedge DUT.done)
begin
    $writememb(`FILE_K_OUT, DUT.hash_mem.mem,0,7);
    $fflush();
end

mem_single #(.WIDTH(32), .DEPTH(8), .FILE(`FILE_C1)) C1_input_mem
           (
               .clock(clk),
               .data(0),
               .address(addr_C1),
               .wr_en(0),
               .q(C1_in)
           );

mem_single #(.WIDTH(32), .DEPTH(((l + (32-l%32)%32)/32)), .FILE(`FILE_C0) ) C0_input_mem
           (
               .clock(clk),
               .data(0),
               .address(addr_C0),
               .wr_en(0),
               .q(C0_in)
           );

mem_single #(.WIDTH(32), .DEPTH(((n + (32-n%32)%32)/32)), .FILE(`FILE_S) ) s_input_mem
           (
               .clock(clk),
               .data(0),
               .address(addr_s),
               .wr_en(0),
               .q(s_in)
           );

mem_single #(.WIDTH(32), .DEPTH(((PG_WIDTH + (32-PG_WIDTH%32)%32)/32)), .FILE(`FILE_POLYG) ) pg_input_mem
           (
               .clock(clk),
               .data(0),
               .address(addr_pg),
               .wr_en(0),
               .q(poly_g_in)
           );


// simulate dual-memory P
wire [m-1:0] dout;

mem_dual #(.WIDTH(m), .DEPTH(1 << m), .FILE(`FILE_P)) mem_dual_P (
             .clock(clk),
             .data_0(0),
             .data_1(0),
             .address_0(P_rd_addr),
             .address_1(0),
             .wren_0(1'b0),
             .wren_1(1'b0),
             .q_0(P_dout),
             .q_1(dout)
         );

endmodule








