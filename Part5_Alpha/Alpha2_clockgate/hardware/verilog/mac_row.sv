// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_row (clk, out_s, in_w, in_n, valid, inst_w, reset, clk_en);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;

  input  clk, reset;
  input clk_en;
  
  output [col-1:0][psum_bw-1:0] out_s;
  output [col-1:0] valid;
  input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [col-1:0][psum_bw-1:0] in_n;

  wire  [col:0][bw-1:0] temp_weight;
  wire [col:0][1:0] temp_inst;

  assign temp_weight[0]= in_w;
  assign temp_inst[0] = inst_w;

  genvar i;
  generate
    for (i=0; i < col ; i=i+1) begin : col_num
        mac_tile #(.bw(bw), .psum_bw(psum_bw)) mac_tile_instance (
          .clk(clk),
          .reset(reset),
          .in_w( temp_weight[i]),
          .out_e(temp_weight[i+1]),
          .inst_w(temp_inst[i]),
          .inst_e(temp_inst[i+1]),
          .in_n(in_n[i]),
          .out_s(out_s[i]),
          .clk_en(clk_en)
        );

        assign valid[i] = temp_inst[i+1][1];
    end
  endgenerate
 
endmodule
