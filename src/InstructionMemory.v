module InstructionMemory (
    input [31:0] addr, input clock,
    output reg [31:0] out
);
    reg [7:0] Memory [0:15];

    initial begin
        // Instruction memory byte order is big-endian
        $readmemb("input/1.mem", Memory);
    end

    always @(posedge clock) begin
        if (addr <= 12)
            out = {Memory[addr], Memory[addr+1], Memory[addr+2], Memory[addr+3]};
        else
            out = 32'h00000000;
    end

endmodule