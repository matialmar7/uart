`timescale 1ns / 1ps

module tb_uarts;
    localparam CLK = 50e6;
    localparam BAUD_RATE = 115200;
    localparam N_BITS = 8;

    //Inputs and outputs declaration
    reg clock, reset, tx_start;
    reg parity = 1;
    wire clock_rx, clock_tx, tick_rx, tick_tx,  tx, tx_done, rx_done;
    reg [N_BITS - 1 : 0] tx_data;
    wire [N_BITS - 1 : 0] rx_data;
    
    //Instancio Baudrate generator
    baudrategen#(.CLK(CLK), .BAUD_RATE(BAUD_RATE)) instancia_bd_tx
    (
        .clock(clock_tx),
        .reset(reset),
        .tick(tick_tx)
    );
    //Instancio Baudrate generator
    baudrategen#(.CLK(CLK), .BAUD_RATE(BAUD_RATE)) instancia_bd_rx
    (
        .clock(clock_rx),
        .reset(reset),
        .tick(tick_rx)
    );
    
    tx#(.N_BITS(N_BITS)) instancia_tx
    (
        .clock(clock_tx),
        .reset(reset),
        .tick(tick_tx),
        .parity(parity),
        .tx_start(tx_start),

        .din(tx_data),
        .tx(tx),
        .TxDone(tx_done)
    );

    rx#(.N_BITS(N_BITS)) instancia_rx
    (
        .clock(clock_rx),
        .reset(reset),
        .tick(tick_rx),
        .parity(parity),

        .dout(rx_data),
        .rx(tx),
        .RxDone(rx_done)
    );
    assign clock_tx = clock;
    assign clock_rx = ~clock;

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
    tx_data = 8'b00001111;
    tx_start = 0;
    #2
    reset = 0;
    #100
    tx_start = 1;
    #100
    tx_start = 0;
    
    while (!tx_done) begin
        #5; // Wait 5 time units before checking again
    end   
    
    tx_data = 8'b11110000;
    #100
    tx_start = 1;
    #100
    tx_start = 0;
    
        while (!tx_done) begin
        #5; // Wait 5 time units before checking again
    end   
    
    tx_data = 8'b01010101;
    #100
    tx_start = 1;
    #100
    tx_start = 0;
    #10000000
    $finish;
    
    end
    
endmodule