/* verilator lint_off UNUSED */
module Data_Receiver (
    input clk,
    input i_uart_rx,
    output o_uart_tx
);
localparam  DBITS = 8,
            FIFO_EXP = 2,
            BR_BITS = 6,
            BR_LIMIT = 53,
            SB_TICK = 16;

reg reset;
wire [7:0] rx_data_out;
wire [7:0]data_buffer;
wire [DBITS-1:0] tx_fifo_out;
wire rx_done;
wire tx_done;
/* verilator lint_off UNUSED */
wire tx_empty;  
wire tx_fifo_not_empty;
wire tick;

wire rx_empty;
wire rx_full;
wire tx_full;

/*********Main program**********/

initial reset = 1'b1;
//assign tx_fifo_not_empty = ~tx_empty;

always @(posedge clk) begin
    reset <= 1'b0;
end

baud_rate_generator 
    #(
        .N(BR_BITS), 
        .M(BR_LIMIT)
     ) 
    BAUD_RATE_GEN   
    (
        .clk(clk), 
        .reset(reset),
        .tick(tick)
     );
Receiver
    #(
        .DBITS(DBITS),
        .SB_TICK(SB_TICK)
        )
        UART_RX_UNIT
        (
        .clk(clk),
        .reset(reset),
        .rx(i_uart_rx),
        .sample_tick(tick),
        .data_ready(rx_done),
        .data_out(rx_data_out)
        );

Transmitter
    #(
        .DBITS(DBITS),
        .SB_TICK(SB_TICK)
     )
     UART_TX_UNIT
     (
        .clk(clk),
        .reset(reset),
        .tx_start(rx_done),
        .sample_tick(tick),
        .data_in(rx_data_out),
        .tx_done(tx_done),
        .tx(o_uart_tx)
     );
endmodule