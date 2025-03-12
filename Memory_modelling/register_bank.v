module register_bank(rdat1,rdat2,wdat,rad1,rad2,wad,w,reset,clk);

parameter ADDR_SIZE = 5;
parameter WORD_SIZE = 32;

input w,reset,clk;
input [ADDR_SIZE-1:0] rad1, rad2, wad;
input [WORD_SIZE-1:0] wdat;
output [WORD_SIZE-1:0] rdat1,rdat2;

reg [WORD_SIZE-1:0] bank [((2**ADDR_SIZE)-1):0];

// read
assign rdat1 = bank[rad1];
assign rdat2 = bank[rad2];

// reset and write
always @(posedge clk) begin
    if(reset)begin
        for (k = 0; k<(2**ADDR_SIZE)-1 ;k = k+1 ) begin
            bank[k] <= 0; 
        end
    end
    else begin
        if(write)
            bank[wad] <= wdat;
        else
            bank[wad] <= bank[wad];
    end
end

endmodule