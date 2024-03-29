module Cache #(
    parameter INDEX_SIZE = 2,               // k; 2^k - number of strings in cache
    parameter BLOCK_OFFSET_SIZE = 4,        // b; 2^b - size of cache string in bytes; b must be at least 2 (2^2=4 - word size)
    parameter ASSOCIATIVE_BLOCKS_NUM = 2    // number of associative blocks
) (
    input [31:0] addr, input [31:0] in, input clk, input rst, input write,
    input stall, input [31:0] cached_out,  // output of cached memory to get information from it
    output [31:0] out, output hit,
    output [31:0] cached_addr, output [31:0] cached_in, output cached_write // inputs for cached memory
);
    localparam TAG_SIZE = 32 - INDEX_SIZE - BLOCK_OFFSET_SIZE;
    wire [TAG_SIZE-1:0] tag = addr[31:32-TAG_SIZE];
    wire [INDEX_SIZE-1:0] index = addr[32-TAG_SIZE-1:BLOCK_OFFSET_SIZE];

    localparam STRINGS_NUM = 1 << INDEX_SIZE;
    localparam DATA_BLOCK_SIZE = 1 << BLOCK_OFFSET_SIZE;

    reg valids[0:ASSOCIATIVE_BLOCKS_NUM-1][0:STRINGS_NUM-1];
    genvar valids_init_i;
    for (valids_init_i = 0; valids_init_i < ASSOCIATIVE_BLOCKS_NUM; valids_init_i = valids_init_i + 1) begin
        genvar valids_init_j;
        for (valids_init_j = 0; valids_init_j < STRINGS_NUM; valids_init_j = valids_init_j + 1) begin
            always @(posedge clk, posedge rst)
                if (rst) valids[valids_init_i][valids_init_j] <= 0;
        end
    end
    reg [TAG_SIZE-1:0] tags[0:ASSOCIATIVE_BLOCKS_NUM-1][0:STRINGS_NUM-1];
    genvar tags_init_i;
    for (tags_init_i = 0; tags_init_i < ASSOCIATIVE_BLOCKS_NUM; tags_init_i = tags_init_i + 1) begin
        genvar tags_init_j;
        for (tags_init_j = 0; tags_init_j < STRINGS_NUM; tags_init_j = tags_init_j + 1) begin
            always @(posedge clk, posedge rst)
                if (rst) tags[tags_init_i][tags_init_j] <= 0;
        end
    end
    reg [7:0] data_blocks[0:ASSOCIATIVE_BLOCKS_NUM-1][0:STRINGS_NUM-1][0:DATA_BLOCK_SIZE-1];
    genvar data_blocks_init_i;
    for (data_blocks_init_i = 0; data_blocks_init_i < ASSOCIATIVE_BLOCKS_NUM; data_blocks_init_i = data_blocks_init_i + 1) begin
        genvar data_blocks_init_j;
        for (data_blocks_init_j = 0; data_blocks_init_j < STRINGS_NUM; data_blocks_init_j = data_blocks_init_j + 1) begin
            genvar data_blocks_init_k;
            for (data_blocks_init_k = 0; data_blocks_init_k < DATA_BLOCK_SIZE; data_blocks_init_k = data_blocks_init_k + 1) begin
                always @(posedge clk, posedge rst)
                    if (rst) data_blocks[data_blocks_init_i][data_blocks_init_j][data_blocks_init_k] <= 0;
            end
        end
    end

    wire [0:ASSOCIATIVE_BLOCKS_NUM-1] hits; // supposed to be array

    wire [BLOCK_OFFSET_SIZE-1:0] in_bo0 = addr[BLOCK_OFFSET_SIZE-1:0];
    wire [BLOCK_OFFSET_SIZE-1:0] in_bo1 = addr[BLOCK_OFFSET_SIZE-1:0]+1;
    wire [BLOCK_OFFSET_SIZE-1:0] in_bo2 = addr[BLOCK_OFFSET_SIZE-1:0]+2;
    wire [BLOCK_OFFSET_SIZE-1:0] in_bo3 = addr[BLOCK_OFFSET_SIZE-1:0]+3;
    genvar i;
    for (i = 0; i < ASSOCIATIVE_BLOCKS_NUM; i = i + 1) begin
        assign hits[i] = (valids[i][index] && (tags[i][index] == tag));
        integer ii = i; // indexing for data, hack for iverilog
        assign out = hits[ii] ? {data_blocks[ii][index][in_bo0],
                                 data_blocks[ii][index][in_bo1],
                                 data_blocks[ii][index][in_bo2],
                                 data_blocks[ii][index][in_bo3]} : 32'bz;
    end
    assign hit = |hits;
    

    integer curr_pop[0:STRINGS_NUM-1];  // for every string current associative block to update (should be writing policy)
    genvar j;
    generate
        for (j = 0; j < STRINGS_NUM; j = j + 1) begin
            always @(posedge clk, posedge rst)
                if (rst) curr_pop[j] <= 0;
        end
    endgenerate
    
    integer word_addr_to_load = 0;  // adress in block

    wire [BLOCK_OFFSET_SIZE-1:0] write_bo0 = word_addr_to_load;
    wire [BLOCK_OFFSET_SIZE-1:0] write_bo1 = word_addr_to_load+1;
    wire [BLOCK_OFFSET_SIZE-1:0] write_bo2 = word_addr_to_load+2;
    wire [BLOCK_OFFSET_SIZE-1:0] write_bo3 = word_addr_to_load+3;
    assign cached_in = {data_blocks[curr_associative_block][index][write_bo0],
                        data_blocks[curr_associative_block][index][write_bo1],
                        data_blocks[curr_associative_block][index][write_bo2],
                        data_blocks[curr_associative_block][index][write_bo3]};
    assign cached_write = !stall & !hit & valids[curr_associative_block][index];
    assign cached_addr = cached_write ? {tags[curr_associative_block][index], index, write_bo0} :       // write_bo0 because it is equals to word_addr_to_load but with BLOCK_OFFSET_SIZE width
                                        {tag, index, write_bo0};


    wire [31:0] curr_associative_block = curr_pop[index];   // associative block to push; actually size of wire should be floor(log2(STRINGS_NUM))+1
    wire [BLOCK_OFFSET_SIZE-1:0] load_bo0 = word_addr_to_load;
    wire [BLOCK_OFFSET_SIZE-1:0] load_bo1 = word_addr_to_load+1;
    wire [BLOCK_OFFSET_SIZE-1:0] load_bo2 = word_addr_to_load+2;
    wire [BLOCK_OFFSET_SIZE-1:0] load_bo3 = word_addr_to_load+3;

    always @(posedge clk) begin
        if (!stall && !hit) begin
            if (valids[curr_associative_block][index]) begin
                if ((word_addr_to_load + 4) % DATA_BLOCK_SIZE == 0) begin
                    valids[curr_associative_block][index] <= 1'b0;
                    word_addr_to_load <= 0;
                end else begin
                    word_addr_to_load <= word_addr_to_load + 4;                
                end
            end else begin
                {data_blocks[curr_associative_block][index][load_bo0],
                 data_blocks[curr_associative_block][index][load_bo1],
                 data_blocks[curr_associative_block][index][load_bo2],
                 data_blocks[curr_associative_block][index][load_bo3]} <= cached_out;            
                if ((word_addr_to_load + 4) % DATA_BLOCK_SIZE == 0) begin
                    valids[curr_associative_block][index] <= 1'b1;
                    tags[curr_associative_block][index] <= tag;
                    word_addr_to_load <= 0;
                    curr_pop[index] <= (curr_pop[index] + 1) % ASSOCIATIVE_BLOCKS_NUM;
                end else begin
                    word_addr_to_load <= word_addr_to_load + 4;                
                end
            end

        end
    end

    genvar k;
    for (k = 0; k < ASSOCIATIVE_BLOCKS_NUM; k = k + 1) begin
        always @(posedge clk) begin
            if (hits[k]) begin
                if (!stall && write) begin
                    {data_blocks[k][index][in_bo0],
                     data_blocks[k][index][in_bo1],
                     data_blocks[k][index][in_bo2],
                     data_blocks[k][index][in_bo3]} <= in;
                end
            end
        end
    end
    assign hit = |hits;

endmodule