`include "include/opcodes.vh"
`include "include/funct.vh"

`include "src/ProgramCounter.v"
`include "src/InstructionMemory.v"
`include "src/DataMemory.v"
`include "src/RegisterSet.v"
`include "src/ALU.v"

module CPU (
    input clk, input rst
);
    reg pc_load = 1;
    wire [31:0] pc_out;
    wire [31:0] pc_in;
    ProgramCounter PC(
        .in(pc_in), .clk(clk), .rst(rst), .load(pc_load),
        .out(pc_out)
    );


    wire [31:0] curr_instruction;
    InstructionMemory im(
        .addr(pc_out), .clk(clk),
        .out(curr_instruction)
    );


    wire [5:0] opcode = curr_instruction[31:26];
    // R-type
    wire [4:0] rs = curr_instruction[25:21];    // also for I-type
    wire [4:0] rt = curr_instruction[20:16];    // also for I-type
    wire [4:0] rd = curr_instruction[15:11];
    wire [4:0] shamt = curr_instruction[10:6];
    wire [5:0] funct = curr_instruction[5:0];
    // I-type
    wire [15:0] IMM = curr_instruction[15:0];
    wire [31:0] EXT_IMM = $signed(IMM);
    // J-type
    wire [25:0] ADDR = curr_instruction[25:0];
    wire [31:0] EXT_ADDR = $unsigned(ADDR);


    wire [4:0] rnum1;
    wire [4:0] rnum2;
    wire [4:0] wnum;
    wire reg_write;
    wire [31:0] wdata;
    wire [31:0] rdata1;
    wire [31:0] rdata2;
    RegisterSet registers(
        .rnum1(rnum1), .rnum2(rnum2), .wnum(wnum),
        .clk(clk), .rst(rst), .write(reg_write), .wdata(wdata),
        .rdata1(rdata1), .rdata2(rdata2)
    );


    wire alu_zero;
    wire [31:0] alu_in1;
    wire [31:0] alu_in2;
    wire [31:0] alu_out;
    ALU alu(
        .in1(alu_in1), .in2(alu_in2), .opcode(opcode), .funct(funct),
        .out(alu_out), .zero(alu_zero)
    );
    assign alu_in1 = rdata1;
    assign alu_in2 = (opcode == `OPCODE_R) ? rdata2 : EXT_IMM;


    assign rnum1 = rs;
    assign rnum2 = rt;
    assign wnum = (opcode == `OPCODE_R) ? rd : rt;
    assign reg_write = (opcode == `OPCODE_BEQ || opcode == `OPCODE_BNE ||
                        opcode == `OPCODE_J || opcode == `OPCODE_SW) ? 0 : 1;
    // out later change to multiplexer (for write in data and registers)
    assign wdata = alu_out;


    assign pc_in = (opcode == `OPCODE_J) ?
                        EXT_ADDR : 
                        ((opcode == `OPCODE_BEQ && rdata1 == rdata2) ||
                         (opcode == `OPCODE_BNE && rdata1 != rdata2)) ? 
                            $signed(pc_out) + $signed(EXT_IMM << 2) + 4 :
                            pc_out + 4;


endmodule