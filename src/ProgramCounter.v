module ProgramCounter (
    input [31:0] in, input clock, input load,
    output reg [31:0] out

);
    always @(posedge clock) begin
        if (load) out <= in;
    end
endmodule