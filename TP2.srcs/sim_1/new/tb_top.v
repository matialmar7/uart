`timescale 1ns / 1ps

module tb_uarts;
    localparam CLK = 50e6;
    localparam BAUD_RATE = 115200;
    localparam N_BITS = 8;

    //Inputs and outputs declaration
    reg  clock, reset, parity;

    //Create a clock
    always #1 clock = ~clock; // # < timeunit > delay
    //Initial block will only excecute once.
    initial
    begin
    //For value (wire and reg) change saving 
    $dumpfile("tb_tx.vcd");
    //Specify variables to be dumped, w/o any argument it dumps all variables 
    $dumpvars;
    #0
    reset = 1;
    clock = 1;
    parity = 1;
    #2
    reset = 0;
    #2
    #10000
    $finish;
    
    end
    
endmodule