/* ALU Code */
`define R_ALUCODE        3'b000
`define L_S_ADDI_ALUCODE 3'b001
`define ANDI_ALUCODE     3'b010
`define ORI_ALUCODE      3'b011
`define XORI_ALUCODE     3'b100
`define LUI_ALUCODE      3'b101
`define SLTI_ALUCODE     3'b110

/* OPERACIONES ALU*/
`define SRL             4'b0001
`define SRA             4'b0010
`define ADD             4'b0011
`define SUB             4'b0100
`define AND             4'b0101
`define OR              4'b0110
`define XOR             4'b0111
`define NOR             4'b1000

`define N_ELEMENTS 128
`define ADDRWIDTH $clog2(`N_ELEMENTS)