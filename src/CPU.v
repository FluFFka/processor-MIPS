`include "src/ProgramCounter.v"
`include "src/InstructionMemory.v"

module CPU (
    input wire clock
);
    reg [31:0] pc_in = 0;
    reg pc_load = 1'b1;
    wire [31:0] pc_out;
    ProgramCounter PC(
        .in(pc_in), .clock(clock), .load(pc_load),
        .out(pc_out)
    );

    wire [31:0] curr_instruction;
    InstructionMemory im(
        .addr(pc_out), .clock(clock),
        .out(curr_instruction)
    );

    reg [5:0] opcode, funct;
    reg [4:0] rs, rt, rd, shamt;

    always @* begin
        pc_in = pc_out + 4;
        pc_load = 1'b1;
        
        {opcode, rs, rt, rd, shamt, funct} = curr_instruction;
    end
endmodule