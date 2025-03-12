// Modelling Memory

// Single Port Syncronous read write RAM
module synRAM(data,addr,r,w,cs,clk);
    parameter ADDR_SIZE = 10;
    parameter WORD_SIZE = 8;

    inout [WORD_SIZE-1:0] data;
    input [ADDR_SIZE-1:0] addr;
    input r,w,cs,clk;
    reg [WORD_SIZE-1:0]d_out;

    reg [WORD_SIZE-1:0] mem [(2**ADDR_SIZE)-1:0];

    assign data = (cs && r)? d_out:8'bz;
    always @(posedge clk) begin
        if(cs && r && !w) d_out <= mem[addr];
    end
    always @(posedge clk) begin
        if(cs && w && !r) mem[addr] <= data;
    end   
endmodule