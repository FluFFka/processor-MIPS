module RegisterSet (
    input [4:0] rnum1, input [4:0] rnum2, input [4:0] wnum,
    input clk, input rst, input write, input [31:0] wdata,
    output [31:0] rdata1, output [31:0] rdata2
);
    /*
        32 registers:
            $zero
            $at
            $v0-$v1
            $a0-$a3
            $t0-$t7
            $s0-$s7
            $t8-$t9
            $k0-$k1
            $gp
            $sp
            $fp
            $ra
    */
    wire [31:0] register_input [31:0];
    wire [31:0] register_output [31:0];
    wire register_load [31:0];
    // $zero initialization
    RegisterZero zero(.in(register_input[0]), .clk(clk), .rst(rst), .load(register_load[0]),
        .out(register_output[0]));
    // other registers initialization
    genvar j;
    generate
        for (j = 1; j <= 31; j = j + 1)
            Register r(.in(register_input[j]), .clk(clk), .rst(rst), .load(register_load[j]),
                .out(register_output[j]));
    endgenerate

    assign rdata1 = rst ? 0 : register_output[rnum1];
    assign rdata2 = rst ? 0 : register_output[rnum2];
    genvar i;
    generate
        for (i = 0; i < 31; i = i + 1) begin
            assign register_input[i] = wdata;
            assign register_load[i] = (write && (i == wnum)) ? 1 : 0;
        end    
    endgenerate
endmodule