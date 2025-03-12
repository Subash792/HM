module bit_reversal_generate #(
    parameter N = 32  // Number of bits
)(
    input  wire [N-1:0] in_data,
    output wire [N-1:0] out_data
);
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : bit_reversal
            assign out_data[i] = in_data[N-1-i];
        end
    endgenerate
endmodule


module barrel_shifter_32b(
    input [31:0] in,
    input [4:0] shift_amt,
    input lr,
    output [31:0] out
);

wire [31:0] in_rev, s1, s2, s3, s4, s5, s6, s6_inv;

bit_reversal_generate g0(in,in_rev);
assign s1 = (lr)?(in_rev):(in);   // if lr = 1 -> right shift else left shift.
assign s2 = (shift_amt[0])?({s1[30:0],1'b0}):s1;
assign s3 = (shift_amt[1])?({s2[29:0],2'b00}):s2;
assign s4 = (shift_amt[2])?({s3[27:0],{4{1'b0}}}):s3;
assign s5 = (shift_amt[3])?({s4[23:0],{8{1'b0}}}):s4;
assign s6 = (shift_amt[4])?({s5[15:0],{16{1'b0}}}):s5;
bit_reversal_generate g1(s6,s6_inv);
assign out = (lr)?s6_inv:s6;

endmodule