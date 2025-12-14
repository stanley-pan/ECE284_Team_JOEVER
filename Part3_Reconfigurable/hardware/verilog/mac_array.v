// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_array (clk, reset, out_s, in_w, in_n, inst_w, valid,os,weight_in,out_sta);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input  clk, reset;
  output [col-1:0][psum_bw-1:0] out_s;
  input  [row-1:0][bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [col-1:0][psum_bw-1:0] in_n;
  output [col-1:0] valid;
 
  wire [row:0][col-1:0][psum_bw-1:0] temp_psum; //temp psum for each row to pass south
  wire [row-1:0][col-1:0] temp_valid; //temp valid bit for each row
  reg [row-1:0][1:0] inst_q; //instuction que for each row
  output [row-1:0][col-1:0][psum_bw-1:0] out_sta;
  input [col-1:0][bw-1:0] weight_in;
  input os;
  wire [row:0][col-1:0][bw-1:0] temp_weight;
  assign temp_psum[0] = in_n; 
  assign temp_weight[0]=weight_in;
  genvar i; 
  for (i=0; i < row ; i=i+1) begin : row_num
      mac_row #(.bw(bw), .psum_bw(psum_bw)) mac_row_instance (
      .clk(clk),
      .reset(reset),
      .in_w(in_w[i]),
      .inst_w(inst_q[i]),
      .in_n(temp_psum[i]), 
      .out_s(temp_psum[i+1]),
      .valid(temp_valid[i]),.os(os),.out_sta(out_sta[i]),.weight_in(temp_weight[i]),.weight_out(temp_weight[i+1]));
  end
 
  //pass inst_w throug the rows via que
  integer j;
  always @ (posedge clk) begin
    if(reset)begin
      inst_q <= 'b0;
    end
    else begin
      inst_q[0] <= inst_w;

      for(j=0;j<row-1;j=j+1)begin
        inst_q[j+1] <= inst_q[j];
      end
    end
  end
  //last row's output psum -> out_s
  assign out_s = temp_psum[row];
  //last row's valid bits -> valid
  assign valid = temp_valid[row-1];
endmodule
