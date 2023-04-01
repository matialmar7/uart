`timescale 1ns / 1ps

module tx
    #(
        parameter N_BITS = 8,     //cantidad de bits de dato
        parameter N_TICK = 16 // # ticks para stop bits 
    )(
        input wire clk,
        input wire reset,
        input wire tick,
        input wire parity,

        input wire [N_BITS - 1 : 0] din, //Data input

        //Receiver interface
        output reg TxRDYn, //Transmitter ready
        output reg TxDone, //Transmitter ready
        output wire tx //Transmitter serial output
    );

    //State declaration
    //According to Lattice semmiconductors state diagram (This implementation is a simplifed version)
    //UART Reference Design 1011 June 2011
    localparam [2 : 0] START     = 3'b000;
    localparam [2 : 0] SHIFT     = 3'b001;
    localparam [2 : 0] PARITY    = 3'b010;
    localparam [2 : 0] STOP_1B   = 3'b011;
    //Not implemented:
    //localparam [2 : 0] STOP_2B   = 3'b100;
    //localparam [2 : 0] STOP_1_5B = 3'b101;
    
    //Transmition params
    localparam START_b 1'b0;
    localparam STOP_b  1'b1;

    //Masks

    //Memory
    reg [2 : 0] state;
    reg [2 : 0] next_state;
    reg tx_reg;
    reg next_tx;
    reg paridad;
    reg done;

    //Register
    reg [N_BITS - 1 : 0] tsr; //Transmit Shift Register
    reg [N_BITS - 1 : 0] thr; //Transmit Holding Register
    reg [N_BITS - 1 : 0] lsr; //Line Status Register

    //Local
    reg [4 : 0] tick_counter;
    reg [2 : 0] bit_counter;

    always @(posedge clk) //Memory
    begin
        if(reset) 
        begin
            state <= START;
            thr <= 0;
            tsr <= 0;
            tx_reg <= STOP_b; 
            tick_counter <= 0;
            bit_counter <= N_BITS;
            TxRDYn <= 1;
            TxDone <= 1;
        end
        else //Update every state
        begin
            state <= next_state;
            tx_reg <= next_tx;
        end

    end

    always @(tick) //Next state logic
    begin
        tick_counter = tick_counter + 1;
        TxDone = 0;
        case(state)
            START:
            begin
                if(thr == 0)
                begin
                    next_state = START; 
                    next_tx = STOP_b;
                    thr = din;
                    tsr = thr;
                end
                else
                begin
                    next_state = SHIFT; 
                    next_tx = START_b; 
                    tick_counter = 0;
                    TxRDYn = 0;
                end
            end
            SHIFT:
            begin
                next_tx = tsr[0];
                if(tick_counter == (N_TICK - 1))
                begin
                    tsr = tsr >> 1;
                    bit_counter = bit_counter + 1;
                    if(bit_counter == (N_BITS -1))
                    begin
                        next_state = PARITY;
                        paridad = (^thr);
                        bit_counter = 0;
                    end
                    tick_counter = 0;
                end
            end
            PARITY:
            begin
                next_tx = paridad;
                if(tick_counter == (N_TICK - 1))
                begin
                    next_state = STOP_1B;
                    tick_counter = 0;
                end
            end
            STOP_1B:
            begin
                next_tx = STOP_b;
                if(tick_counter == (N_TICK - 1))
                begin
                    next_state = START;
                    thr = 0;
                    tsr = 0;
                    TxRDYn = 1;
                    tick_counter = 0;
                end                
            end
            default: //Fault recovery
            begin
                next_state = START_b; 
                thr = 0;
                tsr = 0;
                TxRDYn = 1;
                TxDone = 1;
                tick_counter = 0;
            end
        endcase
    end

    assign tx = tx_reg;
endmodule
