`ifndef __ASM_VH
`define __ASM_VH

// Здесь хранятся макроопределения для удобного написания инструкций mips в машинном коде для использования в памяти инструкций.
// Названия макроопеределений говорят сами за себя.
// Порядок аргументах в макроопределениях - как в общеизвестной ассемблерной записи.
// Пример использования: `ASM_ADDI(5'd1, 5'd2, 16'd500)

`include "opcodes.vh"
`include "funct.vh"

`define ASM_ADD(DST, SRC1, SRC2) {`OPCODE_R, SRC1, SRC2, DST, 5'd0, `FUNCT_ADD}
`define ASM_SUB(DST, SRC1, SRC2) {`OPCODE_R, SRC1, SRC2, DST, 5'd0, `FUNCT_SUB}
`define ASM_SLT(DST, SRC1, SRC2) {`OPCODE_R, SRC1, SRC2, DST, 5'd0, `FUNCT_SLT}

`define ASM_ADDI(DST,SRC,IMM) {`OPCODE_ADDI, SRC, DST, IMM}
`define ASM_SLTI(DST, SRC, IMM) {`OPCODE_SLTI, SRC, DST, IMM}

`define ASM_BEQ(SRC1, SRC2, IMM)  {`OPCODE_BEQ, SRC1, SRC2, IMM}
`define ASM_BNE(SRC1, SRC2, IMM)  {`OPCODE_BNE, SRC1, SRC2, IMM}

`define ASM_LW(DST, ADDR, IMM) {`OPCODE_LW, ADDR, DST, IMM}
`define ASM_SW(VAL, ADDR, IMM) {`OPCODE_SW, ADDR, VAL, IMM}

`define ASM_J(IMM) {`OPCODE_J, IMM}

`define ASM_NOP {`OPCODE_ADDI, 5'd0, 5'd0, 16'd0}

`endif // __ASM_VH
