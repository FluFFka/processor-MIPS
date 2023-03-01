`include "src/Register.v"

module Register_tb();
    reg clk = 0;
    reg rst = 0;
    reg [31:0] my_in = 32'hDEADBEEF;
    reg my_load = 1;
    wire [31:0] my_out;
    always #2 clk = !clk;
    initial #20 $finish;
    
    Register r(.in(my_in), .clk(clk), .rst(rst), .load(my_load), .out(my_out));
    initial begin
        $dumpfile("vcd/Register_tb.vcd");
        $dumpvars(1, Register_tb);
        rst <= #1 1;
        rst <= #3 0;
        my_in <= #7 32'h0000BABE;
        my_load <= #11 0;
        my_in <= #11 32'hDEADBEEF;
        my_in <= #15 32'h1111BABE;
        rst <= #17 1;
    end
endmodule