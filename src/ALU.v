module ALU (
    input [31:0] in1, input [31:0] in2,
    input [5:0] opcode, input [5:0] funct,
    output reg [31:0] out, output zero
);
    always @(in1, in2, opcode, funct)
        case (opcode)
            `OPCODE_R: begin
                case (funct)
                    `FUNCT_ADD: out <= $signed(in1) + $signed(in2); // signed and unsigned doesn't matter (?)
                endcase
            end
            `OPCODE_ADDIU: out <= $unsigned(in1) + $unsigned(in2);
            `OPCODE_LW: out <= $signed(in1) + $signed(in2);   // calculate address
            `OPCODE_SW: out <= $signed(in1) + $signed(in2);   // calculate address
        endcase
    assign zero = out == 0;
endmodule