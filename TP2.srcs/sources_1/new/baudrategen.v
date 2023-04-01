`timescale 1ns / 1ps

module baudrategen 
    #(
        parameter N_BITS = 8, //Baudclock: Clock divider, so that its frequency is 16 times that of the baudrate (by definition). Each bit takes 16xBCLK
        parameter N_BCLK_DIV = 163  
    )(
        input wire clock,
        input wire reset,
        output wire tick
    );

    reg [N_BITS - 1 : 0] count;
    reg reset_counter = (count == N_BCLK_DIV) ? 1'b1 : 1'b0;

    always @(posedge clock)
    begin
        if(reset) count <= 0;
        else if(reset_counter) count <= 0;
        else count = count + 1;
    end

    assign tick = reset_counter;

endmodule
