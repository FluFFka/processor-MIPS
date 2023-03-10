module DataMemory #(
    parameter MEMORY_SIZE = 64
) (
    input [31:0] addr, input [31:0] in, input clk, input rst, input write,
    output [31:0] out
);
    // Data memory byte order is big-endian
    reg [7:0] memory [0:MEMORY_SIZE-1];

    // Make every memory unit empty 
    genvar i;
    generate
        for (i = 0; i < MEMORY_SIZE; i = i + 1) begin
            always @(posedge clk, posedge rst) begin
                if (rst) begin
                    memory[i] <= 0;
                end else if (write && addr <= MEMORY_SIZE - 4) begin
                    {memory[addr], memory[addr+1], memory[addr+2], memory[addr+3]} <= in;
                end
            end
        end
    endgenerate

    assign out = (addr <= MEMORY_SIZE - 4) ? {memory[addr], memory[addr+1], memory[addr+2], memory[addr+3]} : 0;
endmodule
