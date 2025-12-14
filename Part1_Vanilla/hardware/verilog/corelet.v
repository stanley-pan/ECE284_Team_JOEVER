// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module corelet (clk, reset, in_w, in_n,p_mem_out,acc, inst_w,ofifo_out,sfp_out,A_sfp,valid,load);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;
  parameter nij_len = 3;
  parameter kij_len = 9;

  input  clk, reset;
  
  input  [row-1:0][bw-1:0] in_w; 
  input  [col-1:0][psum_bw-1:0] in_n;
  input  [127:0] p_mem_out;
  // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input acc;
  input load;

  output valid;
  output [10:0] A_sfp;
  output [col-1:0][psum_bw-1:0] ofifo_out,sfp_out;

  wire [col-1:0] mac_array_valid;
  reg [col-1:0] last_mac_array_valid;
  wire [col-1:0][psum_bw-1:0] mac_array_out;
  wire ofifo_full;
  wire ofifo_ready;
  wire [row-1:0][bw-1:0] mac_in_w;
  wire [col-1:0][psum_bw-1:0] in_n_l;
  wire sfu_valid,ofifo_valid;

  assign valid = ofifo_valid;

  mac_array #(.bw(bw), .psum_bw(psum_bw), .col(col), .row(row)) mac_array_instance (
    .clk(clk),
    .reset(reset|load),
    .out_s(mac_array_out),
    .in_w(mac_in_w),
    .inst_w(inst_w), 
    .in_n(in_n),
    .valid(mac_array_valid));

 l0 #(.bw(bw), .row(row)) l0_inst (
  .clk(clk), 
  .in(in_w), 
  .out(mac_in_w), 
  .rd(inst_w[0|inst_w[1]]), 
  .wr(inst_w[0|inst_w[1]]), 
  .o_full(), 
  .reset(reset), 
  .o_ready());

  ofifo #(.col(col), .bw(psum_bw))ofifo_inst(
    .clk(clk),
    .reset(reset),
    .in(mac_array_out),
    .out(ofifo_out), 
    .rd(ofifo_valid), 
    .wr(mac_array_valid), 
    .o_full(ofifo_full),  
    .o_ready(ofifo_ready), 
    .o_valid(ofifo_valid));

  sfp #(.col(col), .bw(psum_bw), .nij_len(nij_len), .kij_len(kij_len)) sfp_inst (
  .clk(clk), 
  .in(p_mem_out), 
  .out(sfp_out), 
  .A(A_sfp), 
  .i_valid(acc),
  .o_valid(sfu_valid), 
  .reset(reset));
endmodule
