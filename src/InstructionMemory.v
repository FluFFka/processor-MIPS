module InstructionMemory #(
    parameter MEMORY_SIZE = 64
) (
    input [31:0] addr, input clk,
    output [31:0] out
);
    reg [7:0] memory [0:MEMORY_SIZE-1];

    initial $readmemb("input/2.mem", memory);

    assign out = (addr <= MEMORY_SIZE - 4) ? {memory[addr], memory[addr+1], memory[addr+2], memory[addr+3]} : 0;
endmodule