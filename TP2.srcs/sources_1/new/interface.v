
module Int_Alu
	#(
		parameter N_BITS_DATA  = 8,
		parameter N_BITS_OP    = 6,
		parameter N_BITS_STATE = 4
	)
	(
		input wire clock,
		input wire reset,
		input wire rx_done,
		output wire  tx_done,								
		input wire [N_BITS_DATA-1:0] i_data,
		input wire [N_BITS_DATA-1:0] i_RES,		
		output wire [N_BITS_DATA-1:0] o_A,
		output wire [N_BITS_DATA-1:0] o_B,
		output wire [N_BITS_OP-1:0] o_OP,
		output wire [N_BITS_DATA-1:0] o_RES
	);

	localparam 	[N_BITS_STATE-1:0]          DatoA     =  4'b0001;
	localparam 	[N_BITS_STATE-1:0]			DatoB     =  4'b0010;
	localparam 	[N_BITS_STATE-1:0]			DatoOp    =  4'b0100;
	localparam 	[N_BITS_STATE-1:0]			ResultALU =  4'b1000;

    reg [N_BITS_DATA-1:0] A, B, RES;
	reg [N_BITS_OP-1:0] OP;
	reg tx_done_reg;
	reg read_A_en, read_B_en, read_Op_en, send_tx_result;
	reg [N_BITS_STATE-1:0] state, next_state;

    always @(posedge clock) 
    begin			
        if (reset)
            begin
                state <= DatoA;	

                A   <= {N_BITS_DATA{1'b0}};
                B   <= {N_BITS_DATA{1'b0}};
                OP  <= {N_BITS_DATA{1'b0}};	
                RES <= {N_BITS_DATA{1'b0}};		
            end
        else
            begin
                state <= next_state;

                if (read_A_en)  A <= i_data;
                if (read_B_en)	B <= i_data;
                if (read_Op_en) OP <= i_data;
                if (send_tx_result)
                    begin
                        RES <= i_RES;
                        tx_done_reg <= 1'b1;
                    end
                else
                    tx_done_reg <= 1'b0;
        end
    end

	always @(*) //logica de cambio de estado
		begin: next_state_logic
		
		    read_A_en = 1'b0;
		    read_B_en = 1'b0;
			read_Op_en = 1'b0;
			send_tx_result = 1'b0;
			next_state = state;

			case (state)
				A:
					begin
						if (rx_done)
							begin
								read_A_en = 1'b1;
								next_state  = DatoB;																								
							end
						else
						  begin
						      next_state  = DatoA;						      
						  end
							
											
					end
				B:
					begin
						if (rx_done)
							begin
								read_B_en = 1'b1;
								next_state  = DatoOp;								
							end				
					   else
						  begin
						      next_state  = DatoB;						      
						  end						
					end
				DatoOp:					
					begin
						if (rx_done)
							begin
								read_Op_en = 1'b1;
								next_state  = ResultALU;								
							end
						else
						  begin
						      next_state  = DatoOp;						      
						  end
								
					end						
				ResultALU: 
					begin
						send_tx_result = 1'b1;
						next_state   = A;
					end
				default:
					next_state = A;					
			endcase
		end

    /* Salidas */
	assign o_A           = A;
	assign o_B           = B;
	assign o_OP          = OP;
	assign o_RES         = RES;
	assign tx_done     = tx_done_reg;
endmodule