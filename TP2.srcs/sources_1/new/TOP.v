`timescale 1ns / 1ps

module TOP
    #(
        parameter N_BITS = 8,     //cantidad de bits de dato
        parameter N_BITS_OP   = 6,
        parameter CLK = 50e6,
        parameter BAUD_RATE = 115200
    )(
        input wire clock,
        input wire reset,
        input wire parity,

        //UART interface
        input wire rx,
        output wire tx
    );
    wire rx_done, tx_done;
    wire [N_BITS - 1 : 0] tx_data;
    wire [N_BITS - 1 : 0] rx_data;
    wire [N_BITS - 1 : 0] A;
    wire [N_BITS - 1 : 0] B;
    wire [N_BITS_OP - 1 : 0] OP;
    wire[N_BITS - 1 : 0] RES;

    uart#(.CLK(CLK), .BAUD_RATE(BAUD_RATE)) instancia_uart
    (
        .clock(clock),
        .reset(reset),
        .parity(parity),
        .rx(rx),
        .tx(tx),
        .rx_done(rx_done),
        .tx_done(tx_done),
        .rx_data(rx_data),
        .tx_data(tx_data)
    );
    
    interface instancia_interface
	(
		.clock(clock),
		.reset(reset),
		.rx_done(rx_done),
		.tx_done(tx_done),
		.i_data(rx_data),
		.i_RES(RES),

		.o_A(A),
		.o_B(B),
		.o_OP(OP),
		.o_RES(tx_data)		
	);

    ALU #(.N_BITS (N_BITS))instancia_ALU
    (
        .i_A(A),
        .i_B(B),
        .i_OP(OP),
        .o_RES(RES)
    );
      

endmodule
