/* verilator lint_off UNUSED */
module TranAndRecei (
    input clk,
    input i_uart_rx,
    /* verilator lint_off UNDRIVEN */
    output o_uart_tx
);
localparam  DBITS = 8,                          // 8 bit Data
            DATA_LENGTH = 5,                    // String length of the Data buffer    
            BR_BITS = 6,                        // Counter limit
            BR_LIMIT = 53,                      // Baudrate limit
            SB_TICK = 16;                       // Sb tick
reg [2:0] rx_index;                             // Rx module index
reg [10:0] tx_index;                            // Tx module index
reg [1:0] str_index;                            // Stirng index
/* verilator lint_off WIDTH */
reg [7:0] rx_Data_Buffer[0:DATA_LENGTH];        // Initial rx Data Buffer
reg [7:0] tx_Data_Buffer[0:DATA_LENGTH+35];     // Initial tx Data Buffer
wire [7:0] rx_data_out;                         // Rx Data which receive from Rx module
reg [7:0] tx_data_in;                           // Tx Data input to transfer
reg [7:0] number1;                              // Number1 to calculate in Full Adder
reg [7:0] number2;                              // Number2 to calculate in Full Adder
wire [7:0] sum;                                 // Sum of calculate in Full Adder
reg cin;
/* verilator lint_off UNUSED */
wire cout;                                      // Cout to calculate in Full Adder
reg reset;
reg tx_Send;                                    
wire tx_done;
wire rx_done;
wire tick;
reg	[27:0]	counter;
reg CHECKOK;
reg [2:0] current_state, next_state;
/******Main Program********/
initial begin
     cin = 1'b0;
     reset = 1'b1;
     tx_Send = 1'b0;
     str_index = 2'd0;
     CHECKOK = 1'b0;
end
always @(posedge clk) begin
    reset <= 1'b0;
end
/*------Receiver Process--------*/
always @(posedge clk) begin
    if((rx_data_out != 8'd10) &&(rx_done))
        rx_index <= rx_index + 1'b1;
    if(((rx_data_out == 8'd13)&&(rx_done)) || ((rx_data_out == 8'd10)&&(rx_done)))
        str_index <= str_index + 1'b1;
end    

always @(posedge clk) begin
    rx_Data_Buffer[rx_index] <= rx_data_out;
end
always @(posedge clk) begin
    case (str_index)
        2'b00 : begin
            number1 <= 0;
            number2 <= 0;
        end  
        2'b01 : begin
            number1 <= (rx_Data_Buffer[0] - 48) *100 + (rx_Data_Buffer[1] - 48)*10 + (rx_Data_Buffer[2] -48);
            number2 <= 0;
        end
        2'b10 : begin
            number1 <= number1;
            number2 <= (rx_Data_Buffer[3] - 48) *100 + (rx_Data_Buffer[4] - 48)*10 + (rx_Data_Buffer[5] -48);
            CHECKOK <= 1'b1;
        end
        2'b11: begin
            number1 <= number1;
            number2 <= number2;
        end
        default: begin
            number1 <= 0;
            number1 <= 0; 
        end
    endcase
end

/*------Transfer Process--------*/
initial counter = 28'hfffff00;
initial begin
        tx_Data_Buffer[0] = " ";
        tx_Data_Buffer[1] = "N";
        tx_Data_Buffer[2] = "U";
        tx_Data_Buffer[3] = "M";
        tx_Data_Buffer[4] = "B";
        tx_Data_Buffer[5] = "E";
        tx_Data_Buffer[6] = "R";
        tx_Data_Buffer[7] = "1";
        tx_Data_Buffer[8] = ":";

        tx_Data_Buffer[13] = "N";
        tx_Data_Buffer[14] = "U";
        tx_Data_Buffer[15] = "M";
        tx_Data_Buffer[16] = "B";
        tx_Data_Buffer[17] = "E";
        tx_Data_Buffer[18] = "R";
        tx_Data_Buffer[19] = "2";
        tx_Data_Buffer[20] = ":";

        tx_Data_Buffer[25] = "S";
        tx_Data_Buffer[26] = "U";
        tx_Data_Buffer[27] = "M";
        tx_Data_Buffer[28] = ":";
        

        tx_Data_Buffer[33] = "C";
        tx_Data_Buffer[34] = "O";
        tx_Data_Buffer[35] = "U";
        tx_Data_Buffer[36] = "T";
        tx_Data_Buffer[37] = ":";
        tx_Data_Buffer[39] = "\n";
end
always @(posedge clk) begin
    if((CHECKOK == 1'b1))
    begin
        counter <= counter + 1'b1;

        tx_Data_Buffer[9] <= (number1/100 + 48);
        tx_Data_Buffer[10] <= ((number1%100)/10) + 48;
        tx_Data_Buffer[11] <= ((number1%100)%10) + 48;
        tx_Data_Buffer[12] <= 8'd32;

        tx_Data_Buffer[21] <= (number2/100 + 48);
        tx_Data_Buffer[22] <= ((number2%100)/10) + 48;
        tx_Data_Buffer[23] <= ((number2%100)%10) + 48;
        tx_Data_Buffer[24] <= 8'd32;

        tx_Data_Buffer[29] <= (sum/100 + 48);
        tx_Data_Buffer[30] <= ((sum%100)/10) + 48;
        tx_Data_Buffer[31] <= ((sum%100)%10) + 48;
        tx_Data_Buffer[32] <= 8'd32;
        /* verilator lint_off WIDTH */
        if(cout == 1'b1)
        begin
            tx_Data_Buffer[38] <= "1"; 
        end
        else
            tx_Data_Buffer[38] <= "0"; 
    end
end	
always @(posedge clk) begin
    if((tx_Send) && (tx_done))
        tx_index <= tx_index + 1;
end
always @(posedge clk) begin
    tx_data_in <= tx_Data_Buffer[tx_index];
end
always @(posedge clk) begin
	if ((counter == 28'hfffffff) && (tx_index <= 11'd40) && (CHECKOK == 1'b1))
		tx_Send <= 1'b1;
    if((tx_Send)&&(tx_done)&&(tx_index) >= 11'd40)
        tx_Send <= 1'b0;
end
/*------Connect Signal Module---*/
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
fullAdder 
    FA
    (
    .number1(number1),
    .number2(number2),
    .cin(cin),
    .sum(sum),
    .cout(cout)
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
        .data_in(tx_data_in),
        .tx_done(tx_done),
        .tx(o_uart_tx)
     );
endmodule
