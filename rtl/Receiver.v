module Receiver
    #(
        parameter   DBITS = 8,                              // number of data bits in a data word
                    SB_TICK = 16                            // number of stop bit / oversampling ticks (1 stop bit)
    )
    (
        input clk,              
        input reset,                                        // reset
        input rx,                                           // receiver data line
        input sample_tick,                                  // sample tick from baud rate generator
        output reg data_ready,                              // signal when new data word is complete (received)
        output [DBITS-1:0] data_out                         // data to FIFO
    );
    
    // State Machine States
    localparam [1:0] idle  = 2'b00,                         // IDLE state
                     start = 2'b01,                         // START state
                     data  = 2'b10,                         // DATA state
                     stop  = 2'b11;                         // STOP state
    
    // Registers                 
    reg [1:0] state, next_state;                            // state registers
    reg [4:0] tick_reg, tick_next;                          // number of ticks received from baud rate generator
    reg [3:0] nbits_reg, nbits_next;                        // number of bits received in data state
    reg [7:0] data_reg, data_next;                          // reassembled data word
    
    // Register Logic
    always @(posedge clk, posedge reset)
        if(reset) begin
            state <= idle;                                  // state is idle
            tick_reg <= 0;                                  // reset tick reg
            nbits_reg <= 0;                                 // reset number bit reg
            data_reg <= 0;                                  // reset data reg
        end
        else begin
            state <= next_state;                            // assign state to the next state
            tick_reg <= tick_next;                          // assign tick reg for the tick next
            nbits_reg <= nbits_next;                        // assign number bit reg to the number bit next
            data_reg <= data_next;                          // assign data reg to the data next
        end         

    // State Machine Logic
    always @* begin
        next_state = state;             
        data_ready = 1'b0;
        tick_next = tick_reg;
        nbits_next = nbits_reg;
        data_next = data_reg;
        
        case(state)
            idle:
                if(~rx) begin                               // when data line goes LOW (start condition)
                    next_state = start;                     // next state to the start state    
                    tick_next = 0;
                end
            start:
                if(sample_tick)                             // if is ennough to the baud rate
                    if(tick_reg == 7) begin                 // enough for the 8 bit
                        next_state = data;                  // next state is data
                        tick_next = 0;
                        nbits_next = 0;
                    end
                    else
                        tick_next = tick_reg + 1;           // calculate tick reg
            data:
                if(sample_tick)
                    if(tick_reg == 15) begin                
                        tick_next = 0;
                        data_next = {rx, data_reg[7:1]};    // data_next store data
                        if(nbits_reg == (DBITS-1))
                            next_state = stop;
                        else
                            nbits_next = nbits_reg + 1;
                    end
                    else
                        tick_next = tick_reg + 1;
            stop:
                if(sample_tick)
                    if(tick_reg == (SB_TICK-1)) begin
                        next_state = idle;
                        data_ready = 1'b1;
                    end
                    else
                        tick_next = tick_reg + 1;
        endcase                    
    end
    
    // Output Logic
    assign data_out = data_reg;

endmodule