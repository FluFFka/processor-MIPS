`include "include/opcodes.vh"
`include "include/funct.vh"

`include "src/ProgramCounter.v"
`include "src/InstructionMemory.v"
`include "src/DataMemory.v"
`include "src/RegisterSet.v"
`include "src/ALU.v"

`define NOOP    32'h00000000

module CPU (
    input clk, input rst
);

    wire stall;
    reg stall_clk = 0;
    always @(clk) begin
        if (!stall) stall_clk <= clk;
    end

    reg pc_load = 1;
    wire [31:0] pc_out;
    wire [31:0] pc_in;
    ProgramCounter PC(
        .in(pc_in), .clk(stall_clk), .rst(rst), .load(pc_load),
        .out(pc_out)
    );

    wire [31:0] ir_out_f, ir_out_d, ir_out_e, ir_out_m, ir_out_w;
    wire [31:0] ir_in_e = stall ? `NOOP : ir_out_d;
    Register IR_D(.in(ir_out_f), .clk(stall_clk), .rst(rst), .load(1'b1), .out(ir_out_d));    
    Register IR_E(.in(ir_in_e), .clk(clk), .rst(rst), .load(1'b1), .out(ir_out_e));    
    Register IR_M(.in(ir_out_e), .clk(clk), .rst(rst), .load(1'b1), .out(ir_out_m));    
    Register IR_W(.in(ir_out_m), .clk(clk), .rst(rst), .load(1'b1), .out(ir_out_w));  


    InstructionMemory im(
        .addr(pc_out), .clk(clk),
        .out(ir_out_f)
    );


    wire [31:0] dm_addr;
    wire [31:0] dm_in;
    wire dm_write;
    wire [31:0] dm_out;
    DataMemory dm(
        .addr(dm_addr), .in(dm_in), .clk(clk), .rst(rst), .write(dm_write),
        .out(dm_out)
    );

    wire [5:0] opcode_f = ir_out_f[31:26];
    wire [4:0] rs_f = ir_out_f[25:21];
    wire [4:0] rt_f = ir_out_f[20:16];
    wire [4:0] rd_f = ir_out_f[15:11];
    wire [4:0] shamt_f = ir_out_f[10:6];
    wire [5:0] funct_f = ir_out_f[5:0];
    wire [15:0] IMM_f = ir_out_f[15:0];
    wire [31:0] EXT_IMM_f = $signed(IMM_f);
    wire [25:0] ADDR_f = ir_out_f[25:0];
    wire [31:0] EXT_ADDR_f = $unsigned(ADDR_f);

    wire [5:0] opcode_d = ir_out_d[31:26];
    wire [4:0] rs_d = ir_out_d[25:21];
    wire [4:0] rt_d = ir_out_d[20:16];
    wire [4:0] rd_d = ir_out_d[15:11];
    wire [4:0] shamt_d = ir_out_d[10:6];
    wire [5:0] funct_d = ir_out_d[5:0];
    wire [15:0] IMM_d = ir_out_d[15:0];
    wire [31:0] EXT_IMM_d = $signed(IMM_d);
    wire [25:0] ADDR_d = ir_out_d[25:0];
    wire [31:0] EXT_ADDR_d = $unsigned(ADDR_d);

    wire [5:0] opcode_e = ir_out_e[31:26];
    wire [4:0] rs_e = ir_out_e[25:21];
    wire [4:0] rt_e = ir_out_e[20:16];
    wire [4:0] rd_e = ir_out_e[15:11];
    wire [4:0] shamt_e = ir_out_e[10:6];
    wire [5:0] funct_e = ir_out_e[5:0];
    wire [15:0] IMM_e = ir_out_e[15:0];
    wire [31:0] EXT_IMM_e = $signed(IMM_e);
    wire [25:0] ADDR_e = ir_out_e[25:0];
    wire [31:0] EXT_ADDR_e = $unsigned(ADDR_e);

    wire [5:0] opcode_m = ir_out_m[31:26];
    wire [4:0] rs_m = ir_out_m[25:21];
    wire [4:0] rt_m = ir_out_m[20:16];
    wire [4:0] rd_m = ir_out_m[15:11];
    wire [4:0] shamt_m = ir_out_m[10:6];
    wire [5:0] funct_m = ir_out_m[5:0];
    wire [15:0] IMM_m = ir_out_m[15:0];
    wire [31:0] EXT_IMM_m = $signed(IMM_m);
    wire [25:0] ADDR_m = ir_out_m[25:0];
    wire [31:0] EXT_ADDR_m = $unsigned(ADDR_m);

    wire [5:0] opcode_w = ir_out_w[31:26];
    wire [4:0] rs_w = ir_out_w[25:21];
    wire [4:0] rt_w = ir_out_w[20:16];
    wire [4:0] rd_w = ir_out_w[15:11];
    wire [4:0] shamt_w = ir_out_w[10:6];
    wire [5:0] funct_w = ir_out_w[5:0];
    wire [15:0] IMM_w = ir_out_w[15:0];
    wire [31:0] EXT_IMM_w = $signed(IMM_w);
    wire [25:0] ADDR_w = ir_out_w[25:0];
    wire [31:0] EXT_ADDR_w = $unsigned(ADDR_w);


    wire [4:0] wnum;
    wire reg_write;
    wire [31:0] reg_wdata;
    wire [31:0] rdata1;
    wire [31:0] rdata2;
    RegisterSet registers(
        .rnum1(rs_d), .rnum2(rt_d), .wnum(wnum),
        .clk(clk), .rst(rst), .write(reg_write), .wdata(reg_wdata),
        .rdata1(rdata1), .rdata2(rdata2)
    );


    wire alu_zero;
    wire [31:0] alu_in1;
    wire [31:0] alu_in2;
    wire [31:0] alu_out;
    ALU alu(
        .in1(alu_in1), .in2(alu_in2), .opcode(opcode_e), .funct(funct_e),
        .out(alu_out), .zero(alu_zero)
    );


    wire [31:0] pc_out_d;
    Register pc_out_d_delayer(.in(pc_out), .clk(stall_clk), .rst(rst), .load(1'b1), .out(pc_out_d));


    // assign alu_in1:
    Register alu_in1_e_delayer(.in(rdata1), .clk(clk), .rst(rst), .load(1'b1), .out(alu_in1));
    // assign alu_in2:
    wire [31:0] alu_in2_before = (opcode_d == `OPCODE_R) ? rdata2 : EXT_IMM_d;
    Register alu_in2_e_delayer(.in(alu_in2_before), .clk(clk), .rst(rst), .load(1'b1), .out(alu_in2));
    wire [31:0] rdata2_e;
    Register rdata2_e_delayer(.in(rdata2), .clk(clk), .rst(rst), .load(1'b1), .out(rdata2_e));
    wire [31:0] rdata1_e;
    Register rdata1_e_delayer(.in(rdata1), .clk(clk), .rst(rst), .load(1'b1), .out(rdata1_e));
    wire [31:0] pc_out_e;
    Register pc_out_e_delayer(.in(pc_out_d), .clk(clk), .rst(rst), .load(1'b1), .out(pc_out_e));


    // assign dm_addr:
    Register dm_addr_m_delayer(.in(alu_out), .clk(clk), .rst(rst), .load(1'b1), .out(dm_addr));
    // assign dm_in:
    Register rdata2_m_delayer(.in(rdata2_e), .clk(clk), .rst(rst), .load(1'b1), .out(dm_in));
    assign dm_write = (opcode_m == `OPCODE_SW);


    assign wnum = (opcode_w == `OPCODE_R) ? rd_w : rt_w;
    assign reg_write = !(opcode_w == `OPCODE_BEQ || opcode_w == `OPCODE_BNE ||
                        opcode_w == `OPCODE_J || opcode_w == `OPCODE_SW);
    // assign reg_wdata:
    wire [31:0] reg_wdata_before = (opcode_w != `OPCODE_LW) ? dm_addr : dm_out;
    Register dm_addr_w_delayer(.in(reg_wdata_before), .clk(clk), .rst(rst), .load(1'b1), .out(reg_wdata));


    assign pc_in = (opcode_f == `OPCODE_J) ?
                        EXT_ADDR_f : 
                        (opcode_e != `OPCODE_BEQ && opcode_e != `OPCODE_BEQ) ? pc_out + 4 :
                        ((opcode_e == `OPCODE_BEQ && rdata1_e == rdata2_e) ||   // when fetching, need to calculate address - same time as ALU
                         (opcode_e == `OPCODE_BNE && rdata1_e != rdata2_e)) ?   // when fetching, stall
                            $signed(pc_out_e) + $signed(EXT_IMM_e << 2) + 4 :
                            pc_out_e + 4;


    wire read_rs = !(opcode_d == `OPCODE_J) && rs_d != 5'b00000;
    wire read_rt = (opcode_d == `OPCODE_R || opcode_d == `OPCODE_SW ||
                    opcode_d == `OPCODE_BEQ || opcode_d == `OPCODE_BNE) && rt_d != 5'b00000;    // zero register is always zero, no hazards with it
    wire [4:0] write_num_e = (opcode_e == `OPCODE_R) ? rd_e : rt_e;
    wire write_e = !(opcode_e == `OPCODE_BEQ || opcode_e == `OPCODE_BNE ||
                    opcode_e == `OPCODE_J || opcode_e == `OPCODE_SW) && write_num_e != 5'b00000;
    wire [4:0] write_num_m = (opcode_m == `OPCODE_R) ? rd_m : rt_m;
    wire write_m = !(opcode_m == `OPCODE_BEQ || opcode_m == `OPCODE_BNE ||
                    opcode_m == `OPCODE_J || opcode_m == `OPCODE_SW) && write_num_m != 5'b00000;
    wire [4:0] write_num_w = (opcode_w == `OPCODE_R) ? rd_w : rt_w;
    wire write_w = !(opcode_w == `OPCODE_BEQ || opcode_w == `OPCODE_BNE ||
                    opcode_w == `OPCODE_J || opcode_w == `OPCODE_SW) && write_num_w != 5'b00000;


    assign stall = (read_rs && ((write_e && write_num_e == rs_d) || 
                            (write_m && write_num_m == rs_d) ||
                            (write_w && write_num_w == rs_d))) ||
                    (read_rt && ((write_e && write_num_e == rt_d) || 
                            (write_m && write_num_m == rt_d) ||
                            (write_w && write_num_w == rt_d))); // ignoring branching

endmodule