`include "src/CPU.v"

module CPU_tb();
    reg clock = 0;
    always #1 clock = !clock;
    initial #20 $finish;
    
    CPU cpu(.clock(clock));
    initial begin
        $dumpfile("vcd/CPU_tb.vcd");
        $dumpvars(1, cpu);
        $dumpvars(1, CPU_tb);
    end
endmodule