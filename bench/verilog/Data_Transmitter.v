
module Data_Transmitter(
    input clk,
    output o_uart_tx
    );
localparam  DBITS = 8,
            FIFO_EXP = 2,
            RESET_VALUE = 30,
            BR_LIMIT = 53,
            BR_BITS = 6,
            SB_TICK = 16;

localparam  LD_INIT_STR = 3'b00,
            SEND_CHAR = 3'b001,
            WAIT_BTN = 3'b010,
            RDY_LOW = 3'b011,
            WAIT_RDY = 3'b100,
            LD_BTN_STR = 3'b101,
            STOP_SEND = 3'b110;

localparam  WELCOME_STR_LEN = 21,
            BTN_STR_LEN = 8,
            UART_START = 1,
            UART_STOP = 0,
            CHECK_STRING = 4'd2;
reg [DBITS-1:0] WELCOME_STR[0:WELCOME_STR_LEN-1];
reg [4:0] tx_index = 0;
wire tx_done;
reg tx_Send;
reg [DBITS-1:0] tx_data = 0;
reg reset;
wire tick;




/*****************************/
reg [27:0] counter;
initial begin
    WELCOME_STR[1]   = "I";
    WELCOME_STR[2]   = "n";
    WELCOME_STR[3]   = "p";
    WELCOME_STR[4]   = "u";
    WELCOME_STR[5]   = "t";
    WELCOME_STR[6]   = " ";
    WELCOME_STR[7]   = "N";
    WELCOME_STR[8]   = "u";
    WELCOME_STR[9]   = "m";
    WELCOME_STR[10]  = "b";
    WELCOME_STR[11]  = "e";
    WELCOME_STR[12]  = "r";
    WELCOME_STR[13]  = "1";
    WELCOME_STR[14]  = ":";
end

// assign tx_fifo_not_empty = ~tx_empty;
initial counter = 28'hffffff0;
initial tx_index = 5'd0;
initial tx_Send = 1'b0;
initial	reset = 1'b1;
always @(posedge clk)
    reset <= 1'b0;

always @(posedge clk) begin
    counter <= counter + 1'b1;
end

always @(posedge clk) begin
    if((tx_Send)&&(tx_done))
        tx_index <= tx_index + 1'b1;
end

always @(posedge clk) begin
    tx_data <= WELCOME_STR[tx_index];
end

always @(posedge clk) begin
    if(counter == 28'hfffffff)
        tx_Send <= 1'b1;
    else if((tx_Send) && (tx_done) && (tx_index) == 5'hff)
        tx_Send <= 1'b0;
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

Transmitter
    #(
        .DBITS(DBITS),
        .SB_TICK(SB_TICK)
     )
     UART_TX_UNIT
     (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_Send),
        .sample_tick(tick),
        .data_in(tx_data),
        .tx_done(tx_done),
        .tx(o_uart_tx)
     );
endmodule