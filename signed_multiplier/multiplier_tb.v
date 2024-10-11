`include "multiplier.v"
`timescale 1ns/1ns

module multiplier_tb;

parameter SIZE = 8, tclk = 10;
reg start, reset, clk;
reg [SIZE-1:0] data_in;
wire [(2*SIZE)-1:0] data_out;
wire done;

integer n = 5;

byte arr1[4:0];
byte arr2[4:0];


initial
begin
arr1[0]= 14;
arr1[1]= 51;
arr1[2]=4;
arr1[3]= 11;
arr1[4]= 7;
arr2[0] = 8'b0000_0101;
arr2[1] = 8'b1111_1101;
arr2[2] = 8'b0000_1010;
arr2[3] = 8'b1111_1010;
arr2[4] = 8'b1110_1101;
end

Multiplier #(.SIZE(SIZE)) m0(start,reset,clk,data_in,data_out,done);

task generate_stimulus();
begin
    start <= 1'b0; reset <=1'b1; clk <= 1'b0;
    #(tclk) reset<=1'b0; start<=1'b1;
    #(tclk) start<=1'b0; data_in<=arr1[n];
    #(tclk) data_in<=arr2[n];
end
endtask

initial
begin
    $dumpfile("multiplier_tb.vcd");
    $dumpvars(0,multiplier_tb);
end

// generating the clock.
always #(tclk/2) clk = ~clk;

// Generating input stimulus
initial
begin
    n = n-1;
    generate_stimulus();
end

always@(posedge done)
begin
    if(n == 0) $finish;
    n = n-1;
    generate_stimulus();
end

initial
# 1000 $finish;

// Monitoring signals
initial
begin
    $monitor("time = %t, n=%d, A = %d, B =%b , S =%b, data_out=%b, count = %d, done=%b",$time,n, m0.d0.A, m0.d0.B, m0.d0.S,data_out,m0.count,done);
end
endmodule