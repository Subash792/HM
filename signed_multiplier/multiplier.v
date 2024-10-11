/*
Signed Multiplier using Booth's Algorithm.
Author: Subash Ganti
*/

module PIPO #(
    parameter SIZE = 8)
 (
    output reg [SIZE-1:0] data_out,
    input [SIZE-1:0] data_in,
    input ld,
    input clr,
    input clk
);
always@(posedge clk)
    begin
        if(clr) data_out<=0;
        else if (ld) data_out<=data_in;
    end
endmodule

module shiftreg(data_out, data_in, d_in, ld, sft, clr, clk);
    parameter SIZE = 8;
    output reg[SIZE-1:0] data_out;
    input [SIZE-1:0] data_in;
    input d_in, ld, sft, clr, clk;

    always@(posedge clk)
    begin
        if(clr) data_out<=0;
        else if(sft) data_out<={d_in,data_out[SIZE-1:1]};
        else if(ld) data_out<=data_in;
    end
endmodule

module counter(count, reset, down_count, clk);
    parameter SIZE = 8;
    output reg[SIZE-1:0] count;
    input reset,clk,down_count;
    
    always@(posedge clk)
    begin
        if(reset) count<=SIZE;
        else if(down_count)count <= count -1;
    end
endmodule

module addsub(S,A,B,ctrl);
    parameter SIZE = 8;
    output reg[SIZE-1:0] S;
    input [SIZE-1:0] A;
    input [SIZE-1:0] B;
    input [1:0] ctrl;

    always@(A,B,ctrl)
    begin
        case (ctrl)
            2'b00 : S = B;
            2'b01 : S = A + B;
            2'b10 : S = (~A) + B + 1;
            default: S = B;
        endcase
    end   
endmodule

module datapath(data_out, count, op_con, data_in, lda, ldb, lds, ldq, sftb, clr, addctrl,down_count, clk);
    parameter SIZE = 8;
    output [(2*SIZE)-1:0] data_out;
    output [SIZE-1:0] count;
    output [1:0] op_con; // operation codition
    input [SIZE-1:0] data_in;
    input lda,ldb,lds,ldq,sftb,clr,clk,down_count;
    input [1:0] addctrl;

    wire [SIZE-1:0] A,B,S,P;
    wire Q;
    wire clrA;

    PIPO #(.SIZE(SIZE)) A_reg(A,data_in,lda,clrA,clk);
    PIPO #(.SIZE(SIZE)) S_reg(S,{P[SIZE-1], P[SIZE-1:1]}, lds, clr, clk);
    PIPO #(.SIZE(1))    Q_reg(Q,B[0],ldq,clr,clk);
    shiftreg #(.SIZE(SIZE)) B_reg(B,data_in,P[0],ldb,sftb,clr,clk);
    counter #(.SIZE(SIZE)) C0(count, clr,down_count, clk);
    addsub #(.SIZE(SIZE))  A0(P, A, S, addctrl);
    
    assign clrA = 1'b0;
    assign op_con = {B[0], Q};
    assign data_out = {S,B};

endmodule

module controller(start, reset, clk, op_con, count, lda, ldb, lds, ldq, sftb, addctrl, clr, down_count, done);
    
    parameter SIZE = 8;

    input start,reset,clk;
    input [1:0] op_con;
    input [SIZE-1:0] count;
    output reg lda, ldb, lds, ldq, sftb, clr, done, down_count;
    output reg [1:0] addctrl;

    reg [2:0] state, next_state;
    parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100;

    always@(posedge clk)
        state <= next_state;

    // Determinig next state.
    always@(state, start, reset, count)
        begin
            case (state)
                S0: begin if(reset) next_state = S0; else begin if(start) next_state = S1; else next_state = S0;end end
                S1: begin if(reset) next_state = S0; else next_state = S2; end
                S2: begin if(reset) next_state = S0; else next_state = S3; end
                S3: begin if(reset) next_state = S0; else begin if(count==0) next_state = S4; else next_state = S3; end end
                S4: begin if(reset) next_state = S0; else next_state = S4;end
                default: next_state = S0;
            endcase
        end

    // Determining outputs
   always@(state, start, count, op_con)
   begin
        case (state)
            S0: begin clr = 1; lda = 0; ldb = 0; lds = 0; ldq = 0; sftb = 0; addctrl = 0; down_count = 0; done = 0;end 
            S1: begin clr = 0; lda = 1; ldb = 0;end
            S2: begin lda = 0; ldb = 1;end
            S3: begin 
                if(count == 0) begin lda = 0; ldb = 0; sftb = 0; lds = 0; ldq = 0; clr = 0; down_count = 0; end
                else begin 
                    lda = 0; ldb = 0; lds = 1; ldq = 1; sftb = 1; clr = 0; down_count = 1;
                    case (op_con)
                        2'b00: addctrl = 2'b00;
                        2'b01: addctrl = 2'b01;
                        2'b10: addctrl = 2'b10;
                        2'b11: addctrl = 2'b00;
                        default: addctrl = 2'b00;
                    endcase 
                end
            end
            S4: begin lda = 0; ldb = 0; sftb = 0; lds =0; ldq = 0; clr = 0; done = 1; down_count = 0; end
            default: begin clr = 1; lda = 0; ldb = 0; lds = 0; ldq = 0; sftb = 0; addctrl = 0; done = 0; down_count = 0; end
        endcase
   end 
endmodule

module Multiplier(start, reset, clk, data_in, data_out, done);
    parameter SIZE = 8;
    input start, reset, clk;
    input [SIZE-1:0] data_in;
    output [(2*SIZE)-1:0] data_out; output done;

    wire lda, ldb, lds, ldq, sftb, clr, down_count;
    wire [1:0] addctrl, op_con;
    wire [SIZE-1:0] count;

    datapath #(.SIZE(SIZE)) d0(data_out, count, op_con, data_in, lda, ldb, lds, ldq, sftb, clr, addctrl,down_count, clk);
    controller #(.SIZE(SIZE)) c0(start, reset, clk, op_con, count, lda, ldb, lds, ldq, sftb, addctrl, clr,down_count, done);
endmodule

