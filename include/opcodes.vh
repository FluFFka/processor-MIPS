`ifndef __OPCODES_VH
`define __OPCODES_VH

// https://opencores.org/projects/plasma/opcodes

// Здесь хранятся макроопределения для кодов операций MIPS.
// Названия говорят сами за себя.
`define OPCODE_R        6'b000000
`define OPCODE_ADDI     6'b001000
`define OPCODE_ADDIU    6'b001001
`define OPCODE_SLTI     6'b001010
`define OPCODE_BEQ      6'b000100
`define OPCODE_BNE      6'b000101
`define OPCODE_LW       6'b100011
`define OPCODE_SW       6'b101011
`define OPCODE_J        6'b000010

`endif // __OPCOEDS_VH
