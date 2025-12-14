// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_Part4 (out, a, b, c, mode_2bit);

parameter bw = 4;
parameter psum_bw = 16;

output signed [psum_bw-1:0] out;
input  signed [bw-1:0] a;
input  signed [bw-1:0] b;
input  signed [psum_bw-1:0] c;
input  mode_2bit;
wire signed [bw:0] a_pad;
wire signed [1:0] a_lo = a[1:0];
wire signed [1:0] a_hi = a[3:2];
wire signed [1:0] b_lo = b[1:0];
wire signed [1:0] b_hi = b[3:2];

wire signed [psum_bw-1:0] mac4_out;

wire signed [psum_bw-1:0] mac2_out =
      (a_lo * b_lo) +
      (a_hi * b_hi);
assign a_pad={1'b0,a};
assign mac4_out=a_pad*b;
assign out = mode_2bit ? (mac2_out + c) : (mac4_out + c);

endmodule
