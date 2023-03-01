module RegisterZero (
    input [31:0] in, input clock, input load,
    output reg [31:0] out
); 
    always @(posedge clock)
        out <= 32'b0;
endmodule