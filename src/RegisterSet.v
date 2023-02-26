module RegisterSet (
    input [4:0] rnum1, input [4:0] rnum2, input [4:0] wnum,
    input clock, input write, input [31:0] wdata,
    output reg [31:0] rdata1, output reg [31:0] rdata2
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
    reg [31:0] register_input [31:0];
    wire [31:0] register_output [31:0];
    reg register_load [31:0];
    // $zero initialization
    RegisterZero zero(.in(register_input[0]), .clock(clock), .load(register_load[0]),
        .out(register_output[0]));
    // other registers initialization
    genvar j;
    generate
        for (j = 1; j <= 31; j = j + 1)
            Register r(.in(register_input[j]), .clock(clock), .load(register_load[j]),
                .out(register_output[j]));
    endgenerate

    // procedures for each register
    genvar i;
    generate
        for (i = 0; i <= 31; i = i + 1) begin
            always @(posedge clock) begin
                register_load[i] <= 1'b0;
                if (i == rnum1) begin
                    rdata1 <= register_output[i];
                end
                if (i == rnum2) begin
                    rdata2 <= register_output[i];
                end
                if (write && (i == wnum)) begin
                    register_input[i] <= wdata;
                    register_load[i] <= 1'b1;
                end
            end
        end
    endgenerate
endmodule