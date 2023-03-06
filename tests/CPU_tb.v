`include "src/CPU.v"

module CPU_tb();
    reg clk = 0;
    reg rst = 1;
    always #1 clk = !clk;
    initial #20 $finish;
    
    CPU cpu(.clk(clk), .rst(rst));
    initial begin
        $dumpfile("vcd/CPU_tb.vcd");
        $dumpvars(1, cpu);
        $dumpvars(1, cpu.im);
        $dumpvars(0, cpu.registers);
        $dumpvars(1, cpu.alu);
        $dumpvars(1, CPU_tb);
        rst <= #4 0;
    end
endmodule