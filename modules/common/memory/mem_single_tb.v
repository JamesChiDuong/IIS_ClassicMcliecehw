
module mem_single_tb (
    input clk,
    input reset,  
    input i_uart_rx,
    output o_uart_tx
);
localparam  DBITS = 8,
            DATA_LENGTH  = 11,
            BR_BITS = 6,
            BR_LIMIT = 53,
            SB_TICK = 16,
            WIDTH = 32,
            DEPTH = 8;
/* verilator lint_off UNUSEDPARAM */
parameter [2:0] START           = 3'b000,
                DATA            = 3'b001,
                SEND            = 3'b100,
                STOP            = 3'b111;
//Generator baudrate module
wire tick;
//Rx_Module
wire [7:0] rx_data_out;
wire rx_done;
reg  [WIDTH-1:0] rx_Data_Buffer[0:DATA_LENGTH];
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSEDSIGNAL */
reg [2:0] rx_current_state, rx_next_state;
reg  [3:0] rx_index;
//Tx module
/* verilator lint_off UNUSEDSIGNAL */
wire tx_done;
reg [2:0] tx_current_state, tx_next_state;
reg  [DBITS-1:0] tx_data_in;
reg  [DBITS-1:0] tx_Data_Buffer[0:DATA_LENGTH];
reg  [3:0] tx_index;        
reg tx_Send;
//mem_single_memory
/* verilator lint_off UNDRIVEN */
reg [(DEPTH)-1:0] address;
wire [WIDTH-1:0]         output_memory;


/*------Receiver Process--------*/
always @(posedge clk) begin
    if((rx_data_out == 8'h0A)&&(rx_done))
    begin
        address <= address + 1'b1;
        rx_index <= 4'd0; 
    end
    else if(((rx_data_out != 8'h0A))&&(rx_done))
        rx_index <= rx_index + 1'b1;
    else if((rx_data_out != 8'h0A)&&(address >(DEPTH-1))&&(rx_done))
    begin
        address <= 0;
    end
     
end
always @(posedge clk) begin
    rx_Data_Buffer[rx_index] <= output_memory;
end

always @(posedge clk ) begin
    case (rx_current_state)
       START : begin
        if(((rx_data_out == 8'h0C)) &&(rx_done))
            rx_next_state <= DATA;
       end
       DATA : begin
        if(((rx_data_out == 8'h0A))&&(rx_done))
            rx_next_state <= STOP;
       end
       STOP: begin
        if((rx_done))
            rx_next_state <= START;
       end
        default: rx_next_state <= START;
    endcase
end

// Sequential logic
/* verilator lint_off SYNCASYNCNET */
always @(posedge clk) begin
    if(reset)
    begin
        rx_current_state <= 3'd0;
        tx_current_state <= 3'd0;      
    end
    else
    begin
        rx_current_state <= rx_next_state;
        tx_current_state <= tx_next_state;
    end

end
 

// /*------Transfer Process--------*/	
always @(posedge clk) begin
    if((rx_current_state == STOP))
    begin
        tx_Data_Buffer[0] <= 8'h20;
        /* verilator lint_off WIDTH */
        tx_Data_Buffer[1] <= rx_Data_Buffer[1];
        /* verilator lint_off WIDTH */
        // tx_Data_Buffer[1] <= output_memory;//convert 32bit to 8 bit

        tx_Data_Buffer[2] <= address;
        tx_Data_Buffer[3] <= 8'h0A;
        tx_Data_Buffer[4] <= 8'h0; 
    end
end	
always @(posedge clk ) begin
    case (tx_current_state)
       START : begin
        if((rx_current_state==STOP))
        begin
            tx_next_state <= SEND; 
        end
       end
       SEND : begin
        if((tx_index > 4'd4))
        begin
           tx_next_state <= STOP; 
        end
       end
       STOP : begin
        if((rx_current_state==START) && (rx_done == 1'b1))
        begin
            tx_next_state <= START;
        end
       end
        default: tx_next_state <= START;
    endcase
end
always @(posedge clk) begin
    if((tx_done)&&(tx_index <4'd6))
        tx_index <= tx_index + 1;
    else if(tx_index >= 4'd6)
        tx_index <= 4'd0;
end
always @(posedge clk) begin
    tx_data_in <= tx_Data_Buffer[tx_index];
end
always @(posedge clk) begin
    case (tx_current_state)
        START : begin
            tx_Send <= 1'b0;
        end  
        SEND : begin
            tx_Send <= 1'b1;
        end
        STOP: begin
            tx_Send <= 1'b0;
        end
        default: begin
            tx_Send <= 1'b0;
        end
    endcase
end
baud_rate_generator #(.N(BR_BITS), .M(BR_LIMIT)) 
    BAUD_RATE_GEN   
(
    .clk(clk), 
    .reset(reset),
    .tick(tick)
);
Receiver #(.DBITS(DBITS),.SB_TICK(SB_TICK))
    UART_RX_UNIT
(
    .clk(clk),
    .reset(reset),
    .rx(i_uart_rx),
    .sample_tick(tick),
    .data_ready(rx_done),
    .data_out(rx_data_out)
);
mem_single #(.WIDTH(WIDTH),.DEPTH(DEPTH)) 
    C1_mem
(
    .clock(clk),
    /* verilator lint_off WIDTH */
    .data(rx_data_out),
    .address(address),
    .wr_en(rx_done),
    .q(output_memory)
);
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
endmodule
