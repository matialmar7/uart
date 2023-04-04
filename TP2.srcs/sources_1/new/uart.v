`timescale 1ns / 1ps

module uart
    #(
        parameter CLK = 50e6,
        parameter BAUD_RATE = 9600,
        parameter NB_DATA = 8

    )(
        input wire clock,
        input wire reset,
        input wire parity,
        input wire [NB_DATA - 1 : 0] tx_data,
        output wire [NB_DATA - 1 : 0] rx_data,
        
        input wire rx,
        output wire rx_ready,
        output wire rx_done,
        output wire tx
        output wire tx_done,
        output wire tx_ready,
    );
    
    wire tick;

    baudrategen#(.CLK(CLK), .BAUD_RATE(BAUD_RATE)) instancia_bd
    (
        .clock(clock),
        .reset(reset),
        .tick(tick)
    );

    tx#() instancia_tx
    (
        .clock(clock),
        .reset(reset),
        .tick(tick),
        .parity(parity),

        .din(tx_data),
        .tx(tx),
        .TxRDYn(tx_ready),
        .TxDone(tx_done)
    )

    rx#() instancia_rx
    (
        .clock(clock),
        .reset(reset),
        .tick(tick),
        .parity(parity),

        .rx(rx),
        .dout(rx_data),
        .RxRDYn(rx_ready),
        .RxDone(rx_done)
    )
endmodule