module PIPO #(
    parameter size = 8)
 (
    output reg [size-1:0] data_out,
    input [size-1:0] data_in,
    input ld,
    input clk
);
always@(posedge clk)
    begin
        if(ld) data_out<=data_in;
    end
endmodule

module mux #(
    parameter size = 8
) ( output [size-1:0] out,
    input [size-1:0] A,
    input [size-1:0] B,
    input sel    
);
assign out = (sel)?B:A;    
endmodule

module comp(a,b,lt,gt,eq);
    parameter size =8;
  
    input [size-1:0] a;
    input [size-1:0] b;
    output lt;
    output gt;
    output eq;

    assign lt = a<b;
    assign gt = a>b;
    assign eq = a == b;

endmodule

module sub (x,y,out);
    parameter size = 8;
    input [size-1:0] x;
    input [size-1:0] y;
    output [size-1:0] out;

    assign out = x - y;
endmodule

module datapath(data_in, clk, lda, ldb, sel1, sel2, sel_in, lt, gt, eq, data_out);
    parameter size = 8;

    input [size-1:0] data_in;
    input lda,ldb,clk,sel1,sel2,sel_in;
    output lt, gt, eq;
    output [size-1:0] data_out;
    wire [size-1:0] bus,A,B,sub_out,X,Y;
    
    PIPO A_reg(A,bus,lda,clk);
    PIPO B_reg(B,bus,ldb,clk);
    mux  m1(X,A,B,sel1);
    mux m2(Y,A,B,sel2);
    sub s0(X,Y,sub_out);
    mux m3(bus, sub_out, data_in, sel_in);
    comp c0(A,B,lt,gt,eq);
    assign data_out = A;

endmodule

module controller(start,reset,clk,lt,eq,gt,lda,ldb,sel1,sel2,sel_in,done);

    input start,reset,clk,lt,gt,eq;
    output reg lda,ldb,sel1,sel2,sel_in,done;
    reg [3:0] state,next_state;

    parameter s0 = 3'b000, s1 = 3'b001, s2 = 3'b010, s3 = 3'b011, s4 = 3'b100;

    always@(posedge clk)
        begin
            state<=next_state;
        end

    // next state logic
    always@(state,eq,reset)
        begin
            case (state)
                s0: if(start) next_state = s1; else next_state = s0;
                s1: if(reset) next_state = s0; else next_state = s2;
                s2: if(reset) next_state = s0; else next_state = s3;
                s3: if(reset) next_state = s0; else begin if(eq) next_state = s4; else next_state = s3; end
                s4: if(reset) next_state = s0; else next_state = s4;
                default: next_state = s0;
            endcase
        end
    
    // output logic
    always@(state,lt,gt,eq)
        begin
            case (state)
                s0:  begin  lda = 0; ldb = 0; sel1=0; sel2=0; sel_in=0; done = 0;end
                s1:  begin  lda = 1; ldb = 0; sel_in = 1;end
                s2:  begin  lda = 0; ldb = 1; sel_in = 1;end
                s3:
                begin
                    if(lt) begin sel1 = 1; sel2 = 0; sel_in = 0; lda = 0; ldb = 1; end
                    else if(gt) begin sel1 = 0; sel2 = 1; sel_in = 0; lda = 1; ldb = 0; end
                    else begin lda = 0; ldb = 0; end    
                end
                s4: begin done = 1; lda = 0; ldb = 0; end
            endcase
        end
endmodule

module gcd(start, reset, clk, data_in, data_out, done);
    
    parameter size = 8;
    input start, reset, clk;
    input [size-1:0] data_in;
    output [size-1:0] data_out;
    output done;
    
    wire lda, ldb, sel1,sel2,sel_in,lt,gt,eq;

    datapath #(.size(size)) d0 (data_in, clk, lda, ldb, sel1, sel2, sel_in, lt, gt, eq, data_out); 
    controller c0 (start, reset, clk, lt, eq, gt, lda, ldb, sel1,sel2, sel_in, done);

endmodule


