`timescale 1ns / 1ps

module tb_tx;
    localparam CLK = 50e6;
    localparam BAUD_RATE = 115200;
    localparam N_BITS = 8;
    //Inputs and outputs declaration
    reg clock, reset, parity;
    reg [N_BITS - 1 : 0] tx_data;
    wire tick, tx, tx_ready, tx_done;
    
    //Instancio Baudrate generator
    baudrategen#(.CLK(CLK), .BAUD_RATE(BAUD_RATE)) instancia_bd
    (
        .clock(clock),
        .reset(reset),
        .tick(tick)
    );
    
    tx#(.N_BITS(N_BITS)) instancia_tx
    (
        .clock(clock),
        .reset(reset),
        .tick(tick),
        .parity(parity),

        .din(tx_data),
        .tx(tx),
        .TxRDYn(tx_ready),
        .TxDone(tx_done)
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
    clock = 1;
    parity = 1;
    tx_data = 8'b01010101;
    #1
    reset = 0;
    #10000
    $finish;
    
    end
    
endmodule