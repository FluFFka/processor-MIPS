module ALU (
    input [31:0] in1, input [31:0] in2,
    input [5:0] opcode,
    output reg [31:0] out, output zero
);
    always @(in1, in2, opcode)
        case (opcode)
            6'b100000: out = in1 + in2;
            6'b100010: out = in1 - in2;
        endcase
    assign zero = out == 0;
endmodule