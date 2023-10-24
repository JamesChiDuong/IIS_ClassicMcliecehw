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

            parameter col_width = 64,
            parameter e_width = 64, // error_width

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
enum logic [1:0]
{
    STATE_IDLE,
    STATE_TYPE,
    STATE_LENGTH,
    STATE_VALUE
}state;
enum logic [2:0]
{
    STATE_START_MODE,
    STATE_SET_SEED,
    STATE_SET_PK,
    STATE_LOAD_MEMORY,
    STATE_STOP
}state_mode;
enum logic [1:0]
{
    STATE_TX_START,
    STATE_TX_SEND,
    STATE_TX_STOP
}state_tx;
localparam  DBITS = 8,                                  // 8 bit Data
            DATA_LENGTH = 48,                           // String length of the Data buffer    
            BR_BITS = 6,                                // Counter limit
            BR_LIMIT = 53,                              // Baudrate limit
            SB_TICK = 16;                               // Sb tick
reg tx_Send;                                    
wire tx_done;
wire rx_done;
wire tick;
wire [DBITS-1:0] rx_data_out;                           // Rx Data which receive from Rx module
reg  [DBITS-1:0] tx_Data_Buffer[0:DATA_LENGTH];      // Initial tx Data Buffer
reg  [DBITS-1:0] tx_data_in;                            // Tx Data input to transfer
reg  [5:0] tx_index;                                   // Tx module index
integer STDERR = 32'h8000_0002;

//Register to store the current TLV data byte
reg [DBITS-1:0] tlv_data_byte;
reg [DBITS-1:0] tlv_type_reg;
reg [DBITS-1:0] tlv_length_reg;
reg [DBITS-1:0] tlv_value_reg;
integer data_length =0;
//********************Memory loading procedure*************/
reg [31:0] ctr = 0;
//reg loading_done = 0;

integer SIZE_SEED = 16;
integer SIZE_PK = k*l/col_width;
integer SIZE_C0 = (l + (32-l%32)%32)/32;
integer SIZE_C1 = 8;
integer SIZE_K = 8;

integer START_SEED = 1;
integer STOP_SEED = START_SEED + SIZE_SEED;
integer START_PK = STOP_SEED + 1;
integer STOP_PK = START_PK + SIZE_PK;
integer SIZE_TOTAL = STOP_SEED;

reg write_en;
reg [3:0] data_tlv_length;
/*********************Clock cycle count profiling************** */
integer f_cycles_profile;
time    time_encap_start;
time time_encapsulation;
time time_encrypt_start;
time time_encrypt;
time time_fixedweight_start;
time time_fixedweight;

reg [17*8-1:0] prefix;
 /**************Main Program***************/
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
mem_single #(.WIDTH(col_width), .DEPTH(((l_n_elim+(col_width-l_n_elim%col_width)%col_width)/col_width)), .FILE(`FILE_PK_SLICED) ) 
            publickey
           (
               .clock(clk),
               .data(0),
               .address(addr_PK),
               .wr_en(0),
               .q(PK_col)
           );

// mem_single #(.WIDTH(32), .DEPTH(16), .FILE(`FILE_MEM_SEED) ) 
//             mem_init_seed
//            (
//                 .clock(clk),
//                 .data(0),
//                 .address(addr_seed),
//                 .wr_en(0),
//                 .q(seed_from_ram)
//            );
Transmitter #(.DBITS(DBITS),.SB_TICK(SB_TICK)) 
            UART_TX_UNIT
            (
                .clk(clk),
                .reset(reset),
                .tx_start(tx_Send),
                .sample_tick(tick),
                .data_in(tx_data_in),
                .tx_done(tx_done),
                .tx(o_uart_tx)
            );
mem_single #(.WIDTH(32), .DEPTH(16)) mem_init_seed
           (
               .clock(clk),
               .data(tlv_value_reg),
               .address(addr_seed),
               .wr_en(write_en),
               .q(seed_from_ram)
           );

// initial
// begin
//     $dumpfile(`FILE_VCD);
//     $dumpvars();
// end

always @(posedge clk)
begin
    if(rst)
    begin
        state <= STATE_IDLE;
        tlv_type_reg <= 8'b0;
        tlv_length_reg <= 8'b0;
        tlv_value_reg <= 8'b0;

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
        write_en <= 1'b0;
        data_tlv_length = 4'd0;
    end
end


/***********TLV decode*******************/
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
            state <= STATE_LENGTH;
            tlv_type_reg <= tlv_data_byte;
            tlv_data_byte <= rx_data_out;
        end
        end
        STATE_LENGTH: begin
        if(rx_done)
        begin
            state <= STATE_VALUE;
            tlv_length_reg <= tlv_data_byte;
            tlv_value_reg <= rx_data_out;
            data_tlv_length +=  tlv_length_reg;

            addr_seed <= data_tlv_length;
            write_en <= 1'b1;
        end
        end
        STATE_VALUE: begin
        if((tlv_length_reg == 8'b1))
        begin
            state <= STATE_IDLE;
            write_en <= 1'b0;
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
/***************START Encapsulation*************************/
always @(posedge clk ) begin
    case (state_mode)
       STATE_START_MODE : begin
        if((tlv_value_reg == 8'd2) && (state == STATE_IDLE))
            state_mode <= STATE_SET_PK;
        else if((tlv_value_reg == 8'd1))
            state_mode <= STATE_SET_SEED;
       end
       STATE_SET_PK : begin
        
       end
       STATE_SET_SEED : begin
        if (ctr < SIZE_TOTAL+1)
        begin
            ctr <= ctr + 1;
        end
        else
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
       end
        default: tlv_value_reg <= 8'd0;
    endcase
end
integer i;

always @(posedge clk)
begin
    seed <= seed_from_ram;

    // loading seed
    if (ctr >= START_SEED && ctr < STOP_SEED+1)
    begin
        seed_valid <= 1'b1;
    end
    else
    begin
        addr_seed <= addr_seed;
        seed_valid <= 1'b0;
        write_en <= 1'b0;
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
/***************TRANSFER PROCSSESS*******************/
always @(posedge clk) begin
    if(DUT.done)
    begin
        state_tx <= STATE_TX_START;
        for(i = 0; i <8; i++)
        begin
            tx_Data_Buffer[i] <= ((time_encap_start/2) >> 8*i) & 8'hff; // /2
        end
        for(i = 8; i <16; i++)
        begin
            tx_Data_Buffer[i] <= ((time_encapsulation) >> 8*(i-8)) & 8'hff;
        end
        for(i = 16; i <24; i++)
        begin
            tx_Data_Buffer[i] <= ((time_fixedweight_start/2) >> 8*(i-16)) & 8'hff;
        end
        for(i = 24; i <32; i++)
        begin
            tx_Data_Buffer[i] <= (time_fixedweight >> 8*(i-24)) & 8'hff;
        end
        for(i = 32; i <40; i++)
        begin
            tx_Data_Buffer[i] <= ((time_encrypt_start/2) >> 8*(i-32)) & 8'hff;
        end
        for(i = 40; i <48; i++)
        begin
            tx_Data_Buffer[i] <= (time_encrypt >> 8*(i-40)) & 8'hff;
        end
    end
end
always @(posedge clk) begin
    tx_data_in <= tx_Data_Buffer[tx_index];
    if((tx_done)&&((tx_index != 6'd48)))
    begin
        tx_index <= tx_index + 1;
    end
    else if((tx_done)&&((tx_index == 6'd48)))
    begin
        tx_index <= 6'd0;
    end
end
always @(posedge clk ) begin
    case (state_tx)
      STATE_TX_START : begin
        if(DUT.done) begin
            state_tx <= STATE_TX_SEND;
        end
      end
      STATE_TX_SEND : begin
        if(tx_index == 6'd48)
        begin
            state_tx <= STATE_TX_STOP;
        end
      end
      STATE_TX_STOP : begin
        if((rx_data_out != 8'b0) && (rx_done))
        begin
            state_tx <= STATE_TX_START;
        end
      end
        default: state_tx <= STATE_TX_START;
    endcase
end
always @(posedge clk) begin
    case (state_tx)
        STATE_TX_START : begin
            tx_Send <= 1'b0;
        end  
        STATE_TX_SEND : begin
            tx_Send <= 1'b1;
        end
        STATE_TX_STOP: begin
            tx_Send <= 1'b0;
        end
        default: begin
            tx_Send <= 1'b0;
        end
    endcase
end
initial
begin
    f_cycles_profile = $fopen(`FILE_CYCLES_PROFILE,"w");
    $sformat(prefix, "[mceliece%0d%0d]", DUT.n, DUT.t);
end

always @(posedge DUT.done)
begin
    $writememb(`FILE_K_OUT, DUT.hash_mem.mem,0,7);
    $writememb(`FILE_CIPHER0_OUT, DUT.encryption_unit.encrypt_mem.mem);
    $writememb(`FILE_CIPHER1_OUT, DUT.C1_mem.mem);
    $writememb(`FILE_ERROR_OUT, DUT.error_vector_gen.onegen_instance.mem_dual_B.mem);
    $fflush();
end

always @(posedge seed_valid)
begin  
    time_encap_start = $time;
    $display("%s Start Encapsulation. (%0d cycles)", prefix, time_encap_start/2);
    $fflush();
end

always @(posedge DUT.done)
begin
    time_encapsulation = ($time-time_encap_start)/2;
    $display("%s Encapsulation finished. (%0d cycles)", prefix, time_encapsulation);
    $fwrite(f_cycles_profile, "encapsulation %0d %0d\n", time_encap_start/2, time_encapsulation);
    $fflush();
end

always @(posedge seed_valid)
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

endmodule;
