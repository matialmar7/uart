`timescale 1ns / 1ps

module rx
    #(
        parameter N_BITS = 8,     //cantidad de bits de dato
        parameter N_TICK = 16 // # ticks para stop bits 
    )(
        input wire clock,
        input wire reset,
        input wire tick,
        input wire parity,

        //Receiver interface
        input wire rx,
        output reg RxRDYn, //Receiver ready
        output reg RxDone, //Receiver done
        output wire [N_BITS - 1:0] dout
    );

    //State declaration
    //According to Lattice semmiconductors state diagram (This implementation is a simplifed version)
    //UART Reference Design 1011 June 2011
    localparam [2 : 0] START     = 3'b000;
    localparam [2 : 0] SHIFT     = 3'b001;
    localparam [2 : 0] PARITY    = 3'b010;
    localparam [2 : 0] STOP_1B   = 3'b011;
   
    //Transmition params
    localparam START_b 1'b0;
    localparam STOP_b  1'b1;

    //Masks

    //Memory
    reg [2 : 0] state;
    reg [2 : 0] next_state;
    reg rx_reg;
    reg next_rx;
    reg paridad;
    reg done;

    //Register
    reg [N_BITS - 1 : 0] rsr; //Receiver Shift Register
    reg [N_BITS - 1 : 0] rbr; //Receiver Buffer Register
    reg [N_BITS - 1 : 0] next_rsr; 
    reg [N_BITS - 1 : 0] next_rbr; 

    //Local
    reg [4 : 0] tick_counter;
    reg [2 : 0] bit_counter;
    reg [2 : 0] start_tick_counter;
    reg [2 : 0] next_bit_counter;
    reg [4 : 0] next_tick_counter;
    reg [2 : 0] next_start_tick_counter;

    always @(posedge clock) //Memory
    begin
        if(reset) 
        begin
            RxRDYn <= 1;
            RxDone <= 1;
            state <= START;
            rx_reg <= STOP_b;   
            bit_counter <= 0;
            tick_counter <= 0;
            start_tick_counter <= 0;
        end
        else //Update every variable state
        begin
            rbr <= next_rbr;
            rsr <= next_rsr;
            rx_reg <= next_tx;
            state <= next_state;
            bit_counter <= next_bit_counter;
            tick_counter <= next_tick_counter;
            start_tick_counter <= next_start_tick_counter;
        end

    end

    always @(posedge tick) //Next state logic
    begin
        next_tick_counter = tick_counter + 1;
        RxDone = 0;
        case(state)
            START:
            begin
                if(start_tick_counter == ((N_TICK / 2)-1))
                begin
                    RxRDYn = 0;
                    next_state = SHIFT; 
                    next_tx = START_b; 
                    next_tick_counter = 0;
                    next_start_tick_counter = 0;
                end
                else 
                begin
                    if(rx == 1) 
                        next_start_tick_counter = start_tick_counter + 1;
                    else
                        next_start_tick_counter = 0;        
                    next_state = START; 
                    next_tx = STOP_b;
                end
            end
            SHIFT:
            begin
                if(tick_counter == (N_TICK - 1))
                begin
                    next_tick_counter = 0;
                    next_bit_counter = bit_counter + 1;
                    next_rbr = {rx, rbr[N_BITS - 1:1]}; //ponemos el bit en el registro b 
                    
                    if(bit_counter == (N_BITS - 1))
                    begin
                        paridad = (^next_rbr);
                    
                        if(parity) 
                            next_state = PARITY;
                        else
                            next_state = STOP_1B;
                    end
                end
            end
            PARITY:
            begin
                if(tick_counter == (N_TICK - 1))
                begin
                    next_state = STOP_1B;
                    next_tick_counter = 0;
                    
                    if(rx == paridad)
                        next_state = STOP_1B;
                    else
                        next_state = START;
                end
            end
            STOP_1B:
            begin
                if(tick_counter == (N_TICK - 1))
                begin
                    RxRDYn = 1;
                    RxDone = 1;
                    next_state = START;
                    next_tick_counter = 0;
                end                
            end
            default: //Fault recovery
            begin
                RxRDYn = 1;
                RxDone = 1;
                next_state = START_b; 
                next_tick_counter = 0;
            end
        endcase
    end

    assign dout = rx_reg;
endmodule
