module Register(input [31:0] in, input clock, input load,
                output reg [31:0] out);
    always @(posedge clock)
        if (load) out <= in;
endmodule