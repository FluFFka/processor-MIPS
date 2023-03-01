`include "src/ProgramCounter.v"
`include "src/InstructionMemory.v"
`include "src/DataMemory.v"

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

    assign pc_in = pc_out + 4; // later convert to multiplexer (because of jumps)


    wire [31:0] curr_instruction;
    InstructionMemory im(
        .addr(pc_out), .clk(clk), .rst(rst),
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
    // J-type
    wire [25:0] ADDR = curr_instruction[25:0];

endmodule