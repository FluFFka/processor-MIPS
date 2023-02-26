`include "src/RegisterZero.v"

module RegisterZero_tb();
    reg clock = 0;
    reg [31:0] my_in = 32'hDEADBEEF;
    reg my_load = 1;
    wire [31:0] my_out;
    always #2 clock = !clock;
    initial #20 $finish;
    
    RegisterZero r(.in(my_in), .clock(clock), .load(my_load), .out(my_out));
    initial begin
        $dumpfile("vcd/RegisterZero_tb.vcd");
        $dumpvars(1, RegisterZero_tb);
        my_in <= #3 32'h0000BABE;
        my_load <= #7 0;
        my_in <= #7 32'hDEADBEEF;
        my_in <= #11 32'h1111BABE;
    end
endmodule