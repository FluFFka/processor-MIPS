`include "include/opcodes.vh"
`include "include/funct.vh"

`define NOOP    32'h00000000

module CPU (
    input clk, input rst
);
    wire stall;
    wire stall_l1_cache_miss = !l1_cache_hit & !l1_cache_stall;

    wire pc_load = !stall;
    wire [31:0] pc_out;
    wire [31:0] pc_in;
    ProgramCounter PC(
        .in(pc_in), .clk(clk), .rst(rst), .load(pc_load & !stall_l1_cache_miss),
        .out(pc_out)
    );

    wire ir_load_d = !stall;
    wire [31:0] ir_out_f, ir_out_d, ir_out_e, ir_out_m, ir_out_w;
    wire [31:0] ir_in_d = (opcode_d == `OPCODE_BEQ && rdata1_d == rdata2_d) ||   // must jump on new address
                            (opcode_d == `OPCODE_BNE && rdata1_d != rdata2_d) ? `NOOP : ir_out_f;
    wire [31:0] ir_in_e = stall ? `NOOP : ir_out_d;
    Register IR_D(.in(ir_in_d), .clk(clk), .rst(rst), .load(ir_load_d & !stall_l1_cache_miss), .out(ir_out_d));
    Register IR_E(.in(ir_in_e), .clk(clk), .rst(rst), .load(!stall_l1_cache_miss), .out(ir_out_e));    
    Register IR_M(.in(ir_out_e), .clk(clk), .rst(rst), .load(!stall_l1_cache_miss), .out(ir_out_m));    
    Register IR_W(.in(ir_out_m), .clk(clk), .rst(rst), .load(!stall_l1_cache_miss), .out(ir_out_w));  

    InstructionMemory #(.MEMORY_SIZE(128)) im(
        .addr(pc_out), .clk(clk),
        .out(ir_out_f)
    );


    wire [31:0] dm_addr;
    wire [31:0] dm_in;
    wire dm_write;
    wire [31:0] dm_out;

    wire [31:0] l1_cache_addr;
    wire [31:0] l1_cache_in;
    wire l1_cache_stall = !(opcode_m == `OPCODE_SW || opcode_m == `OPCODE_LW);
    wire [31:0] l1_cache_out;
    wire l1_cache_hit;

    DataMemory #(.MEMORY_SIZE(512)) dm(
        .addr(dm_addr), .in(dm_in), .clk(clk), .rst(rst), .write(dm_write),
        .out(dm_out)
    );

    Cache l1_cache(
        .addr(l1_cache_addr), .in(l1_cache_in), .clk(clk), .rst(rst), .write(l1_cache_write),
        .stall(l1_cache_stall), .cached_out(dm_out),
        .out(l1_cache_out), .hit(l1_cache_hit),
        .cached_addr(dm_addr), .cached_in(dm_in), .cached_write(dm_write)
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

    wire [5:0] opcode_e = ir_out_e[31:26];
    wire [4:0] rs_e = ir_out_e[25:21];
    wire [4:0] rt_e = ir_out_e[20:16];
    wire [4:0] rd_e = ir_out_e[15:11];
    wire [4:0] shamt_e = ir_out_e[10:6];
    wire [5:0] funct_e = ir_out_e[5:0];

    wire [5:0] opcode_m = ir_out_m[31:26];
    wire [4:0] rs_m = ir_out_m[25:21];
    wire [4:0] rt_m = ir_out_m[20:16];
    wire [4:0] rd_m = ir_out_m[15:11];

    wire [5:0] opcode_w = ir_out_w[31:26];
    wire [4:0] rs_w = ir_out_w[25:21];
    wire [4:0] rt_w = ir_out_w[20:16];
    wire [4:0] rd_w = ir_out_w[15:11];


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


    wire pc_load_d = !stall;
    wire [31:0] pc_out_d;
    Register pc_out_d_delayer(.in(pc_out), .clk(clk), .rst(rst), .load(pc_load_d & !stall_l1_cache_miss), .out(pc_out_d));


    wire [31:0] rdata1_d = (read_rs && (write_e && write_num_e == rs_d)) ? alu_out : // bypass from e stage
                                            (read_rs && (write_m && write_num_m == rs_d)) ? reg_wdata_before :  // bypass from m stage
                                            (read_rs && (write_w && write_num_w == rs_d)) ? reg_wdata : // bypass from w stage
                                            rdata1;
    wire [31:0] alu_in1_before = rdata1_d;
    Register alu_in1_e_delayer(.in(alu_in1_before), .clk(clk), .rst(rst), .load(!stall_l1_cache_miss), .out(alu_in1));
    wire [31:0] rdata2_d = (read_rt && (write_e && write_num_e == rt_d)) ? alu_out :   // bypass from e stage
                                            (read_rt && (write_m && write_num_m == rt_d)) ? reg_wdata_before :  // bypass from m stage
                                            (read_rt && (write_w && write_num_w == rt_d)) ? reg_wdata : // bypass from w stage
                                            rdata2;
    wire [31:0] alu_in2_before = (opcode_d != `OPCODE_R) ? EXT_IMM_d : rdata2_d;
    Register alu_in2_e_delayer(.in(alu_in2_before), .clk(clk), .rst(rst), .load(!stall_l1_cache_miss), .out(alu_in2));
    wire [31:0] rdata2_e;
    Register rdata2_e_delayer(.in(rdata2_d), .clk(clk), .rst(rst), .load(!stall_l1_cache_miss), .out(rdata2_e));
    wire [31:0] rdata1_e;
    Register rdata1_e_delayer(.in(rdata1_d), .clk(clk), .rst(rst), .load(!stall_l1_cache_miss), .out(rdata1_e));
    wire [31:0] pc_out_e;
    Register pc_out_e_delayer(.in(pc_out_d), .clk(clk), .rst(rst), .load(!stall_l1_cache_miss), .out(pc_out_e));


    wire [31:0] alu_out_m;
    Register alu_out_m_delayer(.in(alu_out), .clk(clk), .rst(rst), .load(!stall_l1_cache_miss), .out(alu_out_m));
    assign l1_cache_addr = alu_out_m;
    wire [31:0] rdata2_m;
    Register rdata2_m_delayer(.in(rdata2_e), .clk(clk), .rst(rst), .load(!stall_l1_cache_miss), .out(rdata2_m));
    wire [31:0] rdata1_m;
    Register rdata1_m_delayer(.in(rdata1_e), .clk(clk), .rst(rst), .load(!stall_l1_cache_miss), .out(rdata1_m));
    assign l1_cache_in = rdata2_m;
    assign l1_cache_write = (opcode_m == `OPCODE_SW);


    assign wnum = (opcode_w == `OPCODE_R) ? rd_w : rt_w;
    assign reg_write = !(opcode_w == `OPCODE_BEQ || opcode_w == `OPCODE_BNE ||
                        opcode_w == `OPCODE_J || opcode_w == `OPCODE_SW);
    wire [31:0] reg_wdata_before = (opcode_m != `OPCODE_LW) ? alu_out_m : l1_cache_out;
    Register alu_out_w_delayer(.in(reg_wdata_before), .clk(clk), .rst(rst), .load(!stall_l1_cache_miss), .out(reg_wdata));


    assign pc_in = (opcode_f == `OPCODE_J) ?
                        EXT_ADDR_f : 
                        (opcode_d != `OPCODE_BEQ && opcode_d != `OPCODE_BNE) ? pc_out + 4 :
                        ((opcode_d == `OPCODE_BEQ && rdata1_d == rdata2_d) ||
                         (opcode_d == `OPCODE_BNE && rdata1_d != rdata2_d)) ?   // if jump: change path, put noop in previous stage
                            $signed(pc_out_d) + $signed(EXT_IMM_d << 2) + 4 :
                            pc_out + 4; // if not jump: continue as usual


    wire read_rs = !(opcode_d == `OPCODE_J) && rs_d != 5'b00000;    // zero register is always zero, no hazards with it
    wire read_rt = (opcode_d == `OPCODE_R || opcode_d == `OPCODE_SW ||
                    opcode_d == `OPCODE_BEQ || opcode_d == `OPCODE_BNE) && rt_d != 5'b00000;
    wire [4:0] write_num_e = (opcode_e == `OPCODE_R) ? rd_e : rt_e;
    wire write_e = !(opcode_e == `OPCODE_BEQ || opcode_e == `OPCODE_BNE ||
                    opcode_e == `OPCODE_J || opcode_e == `OPCODE_SW) && write_num_e != 5'b00000;
    wire [4:0] write_num_m = (opcode_m == `OPCODE_R) ? rd_m : rt_m;
    wire write_m = !(opcode_m == `OPCODE_BEQ || opcode_m == `OPCODE_BNE ||
                    opcode_m == `OPCODE_J || opcode_m == `OPCODE_SW) && write_num_m != 5'b00000;
    wire [4:0] write_num_w = (opcode_w == `OPCODE_R) ? rd_w : rt_w;
    wire write_w = !(opcode_w == `OPCODE_BEQ || opcode_w == `OPCODE_BNE ||
                    opcode_w == `OPCODE_J || opcode_w == `OPCODE_SW) && write_num_w != 5'b00000;


    assign stall = (opcode_e == `OPCODE_LW && read_rs && (write_e && write_num_e == rs_d));

endmodule