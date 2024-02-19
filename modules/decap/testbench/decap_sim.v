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

module decap_sim
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
           output wire support_gen_done,

           /*UART_module*/
           input i_uart_rx,
           output wire o_uart_tx
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
reg [63:0] time_counter_start;
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
/* Clock cycle count profiling */
integer f_cycles_profile;
reg [63:0]    time_decap_start;
reg [63:0]    time_field_ordering_start;
reg [63:0] time_field_ordering;
reg [63:0] time_decap_finish;
reg [63:0] time_total;
reg [63:0] time_require;
reg [17*8-1:0] prefix;

/************UART Protocol******************/
parameter DATA_LENGTH_TIME = 24;
parameter DATA_LENGTH_K = 32;
parameter RAW_DATA_LENGTH = DATA_LENGTH_TIME + DATA_LENGTH_K;
//Configure Baudrate
localparam  DBITS = 8,                                                  // 8 bit Data
            SB_TICK = 16,                                               // Sb tick
            DATA_LENGTH = RAW_DATA_LENGTH,                              // String length of the Data buffer    
            BR_LIMIT = CLOCK_FPGA/(BAUD_RATE*SB_TICK),                              // Baudrate limit
            BR_BITS = `CLOG2(BR_LIMIT);                                // Counter limit

//Receive data FSM
parameter [1:0] STATE_IDLE      = 2'b00,
                STATE_TYPE      = 2'b01,
                STATE_LENGTH    = 2'b10,
                STATE_VALUE     = 2'b11;
//Decap mode
parameter [2:0] STATE_START_MODE            = 3'b000,
                STATE_DELTA                 = 3'b001,
                STATE_C1                    = 3'b100,
                STATE_C0                    = 3'b101,
                STATE_POLY                  = 3'b110,
                STATE_DECAP                 = 3'b011,
                STATE_STOP                  = 3'b111;
parameter [1:0] STATE_TX_START      = 2'b00,
                STATE_TX_SEND      = 2'b01,
                STATE_TX_STOP     = 2'b11;
reg tx_Send;                                    
wire tx_done;
wire rx_done;
wire tick;
wire [DBITS-1:0] rx_data_out;                           // Rx Data which receive from Rx module
reg  [DBITS-1:0] tx_Data_Buffer[0:DATA_LENGTH];      // Initial tx Data Buffer
reg  [DBITS-1:0] tx_Data_Buffer_1[0:DATA_LENGTH];      // Initial tx Data Buffer
reg  [DBITS-1:0] tx_data_in;                            // Tx Data input to transfer
reg  [8:0] tx_index;                                   // Tx module index
integer STDERR = 32'h8000_0002;

reg [1:0] rx_current_state;
reg [2:0] decap_current_state;
reg [2:0] tx_current_state;


//Register to store the current TLV data byte
reg [DBITS-1:0] tlv_data_byte;
reg [DBITS-1:0] tlv_type_reg;
reg [(DBITS*3-1):0] tlv_length_reg;
reg [DBITS-1:0] tlv_length_reg_check;
reg [DBITS-1:0] tlv_value_reg;
reg [(DBITS*3-1):0] data_tlv_length;

reg [3:0] tlv_size_of_length_data;
reg[40-1:0] DATA_LENGTH_SEND = 0;
/************Memory loading procedure******************/
// Memory loading procedure
reg [31:0] ctr = 0;
reg [1:0] data_index;
reg [32-1:0] mem_data;
reg write_en_set_delta;
reg write_en_set_c1;
reg write_en_set_c0;
reg write_en_set_poly;
reg [1:0] data_set_delta;
reg [1:0] data_set_c1;
reg [1:0] data_set_c0;
reg [1:0] data_set_poly;
//reg loading_done = 0;
integer i;
integer j;
parameter SIZE_S = 8;
parameter SIZE_C1 = 8;
parameter SIZE_C0 = ((L + (32-L%32)%32)/32);
parameter SIZE_POLY = ((PG_WIDTH + (32-PG_WIDTH%32)%32)/32);

parameter START_S = 0;
parameter STOP_S = SIZE_S + 2;
parameter START_C1 = STOP_S + 1;
parameter STOP_C1 = START_C1 + SIZE_C1;
parameter START_C0 = STOP_C1;
parameter STOP_C0 = START_C0 + SIZE_C0;
parameter START_POLY = STOP_C0;
parameter STOP_POLY = START_POLY + SIZE_POLY + 1;

parameter SIZE_TOTAL = STOP_POLY;//SIZE_S + SIZE_C0 + SIZE_C1 + SIZE_POLY;

baud_rate_generator #(.N(BR_BITS),.M(BR_LIMIT)) 
            BAUD_RATE_GEN   
            (
                .clk(clk), 
                .reset(rst),
                .tick(tick)
            );

Receiver #(.DBITS(DBITS),.SB_TICK(SB_TICK))
            UART_RX_UNIT
            (
                .clk(clk),
                .reset(rst),
                .rx(i_uart_rx),
                .sample_tick(tick),
                .data_ready(rx_done),
                .data_out(rx_data_out)
            ); 
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

Transmitter #(.DBITS(DBITS),.SB_TICK(SB_TICK)) 
            UART_TX_UNIT
            (
                .clk(clk),
                .reset(rst),
                .tx_start(tx_Send),
                .sample_tick(tick),
                .data_in(tx_data_in),
                .tx_done(tx_done),
                .tx(o_uart_tx)
            );
// ------------------------------------------------------


always @(posedge clk ) begin
    if(rst)
    begin
        rx_current_state <= STATE_IDLE;
    end
    else
    begin
           case (rx_current_state)
            STATE_IDLE: begin
                        if(rx_data_out != 8'd0 && (rx_done))
                        begin
                            rx_current_state <= STATE_TYPE;
                            tlv_data_byte <= rx_data_out;
                        end
            end
            STATE_TYPE: begin
                        if(rx_done)
                        begin
                            tlv_type_reg <= tlv_data_byte;
                            tlv_data_byte <= rx_data_out;
                            tlv_length_reg_check <= rx_data_out;

                            rx_current_state <= STATE_LENGTH;
                        end
            end
            STATE_LENGTH: begin
                        if((tlv_length_reg_check > 8'h7f) && (tlv_size_of_length_data == 0))
                        begin
                            tlv_size_of_length_data <= (tlv_length_reg_check & 8'b01111111) + 1;

                        end
                        if(tlv_size_of_length_data == 8'd1 || tlv_length_reg_check < 8'h7f)
                        begin
                            rx_current_state <= STATE_VALUE;

                            if(tlv_length_reg_check < 8'h7f)
                            begin
                                tlv_length_reg <= tlv_data_byte;
                            end
                        end
                        else
                        begin
                            if(rx_done)
                            begin
                                tlv_data_byte <= rx_data_out;
                                tlv_size_of_length_data <= tlv_size_of_length_data - 1;
                                tlv_length_reg <= (tlv_length_reg | (rx_data_out << 8*(tlv_size_of_length_data-2)));  
                            end
                        end
            end
            STATE_VALUE: begin
                        if((tlv_length_reg == 8'b0))
                        begin
                            rx_current_state <= STATE_IDLE;
                            // tlv_size_of_length_data <= 4'd0;
                            // data_tlv_length <= 24'd0;
                        end
                        else
                        begin
                            if(rx_done)
                            begin                  
                                tlv_length_reg <= tlv_length_reg - 1'b1;
                                tlv_value_reg <= rx_data_out;
                            end
                        end
            end
        default: tlv_data_byte <= rx_data_out;
        endcase 
    end
end

// /***************START Decapsulation*************************/
always @(posedge clk ) begin
    if(rst)
    begin
        decap_current_state <= STATE_START_MODE;
    end
    else
    begin
        case (decap_current_state)
          STATE_START_MODE  : begin
                            if((tlv_type_reg == 8'd1)&& (rx_current_state == STATE_VALUE))
                            begin
                                decap_current_state <= STATE_DELTA;               
                            end
                            else if((tlv_type_reg == 8'd2)&& (rx_current_state == STATE_VALUE))
                            begin
                                decap_current_state <= STATE_C1;               
                            end
                            else if((tlv_type_reg == 8'd3)&& (rx_current_state == STATE_VALUE))
                            begin
                                decap_current_state <= STATE_C0;               
                            end
                            else if((tlv_type_reg == 8'd4)&& (rx_current_state == STATE_VALUE))
                            begin
                                decap_current_state <= STATE_POLY;               
                            end
                            else if((tlv_type_reg == 8'd5)&& (rx_current_state == STATE_VALUE))
                            begin
                                decap_current_state <= STATE_DECAP;              
                            end 
          end
          STATE_DELTA       : begin
                            if(rx_done)
                            begin
                                data_index <= data_index + 1;
                                if(data_index == 0)
                                begin
                                    mem_data <= rx_data_out << 24;
                                    write_en_set_delta <= 1'd0;
                                end
                                else
                                begin
                                    mem_data <= mem_data | (rx_data_out << 8*(3-data_index));
                                    if(data_index == 3)
                                    begin
                                        write_en_set_delta <= 1'd1;
                                        ctr <= ctr + 1;
                                        if(ctr > 0)
                                        begin
                                            addr_s <= addr_s + 1;
                                        end
                                    end
                                end
                            end
                            if(tlv_length_reg == 0)
                            begin
                                decap_current_state <= STATE_STOP;
                            end
          end
          STATE_C1          : begin
                            if(rx_done)
                            begin
                                data_index <= data_index + 1;
                                if(data_index == 0)
                                begin
                                    mem_data <= rx_data_out << 24;
                                    write_en_set_c1 <= 1'd0;
                                end
                                else
                                begin
                                    mem_data <= mem_data | (rx_data_out << 8*(3-data_index));
                                    if(data_index == 3)
                                    begin
                                        write_en_set_c1 <= 1'd1;
                                        ctr <= ctr + 1;
                                        if(ctr > 0)
                                        begin
                                            addr_C1 <= addr_C1 + 1;
                                        end
                                    end
                                end
                            end
                            if(tlv_length_reg == 0)
                            begin
                                decap_current_state <= STATE_STOP;
                            end
          end
          STATE_C0          : begin
                            if(rx_done)
                            begin
                                data_index <= data_index + 1;
                                if(data_index == 0)
                                begin
                                    mem_data <= rx_data_out << 24;
                                    write_en_set_c0 <= 1'd0;
                                end
                                else
                                begin
                                    mem_data <= mem_data | (rx_data_out << 8*(3-data_index));
                                    if(data_index == 3)
                                    begin
                                        write_en_set_c0 <= 1'd1;
                                        ctr <= ctr + 1;
                                        if(ctr > 0)
                                        begin
                                            addr_C0 <= addr_C0 + 1;
                                        end
                                    end
                                end
                            end
                            if(tlv_length_reg == 0)
                            begin
                                decap_current_state <= STATE_STOP;
                            end
          end
          STATE_POLY        : begin
                            if(rx_done)
                            begin
                                data_index <= data_index + 1;
                                if(data_index == 0)
                                begin
                                    mem_data <= rx_data_out << 24;
                                    write_en_set_poly <= 1'd0;
                                end
                                else
                                begin
                                    mem_data <= mem_data | (rx_data_out << 8*(3-data_index));
                                    if(data_index == 3)
                                    begin
                                        write_en_set_poly <= 1'd1;
                                        ctr <= ctr + 1;
                                        if(ctr > 0)
                                        begin
                                            addr_pg <= addr_pg + 1;
                                        end
                                    end
                                end
                            end
                            if(tlv_length_reg == 0)
                            begin
                                decap_current_state <= STATE_STOP;
                            end
          end
          STATE_DECAP:      begin
                            delta <= seed_from_ram;
                            start_decap <= 1'b0;
                            if(ctr >= SIZE_TOTAL+1 || ctr == STOP_S && support_gen_done == 1'b0)
                            begin
                                ctr <= ctr;
                                if(ctr >= SIZE_TOTAL+1 && tlv_length_reg == 0)
                                     decap_current_state <= STATE_STOP;
                            end
                            else
                            begin
                                if (ctr < SIZE_TOTAL+1)
                                begin
                                    ctr <= ctr + 1;
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
                                    if(ctr > START_C0 && ctr <= STOP_C0)
                                    begin
                                        addr_C0 <= addr_C0 + 1;
                                        C0_valid <= 1'b1;
                                    end
                                    else
                                    begin
                                        addr_C0 <= addr_C0;
                                        C0_valid <= 1'b0; 
                                    end
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
                                    // if(ctr >= 68035 && ctr <= 68051)
                                    // begin         
                                    //     if(ctr > START_C1 && DUT.hash_mem.wren_1 == 0)
                                    //     begin
                                    //         K_addr <= K_addr + 1;
                                    //         K_data_buffer[K_addr] <= K_out;   
                                    //     end
                                    // end             
                                end                                              
                            end             
          end   
          STATE_STOP        : begin
                            if((rx_data_out != 8'b0) && (rx_done))
                            begin
                                decap_current_state <= STATE_START_MODE;
                            end
                            ctr <= 31'd0;
                            addr_s <= 3'd0;
                            addr_C1 <= 3'd0;
                            addr_C0 <= 5'd0;
                            addr_pg <= 5'd0;
                            write_en_set_delta <= 1'b0;
                            write_en_set_poly <= 1'b0;
                            write_en_set_c1 <= 1'd0;
                            write_en_set_c0 <= 1'd0;           
          end
            default: tlv_value_reg <= 8'd0;
        endcase
    end
end

// /***************TRANSFER PROCSSESS*******************/
always @(posedge clk) begin
    if(decap_current_state == STATE_C0)
    begin
        if(tlv_length_reg == 0)
        begin
            data_set_c0 = 1'b1; 
        end
    end
    else if(decap_current_state == STATE_C1)
    begin
        if(tlv_length_reg == 0)
        begin
            data_set_c1 = 1'b1;  
        end
    end
    else if(decap_current_state == STATE_DELTA)
    begin
        if(tlv_length_reg == 0)
        begin
            data_set_delta = 1'b1; 
        end
    end
    else if(decap_current_state == STATE_POLY)
    begin
        if(tlv_length_reg == 0)
        begin
            data_set_poly = 1'b1;
        end
    end

    if(tx_current_state == STATE_TX_SEND)
    begin
        tx_data_in <= tx_Data_Buffer[tx_index];
            if((data_set_c0 == 1) || (data_set_c1 == 1) || (data_set_delta == 1) || (data_set_poly == 1))
            begin
                tx_Data_Buffer[0] <= 8'd1;
                if(data_set_c0 == 1)
                begin
                    $display("%s Send C0 data completed", prefix);
                    data_set_c0 = 1'b0;
                end
                else if (data_set_c1 == 1)
                begin
                    $display("%s Send C1 data completed", prefix);
                    data_set_c1 = 1'b0;
                  //  led7 <= 1;
                end
                else if (data_set_delta == 1)
                begin
                    $display("%s Send Delta data completed", prefix);
                    data_set_delta = 0;
                end
                else if (data_set_poly == 1)
                begin
                    $display("%s Send Poly data completed", prefix);
                    data_set_poly = 0;
                end
            end        
    end
    if(done_decap)
    begin
        //led7 <=1;
        for(i = 0; i < (DATA_LENGTH_TIME/3); i= i +1) // FieldOrdering finished.
        begin
            tx_Data_Buffer[i] = (((time_field_ordering)) >> 8*i) & 8'hff; // /2           
        end
        for(i = 8; i < (DATA_LENGTH_TIME-8); i = i +1) // Decapsulation finished
        begin
             tx_Data_Buffer[i] = (time_decap_finish >> 8*(i-8)) & 8'hff;
        end
        for(i = 16; i <(DATA_LENGTH_TIME); i = i +1) // Tolal time
        begin
             tx_Data_Buffer[i] = (time_require >> 8*(i-16)) & 8'hff;
        end
        for(i = DATA_LENGTH_TIME; i < DATA_LENGTH_TIME + DATA_LENGTH_K; i = i + 1) //Write to cipher_o file
        begin
            if(i - DATA_LENGTH_TIME == 4*(j+1))
            begin
                j = j + 1;
            end
             tx_Data_Buffer[i] = (DUT.DECAPSULATION.hash_mem.mem[j] >> 8*(i-(DATA_LENGTH_TIME + 4*j)));
            //test [(i-(144 + 4*j))] <= (DUT.encryption_unit.encrypt_mem.mem[j] >> 8);
        end
    end
end
always @(posedge clk ) begin
    if(rst)
    begin
        tx_current_state <= STATE_TX_START;
    end
    else
    begin
        case (tx_current_state)
           STATE_TX_START   : begin
                            if((DUT.done_decap) || (data_set_c0) || (data_set_c1) || (data_set_poly) || (data_set_delta))
                            begin
                                tx_current_state <= STATE_TX_SEND;
                                tx_Send <= 1'b1;
                                if((data_set_c0) || (data_set_c1) || (data_set_poly) || (data_set_delta))
                                begin
                                    DATA_LENGTH_SEND = 16; 
                                end
                                else
                                begin
                                    DATA_LENGTH_SEND = DATA_LENGTH;
                                end
                            end
           end
           STATE_TX_SEND    : begin
                            if((tx_done) && (tx_index == DATA_LENGTH_SEND))
                            begin
                                tx_index <= 6'd0;
                                tx_current_state <= STATE_TX_STOP;
                            end
                            else
                            begin
                                if(tx_done)
                                begin
                                    tx_index <= tx_index + 1; 
                                end
                            end
           end
           STATE_TX_STOP    : begin
                            if((rx_data_out != 8'd0) && (rx_done))
                            begin
                                tx_current_state <= STATE_TX_START;
                            end
                            tx_Send <= 1'd0;
           end          
            default: tx_current_state <= STATE_TX_START;
        endcase
    end
end



initial
begin
    f_cycles_profile = $fopen(`FILE_CYCLES_PROFILE,"w");
    $sformat(prefix, "[mceliece%0d%0d]", DUT.N, DUT.T);
end
always @(posedge clk ) begin
    time_counter_start = time_counter_start + 1;
end
always @(posedge DUT.start_fo)
begin
    //time_field_ordering_start <= $time;
    time_field_ordering_start <= time_counter_start;
    $display("%s FieldOrdering module started.", (prefix));
    $fflush();
end

always @(posedge DUT.done_fo)
begin
    //time_field_ordering = ($time-time_field_ordering_start)/2;
    time_field_ordering = (time_counter_start-time_field_ordering_start)/2;
    $display("%s FieldOrdering finished. (%0d cycles)", prefix, time_field_ordering);
    $fwrite(f_cycles_profile, "field_ordering %0d %0d\n", time_field_ordering_start/2, (time_counter_start-time_field_ordering_start)/2);
    //$fwrite(f_cycles_profile, "field_ordering %0d %0d\n", time_field_ordering_start/2, ($time-time_field_ordering_start)/2);
    $fflush();
end

always @(posedge start_decap)
begin
    //time_decap_start = $time;
     time_decap_start = time_counter_start;
    $display("%s Decapsulation module started.", (prefix));
    $fflush();
end

always @(posedge done_decap)
begin
    //time_decap_finish = ($time-time_decap_start)/2;
    time_decap_finish = (time_counter_start-time_decap_start)/2;
    time_total = time_field_ordering+time_decap_finish;
   // time_require = time_field_ordering+($time-time_decap_start)/2;
   time_require = time_field_ordering+(time_counter_start-time_decap_start)/2;
    $display("%s Decapsulation module finished. (%0d cycles) [re-encrypt %s]", prefix,time_decap_finish, DUT.DECAPSULATION.decryption_module.decryption_fail ? "failed" : "succeeded");
    $display("%s FieldOrdering and Decapsulation require %0d cycles.", prefix, time_require);
    $fwrite(f_cycles_profile, "decap %0d %0d\n", time_decap_start/2, time_decap_finish);
    $fwrite(f_cycles_profile, "total %0d %0d\n", time_field_ordering_start/2, time_total);
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
// always @(posedge DUT.done_decap)
// begin
//     $writememb(`FILE_K_OUT, DUT.DECAPSULATION.hash_mem.mem,0,7);
//     $fflush();
// end

mem_single #(.WIDTH(32), .DEPTH(8)) mem_init_seed
           (
               .clock(clk),
               .data(mem_data),
               .address(addr_s),
               .wr_en(write_en_set_delta),
               .q(seed_from_ram)
           );

mem_single #(.WIDTH(32), .DEPTH(8)) C1_input_mem
           (
               .clock(clk),
               .data(mem_data),
               .address(addr_C1),
               .wr_en(write_en_set_c1),
               .q(C1_in)
           );

mem_single #(.WIDTH(32), .DEPTH(((L + (32-L%32)%32)/32))) C0_input_mem
           (
               .clock(clk),
               .data(mem_data),
               .address(addr_C0),
               .wr_en(write_en_set_c0),
               .q(C0_in)
           );

mem_single #(.WIDTH(32), .DEPTH(((PG_WIDTH + (32-PG_WIDTH%32)%32)/32))) pg_input_mem
           (
               .clock(clk),
               .data(mem_data),
               .address(addr_pg),
               .wr_en(write_en_set_poly),
               .q(poly_g_in)
           );

endmodule








