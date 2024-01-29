/*
 * This file is computes S2.
 *
 * Copyright (C) 2018
 * Authors: Wen Wang <wen.wang.ww349@yale.edu>
 *          Ruben Niederhagen <ruben@polycephaly.org>
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




module doubled_syndrome
  #(
    parameter m = 13,
    parameter t = 119,
    parameter N = 20, // block size
    parameter mem_width = 32,

    parameter l = m*t,
    parameter eva_mem_WIDTH = 2*m*mem_width, //memory width in the add_FFT module, sum of mem_A and mem_B
    parameter eva_mem_WIDTH_bits = `CLOG2(mem_width)+1,
    parameter eva_mem_DEPTH = (1 << (`CLOG2(t+1))), //memory depth in the add_FFT module
    parameter eva_mem_DEPTH_bits = `CLOG2(t+1)
  )
  (
    input  wire                          clk,
    input  wire                          start,
    input  wire [l-1:0]                  cipher, // ciphertext
    output reg                           done = 1'b0,
    
    input  wire [l-1:0]                  P_rd_addr_re_encrypt,
    input  wire [1:0]                    operation,
      //2'b01: calculate doubled syndrome: S_2 = H_2*P*(c | 0)
      //2'b10: for re-encryption in decryption" S' = H_2*recovered_error

    // outside read signals from BM module
    input  wire                          synd_rd_en_in,
    input  wire [`CLOG2(2*t)-1:0]        synd_rd_addr_in,
    output wire [m-1:0]                  synd_A_dout_out,
    
    // output read signals    from decryption module
    input  wire                          re_encrypt_check_rd_en_in,
    input  wire [`CLOG2(2*t)-1:0]        re_encrypt_check_rd_addr_in,
    output wire [m-1:0]                  synd_B_dout_out,

    // memory interface of P
    input  wire [m-1:0]                  P_dout,
    output wire                          P_rd_en,
    output wire [m-1:0]                  P_rd_addr,

    // poly eval interface
    output reg                           eva_rd_en = 1'b0,
    output reg  [eva_mem_DEPTH_bits-1:0] eva_rd_addr = {eva_mem_DEPTH_bits{1'b0}},

    input  wire [eva_mem_WIDTH-1:0]       eva_dout
   );
  
  wire [m-1:0] P_rd_addr_syndrome;
  wire P_rd_en_syndrome;

  reg [`CLOG2(l)-1:0] column_scanned_limit = {`CLOG2(l){1'b0}};
  reg [l-1:0] P_rd_addr_re_encrypt_shifted = {l{1'b0}};

  wire [m-1:0] P_rd_addr_re_encryption;
  wire P_rd_en_re_encryption;

  assign P_rd_en_syndrome = P_rd_en & (operation == 2'b01);
  assign P_rd_en_re_encryption = P_rd_en & (operation == 2'b10);
  
  assign P_rd_addr_re_encryption = P_rd_addr_re_encrypt_shifted[m*t-1:m*(t-1)];
  assign P_rd_addr = P_rd_en_syndrome ? P_rd_addr_syndrome : P_rd_addr_re_encryption;
 
  reg eva_done = 1'b0;

  always @(posedge clk)
    eva_done <= start;
 
   // interface of add_FFT
  reg eva_rd_en_buffer = 1'b0;

  // interface of point_loc
  reg point_loc_start = 1'b0;
  reg point_loc_start_buffer_0 = 1'b0;
  reg point_loc_start_buffer_1 = 1'b0;

  reg [eva_mem_WIDTH_bits-1:0] eva_rd_loc = {eva_mem_WIDTH_bits{1'b0}};
  reg [eva_mem_WIDTH_bits-1:0] eva_rd_loc_buffer = {eva_mem_WIDTH_bits{1'b0}};

  // interface of GFE_inv_H_gen
  wire [m-1:0] inv_din;
  wire [m-1:0] inv_dout;
  wire inv_dout_en;
  wire inv_done;

  // interface of gf multiplier
  reg inv_done_buffer = 1'b0;
//  reg [m-1:0] inv_dout_buffer = {m{1'b0}};
  wire [m-1:0] sq_dout;

  // interface of syndrome memory
  reg [m-1:0] synd_din = {m{1'b0}};
  reg [`CLOG2(2*t)-1:0] synd_rd_addr = {`CLOG2(2*t){1'b0}};
  wire synd_rd_en;
  reg synd_rd_en_buffer_0 = 1'b0;
  reg synd_rd_en_buffer_1 = 1'b0;

  reg [`CLOG2(2*t)-1:0] synd_wr_addr = {`CLOG2(2*t){1'b0}};
  reg synd_wr_en = 1'b0; 
  reg [m-1:0] synd_dout_buffer = {m{1'b0}};

  reg [m-1:0] column_scanned_counter = {m{1'b0}}; // iterate through cipher c
  reg [`CLOG2(l+1)-1:0] cipher_weight_counter = {`CLOG2(l+1){1'b0}};
  reg [`CLOG2(N+1)-1:0] first_row_counter = {`CLOG2(N+1){1'b0}};
  reg [`CLOG2(2*t+2)-1:0] row_counter = {`CLOG2(2*t+2){1'b0}};

  reg [`CLOG2(N+1)-1:0] block_weight_counter = {`CLOG2(N+1){1'b0}};

  wire first_row_done;

  reg [l-1:0] cipher_shift = {l{1'b0}};
  wire cipher_bit = (operation == 2'b01) ? cipher_shift[l-1] : (column_scanned_counter < column_scanned_limit);

  reg first_row = 1'b0;

  reg [N*m-1:0] syndrome_block = {N*m{1'b0}}; 

  reg [N*m-1:0] row_temp = {N*m{1'b0}};
  wire [N*m-1:0] mul_res;

  reg [N*m-1:0] index_block = {N*m{1'b0}};

  reg block_done = 1'b0;
  reg following_rows = 1'b0;

  // the latter done signal among first_row_done and block_done
  wire longer_done;
  assign longer_done = ((first_row_done && !following_rows) | (first_row_done && block_done) | (block_done && !first_row));

  reg [N*m-1:0] xor_vector = {N*m{1'b0}};
  wire [m-1:0] xor_res;
  reg [m-1:0] xor_res_buffer = {m{1'b0}};

  wire weight_N;
  assign weight_N = (block_weight_counter == N);
  reg weight_N_buffer = 1'b0;
  wire weight_N_point;
  assign weight_N_point = (weight_N && (!weight_N_buffer));

  reg shift_en_long = 1'b0; 
  wire shift_en;
  assign shift_en = (shift_en_long && (!weight_N_point));

  reg last_block_done_1_buffer [1: (eva_mem_WIDTH_bits+6)];

  wire last_block_done_buffer;
  assign last_block_done_buffer = (last_block_done_1_buffer[eva_mem_WIDTH_bits+4] && (!last_block_done_1_buffer[eva_mem_WIDTH_bits+5]));
  reg last_block_done = 1'b0;
  
  reg non_first_block = 1'b0; 

  wire [m-1:0] synd_dout;

  assign synd_dout = (operation == 2'b01) ? synd_A_dout_out :
                           synd_B_dout_out;

  wire [`CLOG2(2*t)-1:0] synd_A_rd_addr_in;
  assign synd_A_rd_addr_in = synd_rd_en_in ? synd_rd_addr_in :
                             re_encrypt_check_rd_en_in ? re_encrypt_check_rd_addr_in :
                             synd_rd_addr;

  wire synd_A_rd_en;
  assign synd_A_rd_en = synd_rd_en_in ? 1'b1 :
                        re_encrypt_check_rd_en_in ? 1'b1 :
                        synd_rd_en;

  always @(posedge clk) begin
    P_rd_addr_re_encrypt_shifted <= start ? P_rd_addr_re_encrypt : 
                                    P_rd_en_re_encryption ? (P_rd_addr_re_encrypt_shifted << m) :
                                    P_rd_addr_re_encrypt_shifted;

    column_scanned_limit <= (operation == 2'b01) ? l : t;
  end
	
  always @(posedge clk)
    begin
      non_first_block <= (start | done) ? 1'b0 :
                          block_done ? 1'b1 :
                          non_first_block;
    end

  integer p;
  initial
    begin
      for (p = 1; p <= (eva_mem_WIDTH_bits+6); p=p+1)
        last_block_done_1_buffer[p] = 1'b0;
    end

  // here need to generate one clock high signal
  always @(posedge clk)
    begin
      last_block_done_1_buffer[1] <= start ? 1'b0 :
                                     (column_scanned_counter == column_scanned_limit) ? 1'b1 :
                                     last_block_done_1_buffer[1];
     end

  genvar q;
  generate
    for (q=1; q < (eva_mem_WIDTH_bits+6); q=q+1)
      begin: gen_last_block_done_1_buffers
        always @(posedge clk)
          last_block_done_1_buffer[q+1] <= last_block_done_1_buffer[q];
      end
  endgenerate
  
  reg running = 1'b0;
  reg [1:0] done_counter = 2'b0;
  reg longer_done_buffer = 1'b0; 
  
  always @(posedge clk)
    begin
      running <= start ? 1'b1 :
                 done ? 1'b0 :
                 running;
      
      done_counter <= start ? 2'b0 :
                      ((column_scanned_counter == column_scanned_limit) && longer_done) ? done_counter + 1 :
                      done_counter;

      longer_done_buffer <= longer_done;

      done <= (done_counter == 2) && longer_done_buffer;
    end
  
 
  wire syndrome_eva_done;
  assign syndrome_eva_done = (running && eva_done);

  always @(posedge clk)
    begin
      // prepare for the first row block
      // first_row: prepare for the first row
      first_row <= ((syndrome_eva_done | longer_done) && (column_scanned_counter < column_scanned_limit)) ? 1'b1 :
                   (start | first_row_done) ? 1'b0 :
                    first_row;

      // calculate the following rows
      following_rows <= longer_done ? 1'b1 :
                        (start | block_done) ? 1'b0 :
                        following_rows;

      first_row_counter <= (start | first_row_done | done) ? {`CLOG2(N+1){1'b0}} :
                            inv_done_buffer ? first_row_counter + 1 :
                            first_row_counter;

       // one cycle longer than actual shift_en signal
      weight_N_buffer <= weight_N;

      shift_en_long <= (start | weight_N_point | done) ? 1'b0 :
                       (syndrome_eva_done | longer_done) & running ? 1'b1 :
                        shift_en_long;

      cipher_shift <= start ? cipher :
                      shift_en ? (cipher_shift << 1) :
                      cipher_shift;

      // count the bits in cipher c
      column_scanned_counter <= (start | done) ? {m{1'b0}} :
                                (shift_en && (column_scanned_counter < column_scanned_limit)) ? column_scanned_counter + 1 :
                                 column_scanned_counter;

      // count the weight of cipher c
      cipher_weight_counter <= (start | done) ? {`CLOG2(l+1){1'b0}} :
                               (shift_en && cipher_bit) ? cipher_weight_counter + 1 :
                               cipher_weight_counter;

      block_weight_counter <= (start | longer_done | done) ? {`CLOG2(N+1){1'b0}} :
                              (shift_en && cipher_bit) ? block_weight_counter + 1 :
                              block_weight_counter;

      // read g(alpha) from add_FFT's data memory
      eva_rd_en_buffer <= shift_en;
      eva_rd_en <= eva_rd_en_buffer;

      eva_rd_addr <= (P_dout >> eva_mem_WIDTH_bits);

      point_loc_start_buffer_0 <= (cipher_bit && shift_en); // only do calculation when c_i is "1"
      point_loc_start_buffer_1 <= point_loc_start_buffer_0;
      point_loc_start <= point_loc_start_buffer_1;

      eva_rd_loc_buffer <= (P_dout % (1 << eva_mem_WIDTH_bits));
      eva_rd_loc <= eva_rd_loc_buffer;

      // (g(alpha))^-2 by use of gf multiplier
//      inv_dout_buffer <= inv_dout; // inversion module's output is already buffered

      inv_done_buffer <= inv_done;

      // construct the first row for syndrome calculation (xor) + index vector for later multiplication
      index_block <= (start | longer_done) ? {N*m{1'b0}} :
                     point_loc_start_buffer_0 ? ((index_block << m) ^ {{(N-1)*m{1'b0}}, P_dout}) :
                     index_block;

      syndrome_block <= (start | longer_done) ? {N*m{1'b0}} :
                        inv_done_buffer ? ((syndrome_block << m) ^ {{(N-1)*m{1'b0}}, sq_dout}) :
                        syndrome_block;

      // calculation of the rest rows
      row_counter <= (start | done) ? {`CLOG2(2*t+2){1'b0}} :
                     longer_done ? 1 :
                     (row_counter > 0) ? row_counter + 1 :
                     row_counter;

      row_temp <= longer_done ? syndrome_block :
                  mul_res;

      block_done <= (row_counter == (2*t+1)); //depends on your design

      xor_vector <= longer_done ? syndrome_block :
                    mul_res;

      xor_res_buffer <= xor_res;

      // syndrome memory interface

      synd_rd_addr <= (start | (synd_rd_addr == (2*t-1)) | done) ? {`CLOG2(2*t){1'b0}} :
                      synd_rd_en ? synd_rd_addr + 1 :
                      synd_rd_addr;

	    synd_dout_buffer <= (synd_rd_en_buffer_0 && non_first_block) ? synd_dout : {m{1'b0}};

      synd_din <= (xor_res_buffer ^ synd_dout_buffer);

      synd_rd_en_buffer_0 <= synd_rd_en;
      synd_rd_en_buffer_1 <= synd_rd_en_buffer_0;

      synd_wr_en <= (done_counter == 2) ? 1'b0 :
                    synd_rd_en_buffer_1;

      synd_wr_addr <= (start | longer_done | done) ? {`CLOG2(2*t){1'b0}} :
                      synd_wr_en ? synd_wr_addr + 1 :
                      synd_wr_addr;

      last_block_done <= start ? 1'b0 :
                         last_block_done_buffer;

    end


  reg [N*m-1:0] index_block_delayed = {N*m{1'b0}};

  always @(posedge clk)
    begin
      index_block_delayed <= longer_done ? index_block :
                             index_block_delayed;
    end

  // construction of the first row is done
  assign first_row_done = ((first_row_counter == N) | last_block_done);

  assign P_rd_en = shift_en;
  assign P_rd_addr_syndrome = column_scanned_counter;

  assign synd_rd_en = longer_done | ((row_counter > 0) && (row_counter < 2*t));

  // basis = {1, a, a^2, ..., a^12} instead of {a^12, a^11, ..., a, 1}
  wire [N*m-1:0] alpha_block;
  genvar k;
  generate
    for (k=0; k < N*m; k=k+1)
      begin : gen_alpha
        assign alpha_block[k] = index_block_delayed[m*(k/m)+m-(k%m)-1];
      end
  endgenerate
 
  wire [m-1:0] dout_B;
  wire dout_en_B;

  point_loc point_loc_inst (
    .start(point_loc_start),
    .clk(clk),
    .location(eva_rd_loc),
    .data_in(eva_dout),
    .data_out(inv_din),
    .done(inv_done)
  );

  gf_inv_syndrome #(.DELAY(1)) gf_inv_syndrome_inst (
    .clk(clk),
    .din_A(inv_din),
    .dout_A(inv_dout),
    .dout_en_A(inv_dout_en),
    .din_B(0),
    .dout_B(dout_B),
    .dout_en_B(dout_en_B)
  );

  gf_sq gf_sq_syndrome_inst (
    .clk(clk),
//    .din(inv_dout_buffer),
    .din(inv_dout),
    .dout(sq_dout)
  );

  vec_mul_syndrome vec_mul_syndrome_inst (
    .clk(clk),
    .vec_a(row_temp),
    .vec_b(alpha_block),
    .vec_c(mul_res)
  );

  entry_xor entry_xor_inst (
    .vector(xor_vector),
    .res(xor_res)
  );

	mem #(.WIDTH(m), .DEPTH(2*t), .INIT(1)) mem_synd_A (
    .clock (clk),
    .data (synd_din),
    .rdaddress (synd_A_rd_addr_in),
    .rden (synd_A_rd_en),
    .wraddress (synd_wr_addr),
    .wren (synd_wr_en & (operation == 2'b01)),
    .q (synd_A_dout_out)
  );

  mem #(.WIDTH(m), .DEPTH(2*t), .INIT(1)) mem_synd_B (
    .clock (clk),
    .data (synd_din),
    .rdaddress (synd_rd_en? synd_rd_addr : re_encrypt_check_rd_addr_in),
    .rden (synd_rd_en ? 1'b1 : re_encrypt_check_rd_en_in),
    .wraddress (synd_wr_addr),
    .wren (synd_wr_en & (operation == 2'b10)),
    .q (synd_B_dout_out)
  );

endmodule

