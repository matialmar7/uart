`timescale 1ns / 1ps

module tb_rx;
    localparam CLK = 50e6;
    localparam BAUD_RATE = 115200; //56 ns por tick
    localparam N_BITS = 8;
    //Inputs and outputs declaration
    reg clock, reset, parity,rx;
    wire [N_BITS - 1 : 0] rx_data;
    wire tick, rx_done;
    
    //Instancio Baudrate generator
    baudrategen#(.CLK(CLK), .BAUD_RATE(BAUD_RATE)) instancia_bd
    (
        .clock(clock),
        .reset(reset),
        .tick(tick)
    );
    
    rx#(.N_BITS(N_BITS)) instancia_rx
    (
        .clock(clock),
        .reset(reset),
        .tick(tick),
        .parity(parity),

        .dout(rx_data),
        .rx(rx),
        .RxDone(rx_done)
    );
    //Create a clock
    always #1 clock = ~clock; // # < timeunit > delay
    
    //Initial block will only excecute once.
    initial
    begin
    //For value (wire and reg) change saving 
    $dumpfile("tb_rx.vcd");
    //Specify variables to be dumped, w/o any argument it dumps all variables 
    $dumpvars;
    #0 //ns
    reset = 1;
    clock = 1;
    parity = 1;
    rx = 0;
    #1
    reset = 0;
    //--------------------Inicio transmicion serial------------------//
    #54
    rx = 1; 
    //--------------------Inicia trama-------------------------------//
    //Transmicion de trama 0110 1011 paridad 1 (impar)
    //16 ticks 
    #896 
    //bit 0
    rx = 0; 
    #896
    //bit 1
    rx = 1;
    #896
    //bit 2
    rx = 1;
    #896
    //bit 3
    rx = 0;
    #896
    //bit 4
    rx = 1;
    #896
    //bit 5
    rx = 0;
    #896
    //bit 6
    rx = 1;
    #896
    //bit 7
    rx = 1;
    #896
    //bit paridad
    rx = 1;
    #896
    rx = 0;
    #896
    #896
    $finish;
    
    end
    
endmodule