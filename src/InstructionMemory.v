module InstructionMemory #(
    parameter MEMORY_SIZE = 16
) (
    input [31:0] addr, input clk, input rst,
    output [31:0] out
);
    reg [7:0] memory [0:MEMORY_SIZE-1];

    always @(posedge clk) begin
        // Instruction memory byte order is big-endian
        if (rst)
            $readmemb("input/1.mem", memory);
    end

    assign out = addr <= MEMORY_SIZE - 4 ? {memory[addr], memory[addr+1], memory[addr+2], memory[addr+3]} : 0;
endmodule