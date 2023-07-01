module Transmitter
    #(
        parameter   DBITS = 8,                      // number of data bits
                    SB_TICK = 16                    // number of stop bit / oversampling ticks (1 stop bit)
    )
    (
        input clk,                                  // clk
        input reset,                                // reset
        input tx_start,                             // begin data transmission (FIFO NOT empty)
        input sample_tick,                          // from baud rate generator
        input [DBITS-1:0] data_in,                  // data word from FIFO
        output reg tx_done,                         // end of transmission
        output tx                                   // transmitter data line
    );
    
    // State Machine States
    localparam [1:0]    idle  = 2'b00,              // IDLE state
                        start = 2'b01,              // START state
                        data  = 2'b10,              // DATA state
                        stop  = 2'b11;              // STOP state
    
    // Registers                    
    reg [1:0] state, next_state;                    // state registers
    reg [4:0] tick_reg, tick_next;                  // number of ticks received from baud rate generator
    reg [3:0] nbits_reg, nbits_next;                // number of bits transmitted in data state
    reg [DBITS-1:0] data_reg, data_next;            // assembled data word to transmit serially
    reg tx_reg, tx_next;                            // data filter for potential glitches
    
    // Register Logic
    always @(posedge clk, posedge reset)
        if(reset) begin                             // if reset button is pressed
            state <= idle;                          // State is IDLE
            tick_reg <= 0;                          // Init tick reg
            nbits_reg <= 0;                         // init bit reg
            data_reg <= 0;                          // init data reg
            tx_reg <= 1'b1;                         // init tx_reg
        end
        else begin
            state <= next_state;                    // assign state for next state
            tick_reg <= tick_next;                  // assign tick for tick next
            nbits_reg <= nbits_next;                // assign nbits next for nbit reg
            data_reg <= data_next;                  // assign data reg for data next
            tx_reg <= tx_next;                      // assign tx_next for tx_reg
        end
    
    // State Machine Logic
    always @* begin
        next_state = state;
        tx_done = 1'b0;
        tick_next = tick_reg;
        nbits_next = nbits_reg;
        data_next = data_reg;
        tx_next = tx_reg;
        
        case(state)
            idle: begin                             // no data in FIFO
                tx_next = 1'b1;                     // transmit idle
                if(tx_start) begin                  // when FIFO is NOT empty
                    next_state = start;             // next_state for start
                    tick_next = 0;                  // init tick_next to zero
                    data_next = data_in;            // assign data_in to data_next
                end
            end
            
            start: begin
                tx_next = 1'b0;                     // start bit
                if(sample_tick)                     // when sample_tick is set 1, the next state is data
                    if(tick_reg == 15) begin        // when tick reg is = 16 bit, it mean count enough for 16 bits
                        next_state = data;          // next_state is data
                        tick_next = 0;              // tick_next is zero
                        nbits_next = 0;
                    end
                    else
                        tick_next = tick_reg + 1;   // caculate tick next
            end
            
            data: begin
                tx_next = data_reg[0];              // Assign bit zero of data to tx_next
                if(sample_tick)                     // Is enough the baud rate
                    if(tick_reg == 15) begin
                        tick_next = 0;
                        data_next = data_reg >> 1;  // Shift bit data
                        if(nbits_reg == (DBITS-1))  // If number of bit is = 8 bits
                            next_state = stop;      // finish the transfer bit
                        else
                            nbits_next = nbits_reg+1;// if not, continue counting
                    end
                    else
                        tick_next = tick_reg + 1;   //counting for baudrate
            end
            
            stop: begin
                tx_next = 1'b1;         // back to idle
                if(sample_tick)
                    if(tick_reg == (SB_TICK-1)) begin
                        next_state = idle;
                        tx_done = 1'b1;
                    end
                    else
                        tick_next = tick_reg + 1;
            end
        endcase    
    end
    
    // Output Logic
    assign tx = tx_reg;
 
endmodule

