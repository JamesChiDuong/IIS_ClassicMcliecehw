
module mem_single_tb (
    input clk,
    input reset,  
    input i_uart_rx,
    output o_uart_tx
);
localparam  DBITS = 8,  
            BR_BITS = 6,
            BR_LIMIT = 53,
            SB_TICK = 16,
            WIDTH = 32,
            DEPTH = 8;
//Generator baudrate module
wire tick;
//Rx_Module
wire [7:0] rx_data_out;
wire rx_done;
//Tx module
/* verilator lint_off UNUSEDSIGNAL */
wire tx_done;
//mem_single_memory
/* verilator lint_off UNDRIVEN */
wire [(DEPTH)-1:0] address;
wire [WIDTH-1:0]         output_memory;

always @(posedge cl)
begin
    $writememb(`FILE_K_OUT, DUT.hash_mem.mem,0,7);
    $writememb(`FILE_CIPHER0_OUT, DUT.encryption_unit.encrypt_mem.mem);
    $writememb(`FILE_CIPHER1_OUT, DUT.C1_mem.mem);
    $writememb(`FILE_ERROR_OUT, DUT.error_vector_gen.onegen_instance.mem_dual_B.mem);
    $fflush();
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
        .tx_start(rx_done),
        .sample_tick(tick),
        .data_in(rx_data_out),
        .tx_done(tx_done),
        .tx(o_uart_tx)
     );
endmodule
