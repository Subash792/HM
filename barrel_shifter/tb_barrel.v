`timescale 1ps/1ps
module tb;
reg [31:0] in;
reg [4:0] shft_amt;
reg lr;
wire [31:0] out;

reg [31:0] a,b;
barrel_shifter_32b dut(in,shft_amt,lr,out);

initial begin
    in <= 31'h1234_5678;
    shft_amt <= 5'd5;
    lr <= 1'b0;
    #5 lr<= 1'b1;
end

initial begin
    $monitor("in: %h, shft_amt = %b, out = %h",in,shft_amt,out);
    $dumpfile("waveform.vcd");
    $dumpvars(0,tb);
end

initial
    begin
    #8
    a = in<<shft_amt;
    b = in>>shft_amt; 
    $display("in<<shft_amt = %h, in>>shft_amt = %h",a,b);
    end
    

initial
    #10 $finish;
    
endmodule