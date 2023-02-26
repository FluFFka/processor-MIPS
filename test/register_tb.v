`include "src/register.v"

module Register_test();
    reg clock = 0;
    reg [31:0] my_in = 32'hDEADBEEF;
    wire [31:0] my_out;
    always #2 clock = !clock;
    initial #12 $finish;
    
    Register r(.in(my_in), .clock(clock), .load(1'b1), .out(my_out));
    initial begin
        $dumpfile("bin/register_tb.vcd");
        $dumpvars(1, Register_test);
        #3 my_in=32'h0000BABE;
    end
endmodule