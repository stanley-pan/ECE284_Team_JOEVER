// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_array_Part4 (clk, reset, out_s, in_w, in_n, inst_w, valid,in_n_weight,os,mode_2bit,out_sta);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;
  input os;
  output [row-1:0][col*psum_bw-1:0] out_sta;
  input  clk, reset;
  output [col-1:0][psum_bw-1:0] out_s;
  input  [row-1:0][bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;
  output [col-1:0] valid;
  input mode_2bit;
  input  [col-1:0][bw-1:0] in_n_weight;
  reg    [2*row-1:0] inst_w_temp;
  wire   [psum_bw*col*(row+1)-1:0] temp;
  wire   [row*col-1:0] valid_temp;

  wire [bw*col*(row+1)-1:0] weight_temp;
  genvar i;
  assign weight_temp[bw*col*1-1:bw*col*0]=in_n_weight;
  assign out_s = temp[psum_bw*col*9-1:psum_bw*col*8];
  assign temp[psum_bw*col*1-1:psum_bw*col*0] = 0;
  assign valid = valid_temp[row*col-1:row*col-8];
  generate
  for (i=1; i < row+1 ; i=i+1) begin : row_num
      mac_row_Part4 #(.bw(bw), .psum_bw(psum_bw)) mac_row_instance (
         .clk(clk),
         .reset(reset),
	 .in_w(in_w[i-1]),
	 .inst_w(inst_w_temp[2*i-1:2*(i-1)]),
	 .in_n(temp[psum_bw*col*i-1:psum_bw*col*(i-1)]),
         .valid(valid_temp[col*i-1:col*(i-1)]),
	 .out_s(temp[psum_bw*col*(i+1)-1:psum_bw*col*(i)]),.os(os),
         .out_sta(out_sta[i-1]),
        .in_n_weight(weight_temp[bw*col*i-1:bw*col*(i-1)]),
        .out_s_weight(weight_temp[bw*col*(i+1)-1:bw*col*(i)]),.mode_2bit(mode_2bit));
  end
  endgenerate
  always @ (posedge clk) begin


    //valid <= valid_temp[row*col-1:row*col-8];
    inst_w_temp[1:0]   <= inst_w; 
    inst_w_temp[3:2]   <= inst_w_temp[1:0]; 
    inst_w_temp[5:4]   <= inst_w_temp[3:2]; 
    inst_w_temp[7:6]   <= inst_w_temp[5:4]; 
    inst_w_temp[9:8]   <= inst_w_temp[7:6]; 
    inst_w_temp[11:10] <= inst_w_temp[9:8]; 
    inst_w_temp[13:12] <= inst_w_temp[11:10]; 
    inst_w_temp[15:14] <= inst_w_temp[13:12]; 
  end



endmodule
