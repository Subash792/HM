`include "gcd.v"
`timescale 1ns/1ps

module tb_gcd;
parameter SIZE = 8;
parameter tclk = 10;
reg start, reset, clk;
reg [SIZE-1:0] data_in;
wire [SIZE-1:0] data_out;
wire done;

integer n = 5;

gcd g0(start,reset,clk,data_in,data_out,done);

task generate_stimulus();
begin
    start <= 1'b0; reset <=1'b1; clk <= 1'b0;
    #(tclk) reset<=1'b0; start<=1'b1;
    #(tclk) start<=1'b0; data_in<=$random;
    #(tclk) data_in<=$random;
end
endtask

initial
begin
    $dumpfile("tb_gcd.vcd");
    $dumpvars(0,tb_gcd);
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
    $monitor("time = %t, A = %d, B = %d, done=%b",$time, g0.d0.A, g0.d0.B,done);
end
endmodule