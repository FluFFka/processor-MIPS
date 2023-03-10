module Register (
    input [31:0] in, input clk, input rst, input load,
    output reg [31:0] out
);
    always @(posedge clk, posedge rst) begin
        if (rst) out <= 0;
        else if (load) out <= in;
    end
endmodule