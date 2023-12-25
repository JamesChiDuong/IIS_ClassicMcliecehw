`timescale 1ns/1ps
module encap_sim
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
            parameter KEY_START_ADDR = l*(l/col_width)
            )(
            input wire 	clk,
            input wire 	rst,
            input i_uart_rx,
            output o_uart_tx,
            output wire done
            );
/*********Classic Variable*************/
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

reg [`CLOG2((l_n_elim +(col_width-l_n_elim%col_width)%col_width)/col_width) - 1:0] PK_addr;

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

/******************UART Protocol Variable***************/
parameter [2:0] STATE_START_MODE            = 3'b000,
                STATE_SET_SEED              = 3'b001,
                STATE_SET_PK                = 3'b100,
                STATE_ENCAP_CHECKDATABACK    = 3'b101,
                STATE_STOP                  = 3'b111;

parameter [1:0] STATE_IDLE      = 2'b00,
                STATE_TYPE      = 2'b01,
                STATE_LENGTH    = 2'b10,
                STATE_VALUE     = 2'b11;
parameter [1:0] STATE_TX_START      = 2'b00,
                STATE_TX_SEND      = 2'b01,
                STATE_TX_STOP     = 2'b11;


reg [2:0] state_mode;
reg [1:0] state;
reg [1:0] state_tx;

parameter DATA_LENGTH_TIME = 48;
parameter DATA_LENGTH_CIPHER0 = 96;
parameter DATA_LENGTH_CIPHER1 = 32;
parameter DATA_LENGTH_K = 32;
parameter RAW_DATA_LENGTH = DATA_LENGTH_TIME + DATA_LENGTH_CIPHER0 + DATA_LENGTH_CIPHER1 + DATA_LENGTH_K;
localparam  DBITS = 8,                                  // 8 bit Data
            DATA_LENGTH = RAW_DATA_LENGTH,                           // String length of the Data buffer    
            BR_BITS = 6,                                // Counter limit
            BR_LIMIT = 2,                              // Baudrate limit
            SB_TICK = 16;                               // Sb tick
reg tx_Send;                                    
wire tx_done;
wire rx_done;
wire tick;
wire [DBITS-1:0] rx_data_out;                           // Rx Data which receive from Rx module
reg  [DBITS-1:0] tx_Data_Buffer[0:DATA_LENGTH];      // Initial tx Data Buffer
reg  [DBITS-1:0] tx_data_in;                            // Tx Data input to transfer
reg  [8:0] tx_index;                                   // Tx module index
integer STDERR = 32'h8000_0002;

//Register to store the current TLV data byte
reg [DBITS-1:0] tlv_data_byte;
reg [DBITS-1:0] tlv_type_reg;
reg [(DBITS*3-1):0] tlv_length_reg;
reg [DBITS-1:0] tlv_length_reg_check;
reg [DBITS-1:0] tlv_value_reg;
reg [(DBITS*3-1):0] data_tlv_length;

reg [3:0] tlv_size_of_length_data;


//********************Memory loading procedure*************/
reg [39:0] ctr = 0;
reg [39:0] counter = 0; 
//reg loading_done = 0;
parameter SIZE_SEED = 16;
parameter SIZE_PK = k*l/col_width;
parameter SIZE_C0 = (l + (32-l%32)%32)/32;
parameter SIZE_C1 = 8;
parameter SIZE_K = 8;

parameter START_SEED = 0;
parameter STOP_SEED = 16;  // each row is 32 bit and total have 512 bit, each time will read 1 row, so need to read 16 times
parameter START_PK = 1854; // It depend on the addr_PK at the module DUT, brow the data so that synchronous addr_PK
parameter STOP_PK = 17 + k*l/col_width + 1855 - 16; // to stop PK
parameter START_C0 = STOP_PK;
parameter STOP_C0 = START_C0 + SIZE_C0 + 2;
parameter START_C1 = STOP_C0 + 3;
parameter STOP_C1 = START_C1 + SIZE_C1 + 1;
// integer START_K = 
parameter SIZE_TOTAL = 17 + k*l/col_width + 1855 - 16 + STOP_C0 + STOP_C1 + 5;

reg write_en_setseed;
reg write_en_setpk;

reg [1:0] data_index;
reg [32-1:0] mem_data;
reg [1:0] data_set_seed;
reg [1:0] data_set_pk;
reg [31:0] C0_data_buffer[0:24];
reg [31:0] K_data_buffer[0:8];
/*********************Clock cycle count profiling************** */
integer f_cycles_profile;
reg [63:0]  time_encap_start;
reg [63:0]  time_encapsulation;
reg [63:0]  time_encrypt_start;
reg [63:0]  time_encrypt;
reg [63:0]  time_fixedweight_start;
reg [63:0]  time_fixedweight;

reg [63:0] time_counter_start;
// reg rst;
reg [17*8-1:0] prefix;


 /**************Main Program***************/

integer i;
integer j;
//reg [7:0] test[23:0];

/***********TLV decode*******************/
always @(posedge clk ) begin
    if(rst)
    begin
        state <= STATE_IDLE;
        state_mode <= STATE_START_MODE;
        tlv_type_reg <= 8'b0;
        tlv_length_reg <= 8'b0;
        tlv_value_reg <= 8'b0;

        ctr <= 0;
	    addr_h = 0;
        addr_seed <= 0;


        seed_valid <= 1'b0;
        K_col_valid <= 1'b0;

        write_en_setseed <= 1'b0;
        write_en_setpk <= 1'b0;
        data_tlv_length <= 24'd0;
        tlv_size_of_length_data <= 4'd0;

        time_counter_start = 64'd0;
        data_index <= 2'd0;

        C0_addr <= 0;
        C1_addr <= 0;
    end
end
always @(posedge clk)
begin
    case (state)
        STATE_IDLE : begin
        if((rx_data_out != 8'b0) && (rx_done))
        begin
            state <= STATE_TYPE;
            tlv_data_byte <= rx_data_out;
        end
        end
        STATE_TYPE: begin
        if(rx_done)
        begin
            tlv_type_reg <= tlv_data_byte;
            tlv_data_byte <= rx_data_out;
            tlv_length_reg_check <= rx_data_out;
            state <= STATE_LENGTH;
        end
        end
        STATE_LENGTH: begin
        if((tlv_length_reg_check > 8'h7f) && (tlv_size_of_length_data == 0))
        begin
            tlv_size_of_length_data <= (tlv_length_reg_check & 8'b01111111) + 1;
        end
        if(tlv_size_of_length_data == 8'd1 || tlv_length_reg_check < 8'h7f)
        begin
            state <= STATE_VALUE;
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
            state <= STATE_IDLE;
            tlv_size_of_length_data <= 4'd0;
            data_tlv_length <= 24'd0;
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
// /***************START Encapsulation*************************/
always @(posedge clk ) begin
    case (state_mode)
        STATE_START_MODE : begin
            if((tlv_type_reg == 8'd1)&& (state == STATE_VALUE))
                state_mode <= STATE_SET_PK;
            else if((tlv_type_reg == 8'd2) && (state == STATE_VALUE))
                state_mode <= STATE_SET_SEED;
            else if((tlv_type_reg == 8'd3) && (state == STATE_VALUE))
                state_mode <= STATE_ENCAP_CHECKDATABACK;
        end
        STATE_SET_PK : begin
            if(rx_done)
            begin

                data_index <= data_index + 1;
                if(data_index == 0)
                begin
                    mem_data <= rx_data_out << 24;
                    write_en_setpk <= 1'b0;                  
                end
                else
                begin
                    mem_data <= mem_data | (rx_data_out << 8*(3-data_index));
                    if(data_index == 3)
                    begin
                        write_en_setpk <= 1'b1;
                        ctr <= ctr + 1;
                        if(ctr > 0)
                        begin
                            PK_addr <= PK_addr + 1;
                        end
                    end           
                end
            end
            if(tlv_length_reg == 0)
            begin
                data_set_pk = 1'b1;
                state_mode <= STATE_STOP;
            end
        end
        STATE_SET_SEED : begin  
            if(rx_done)
            begin
                data_index <= data_index + 1;         
                if(data_index == 0)
                begin
                    mem_data <= rx_data_out << 24;
                    write_en_setseed <= 1'b0;
                end
                else
                begin
                    mem_data <= mem_data | (rx_data_out << 8*(3-data_index));
                    if(data_index == 3)
                    begin     
                        write_en_setseed <= 1'b1;
                        ctr <= ctr + 1;
                        if(ctr > 0)
                        begin
                            addr_seed <= addr_seed + 1;   
                        end
                    end
                end
            end
            if(tlv_length_reg == 0)
            begin
                data_set_seed = 1'b1;
                state_mode <= STATE_STOP;
            end
        end
        STATE_ENCAP_CHECKDATABACK : begin
            seed <= seed_from_ram;
            if (ctr < SIZE_TOTAL)
            begin
                ctr <= ctr + 1;
                if (ctr >= START_SEED && ctr < STOP_SEED+1)
                begin
                    seed_valid <= 1'b1;
                end
                else
                begin
                    seed_valid <= 1'b0;
                end
                if (ctr >= START_PK && ctr < STOP_PK)
                begin   
                    if (ctr > START_PK)
                        PK_addr <= PK_addr + 1; //start add the PK_add follow ctr
                        //addr_PK <= PK_addr; // addr_pk will be assign the PK_addr to synchronous
                end
                else
                begin
                    PK_addr <= 0;
                end
                if(ctr >= START_C0 && ctr <= STOP_C0)
                begin
                    
                    if(DUT.encryption_unit.encrypt_mem.address_1 > 0)
                    begin          
                        C0_addr <= C0_addr + 1;
                        C0_data_buffer[C0_addr] <= C0_out;                   
                    end
                end
                if(ctr >= 68035 && ctr <= 68051)
                begin         
                    if(ctr > START_C1 && DUT.hash_mem.wren_1 == 0)
                    begin
                        K_addr <= K_addr + 1;
                        K_data_buffer[K_addr] <= K_out;   
                    end
                end
                
            end
            else if ((ctr >= SIZE_TOTAL) && tlv_length_reg == 0)
            begin
                state_mode <= STATE_STOP;
            end
        end
        STATE_STOP : begin
            if((rx_data_out != 8'b0) && (rx_done))
            begin
                state_mode <= STATE_START_MODE;
            end
            ctr <= 31'd0;
            seed_valid <= 1'b0;
            addr_seed <= 0;
            PK_addr <= 0;
            data_set_pk = 1'b0;
            data_set_seed = 1'b0;
            write_en_setpk <= 1'b0;
            write_en_setseed <= 1'b0;
            C0_addr <= 0;
            C1_addr <= 0;
        end
        default: tlv_value_reg <= 8'd0;
    endcase
end

/***************TRANSFER PROCSSESS*******************/
always @(posedge clk) begin

    if(DUT.done)
    begin
        state_tx <= STATE_TX_START;
        for(i = 0; i < (DATA_LENGTH_TIME/6); i= i +1)
        begin
            tx_Data_Buffer[i] <= (((time_encap_start)/2) >> 8*i) & 8'hff; // /2           
        end
        for(i = 8; i < (DATA_LENGTH_TIME/3); i = i +1)
        begin
            tx_Data_Buffer[i] <= ((time_encapsulation) >> 8*(i-8)) & 8'hff;
        end
        for(i = 16; i <(DATA_LENGTH_TIME/2); i = i +1)
        begin
            tx_Data_Buffer[i] <= ((time_fixedweight_start/2) >> 8*(i-16)) & 8'hff;
        end
        for(i = 24; i < (DATA_LENGTH_TIME-16); i = i+1)
        begin
            tx_Data_Buffer[i] <= (time_fixedweight >> 8*(i-24)) & 8'hff;
        end
        for(i = 32; i < (DATA_LENGTH_TIME - 8); i = i+1)
        begin
            tx_Data_Buffer[i] <= ((time_encrypt_start/2) >> 8*(i-32)) & 8'hff;
        end
        for(i = 40; i < DATA_LENGTH_TIME; i=i+1)
        begin
            tx_Data_Buffer[i] <= (time_encrypt >> 8*(i-40)) & 8'hff;
        end
        for(i = DATA_LENGTH_TIME; i < DATA_LENGTH_TIME + DATA_LENGTH_CIPHER0; i = i + 1) //Write to cipher_o file
        begin
            if(i - DATA_LENGTH_TIME == 4*(j+1))
            begin
               j = j + 1;
            end

            tx_Data_Buffer[i] <= (C0_data_buffer[j+1] >> 8*(i-(48 + 4*j)));
            //test [(i-(144 + 4*j))] <= (DUT.encryption_unit.encrypt_mem.mem[j] >> 8);
        end
        for(i = (DATA_LENGTH_TIME + DATA_LENGTH_CIPHER0); i < (DATA_LENGTH_TIME + DATA_LENGTH_CIPHER0 + DATA_LENGTH_CIPHER1); i = i +1)
        begin
            if(i == (DATA_LENGTH_TIME + DATA_LENGTH_CIPHER0))
            begin
                j = 0;
            end
            if(i - (DATA_LENGTH_TIME + DATA_LENGTH_CIPHER0) == 4*(j+1))
            begin
               j = j + 1;
            end
            tx_Data_Buffer[i] <= (DUT.C1_mem.mem[j] >> 8*(i-(144 + 4*j)));
            //test [(i-(144 + 4*j))] = (DUT.C1_mem.mem[j] >> 8);
        end
        for(i = (DATA_LENGTH_TIME + DATA_LENGTH_CIPHER0 + DATA_LENGTH_CIPHER1); i < RAW_DATA_LENGTH; i = i +1)
        begin
            if(i == (DATA_LENGTH_TIME + DATA_LENGTH_CIPHER0 + DATA_LENGTH_CIPHER1))
            begin
                j = 0;
            end
            if(i - (DATA_LENGTH_TIME + DATA_LENGTH_CIPHER0 + DATA_LENGTH_CIPHER1) == 4*(j+1))
            begin
               j = j + 1;
            end
            tx_Data_Buffer[i] <= (K_data_buffer[j] >> 8*(i-(176 + 4*j)));
        end
    end
    if((data_set_seed == 1) || (data_set_pk == 1))
    begin
        tx_Data_Buffer[0] <= 1;
        if(data_set_seed == 1)
        begin
            $display("%s Send Seed data completed", prefix);
        end
        else
        begin
            $display("%s Send Public key data completed", prefix);
        end
    end
end
always @(posedge clk) begin
    tx_data_in <= tx_Data_Buffer[tx_index];
    if((tx_done)&&((tx_index != DATA_LENGTH)))
    begin
        tx_index <= tx_index + 1;
    end
    else if((tx_done)&&((tx_index == DATA_LENGTH)))
    begin
        tx_index <= 6'd0;
    end
end
always @(posedge clk ) begin
    case (state_tx)
      STATE_TX_START : begin
        if((DUT.done) ||(data_set_seed == 1) || (data_set_pk == 1) ) begin
            state_tx <= STATE_TX_SEND;
            tx_Send <= 1'b1;
        end
      end
      STATE_TX_SEND : begin
        if(tx_index == DATA_LENGTH)
        begin
            state_tx <= STATE_TX_STOP;
            tx_Send <= 1'b0;
        end
      end
      STATE_TX_STOP : begin
        if((rx_data_out != 8'b0) && (rx_done))
        begin
            state_tx <= STATE_TX_START;
            tx_Send <= 1'b0;
        end
      end
        default: state_tx <= STATE_TX_START;
    endcase
end
initial
begin
    f_cycles_profile = $fopen(`FILE_CYCLES_PROFILE,"w");
    $sformat(prefix, "[mceliece%0d%0d]", n, t);
end
// always @(posedge DUT.done)
// begin
//     $writememb(`FILE_K_OUT, DUT.hash_mem.mem,0,7);
//     $writememb(`FILE_CIPHER0_OUT, DUT.encryption_unit.encrypt_mem.mem);
//     $writememb(`FILE_CIPHER1_OUT, DUT.C1_mem.mem);
//     $writememb(`FILE_ERROR_OUT, DUT.error_vector_gen.onegen_instance.mem_dual_B.mem);
//     $fflush();
// end
always @(posedge clk ) begin
    time_counter_start = time_counter_start + 1;
end
always @(posedge seed_valid)
begin  
    time_encap_start = time_counter_start+1;
    $display("%s Start Encapsulation. (%0d cycles)", prefix, time_encap_start/2);
    $fflush();
end

always @(posedge DUT.done)
begin
    time_encapsulation = (time_counter_start-time_encap_start)/2;
    $display("%s Encapsulation finished. (%0d cycles)", prefix, time_encapsulation);
    $fwrite(f_cycles_profile, "encapsulation %0d %0d\n", time_encap_start/2, time_encapsulation);
end

always @(posedge seed_valid)
begin
    time_fixedweight_start = time_counter_start+1;
    $display("%s Start FixedWeight. (%0d cycles)", prefix, time_fixedweight_start/2);
    $fflush();
end

always @(posedge DUT.done_error)
begin
    time_fixedweight = (time_counter_start-time_fixedweight_start)/2;
    $display("%s FixedWeight finished. (%0d cycles)", prefix, time_fixedweight);
    $fwrite(f_cycles_profile, "fixedweight %0d %0d\n", time_fixedweight_start/2, time_fixedweight);
    $fflush();
end

always @(posedge DUT.done_error)
begin
    time_encrypt_start = time_counter_start+1;
    $display("%s Start Encode. (%0d cycles)", prefix, time_encrypt_start/2);
    $fflush();
end

always @(posedge DUT.done_encrypt)
begin
    time_encrypt = (time_counter_start-time_encrypt_start)/2;
    $display("%s Encode finished. (%0d cycles)", prefix, time_encrypt);
    $fwrite(f_cycles_profile, "encode %0d %0d\n", time_encrypt_start/2, time_encrypt);
    $fflush();
end


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
mem_single #(.WIDTH(col_width), .DEPTH(((l_n_elim+(col_width-l_n_elim%col_width)%col_width)/col_width)))
            publickey
           (
               .clock(clk),
               .data(mem_data),
               .address(PK_addr),
               .wr_en(write_en_setpk),
               .q(PK_col)
           );
mem_single #(.WIDTH(32), .DEPTH(16)) 
            mem_init_seed
           (
               .clock(clk),
               .data(mem_data),
               .address(addr_seed),
               .wr_en(write_en_setseed),
               .q(seed_from_ram)
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

endmodule
