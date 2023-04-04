`timescale 1ns / 1ps

module tb_bd;
    localparam CLK = 50e6;
    localparam BAUD_RATE = 9600;
    //Inputs and outputs declaration
    reg clock, reset;
    wire tick;
    
    //Instancio Baudrate generator
    baudrategen#(.CLK(CLK), .BAUD_RATE(BAUD_RATE)) instancia_bd
    (
        .clock(clock),
        .reset(reset),
        .tick(tick)
    );
    
    //Create a clock
    always #1 clock = ~clock; // # < timeunit > delay
    
    //Initial block will only excecute once.
    initial
    begin
    //For value (wire and reg) change saving 
    $dumpfile("tb_bd.vcd");
    //Specify variables to be dumped, w/o any argument it dumps all variables 
    $dumpvars;
    #0
    reset = 1;
    clock = 0;
    #1
    reset = 0;
    #10000
    $finish;
    
    end
    
endmodule