// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module corelet (clk, reset, in_w, in_n, A_x_in, p_mem_out,acc, inst_w,ofifo_out,sfp_out,A_sfp,A_x,valid,load);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;
  parameter nij_len = 3;
  parameter kij_len = 9;

  input  clk, reset;
  
  input  [row-1:0][bw-1:0] in_w; 
  input  [col-1:0][psum_bw-1:0] in_n;
  input [10:0] A_x_in;
  input  [127:0] p_mem_out;
  // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input acc;
  input load;

  output valid;
  output [10:0] A_sfp,A_x;
  output [col-1:0][psum_bw-1:0] ofifo_out,sfp_out;

  wire [col-1:0] mac_array_valid;
  wire [col-1:0][psum_bw-1:0] mac_array_out;
  wire ofifo_full;
  wire ofifo_ready;
  wire [row-1:0][bw-1:0] mac_in_w;
  wire [col-1:0][psum_bw-1:0] in_n_l;
  wire sfu_valid,ofifo_valid,ififo_valid;
  reg [$clog2(kij_len):0] kij_count;

  assign valid = ofifo_valid;
  assign A_x = nij_lut(A_x_in+(kij_count-1),kij_count-1,A_x_in);
  assign in_n_l = ((kij_count-1)==0) ? 'b0:ofifo_out;

  genvar j;
  for(j=0;j<col;j=j+1)begin
    assign sfp_out[j] = (ofifo_out[row-1-j][psum_bw-1]) ? 'b0 : ofifo_out[row-1-j];
  end

  function [$clog2(nij_len)+1:0] kij_lut([$clog2(kij_len)+1:0] kij);
  if(kij < 3) begin
    kij_lut = 'd0;
  end 
  else if(kij < 6) begin
    kij_lut = 'd3;
  end 
  else begin
    kij_lut = 'd6;
  end
  endfunction 

  function [$clog2(nij_len)+1:0] nij_lut([$clog2(nij_len)+1:0] nij, [$clog2(kij_len)+1:0] kij, [5:0] fm);
    if(fm < 4)begin
      nij_lut = nij + kij_lut(kij) + 'd0;
    end 
    else if(fm < 8) begin
      nij_lut = nij + kij_lut(kij) + 'd2;
    end 
    else if(fm < 12) begin
      nij_lut = nij + kij_lut(kij) + 'd4;
    end
    else begin
      nij_lut = nij + kij_lut(kij) + 'd6;
    end
  endfunction

  mac_array #(.bw(bw), .psum_bw(psum_bw), .col(col), .row(row)) mac_array_instance (
    .clk(clk),
    .reset(reset|load),
    .out_s(mac_array_out),
    .in_w(mac_in_w),
    .inst_w(inst_w), 
    .in_n(in_n_l),
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


  ififo #(.col(col), .bw(psum_bw))ififo_inst(
    .clk(clk),
    .reset(reset),
    .in(mac_array_out),
    .out(ofifo_out), 
    .rd(ofifo_valid & acc & (kij_count != 'b1)), 
    .rd_config(kij_count>kij_len),
    .wr(mac_array_valid), 
    .o_full(ofifo_full),  
    .o_ready(ofifo_ready), 
    .o_valid(ofifo_valid));

  always@(posedge clk)begin
    if(reset)begin
      kij_count <= 'b0;
    end
    else begin
      if(load)begin
        kij_count <= kij_count + 'b1;
      end
      else begin
        kij_count <= kij_count;
      end
    end
  end
endmodule
