// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module core (clk, inst,inst_w, ofifo_valid, D_xmem, sfp_out, reset);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;
  parameter nij_len = 3;
  parameter kij_len = 9;

  input clk, reset;
  input [33:0] inst;
  input [1:0] inst_w;
  input [row-1:0][bw-1:0] D_xmem; 
  output ofifo_valid;
  output [col-1:0][psum_bw-1:0] sfp_out;

  wire [row-1:0][bw-1:0] in_w;
  reg [1:0] inst_w_q;
  wire [col-1:0][psum_bw-1:0] ofifo_out;
  wire [col-1:0][psum_bw-1:0] p_mem_out;
  reg [10:0] A_psum;
  wire [10:0] A_sfp ;
  wire done;


  corelet #(.bw(bw), .psum_bw(psum_bw), .col(col), .row(row), .nij_len(nij_len), .kij_len(kij_len)) corelet_inst (
  .clk(clk), 
  .reset(reset), 
  .in_w(in_w), 
  .in_n({psum_bw*col{1'b0}}), 
  .p_mem_out(p_mem_out),
  .inst_w(inst_w_q),
  .acc(inst[33]),
  .ofifo_out(ofifo_out),
  .sfp_out(sfp_out),
  .A_sfp(A_sfp),
  .valid(ofifo_valid),
  .load(inst[0]));


  sram_128b_w2048 x_mem_inst (
    .CLK(clk), 
    .D({{(128-(bw*row)){1'b0}},D_xmem}), 
    .Q(in_w), 
    .CEN(inst[19]), 
    .WEN(inst[18]), 
    .A(inst[17:7]));
  
  sram_128b_w2048 p_mem_inst (
    .CLK(clk), 
    .D(ofifo_out), 
    .Q(p_mem_out), 
    .CEN(~(inst[33] | ofifo_valid)), 
    .WEN(inst[33]), 
    .A(A_psum));


always@(posedge clk)begin
  if(reset)begin
    inst_w_q <= 'b0;
    A_psum <= 'b0;
  end
  else begin
    inst_w_q <=inst_w;
    if(inst[33])begin
      A_psum <= A_sfp;
    end
    else begin
      A_psum <= (ofifo_valid) ? A_psum + 1 : A_psum;
    end
  end
end
  
endmodule
