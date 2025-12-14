// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sfu (clk, in, out, i_valid,  reset, o_valid);

  parameter bw = 4;
  parameter kij_len = 9;
  parameter nij_len = 36;

  input  clk;
  input  i_valid;
  input  reset;
  input  signed [bw-1:0] in;
  output signed [nij_len-1:0][bw-1:0] out;
  output o_valid;

  reg [$clog2(nij_len)+1:0] nij_count;
  reg [$clog2(kij_len)+1:0] kij_count;
  reg signed [nij_len-1:0][bw-1:0] psum_q;
  
  always@(posedge clk)begin
    if(reset ) begin
      psum_q <= 'b0;
      nij_count <= 'b0;
      kij_count <= 'b0;
    end
    else begin
      if(i_valid & (nij_count == (nij_len-1)))begin
        psum_q[nij_count] <= psum_q[nij_count] + in;
        nij_count <= 'b0;
        kij_count <= kij_count + 1;
      end
      else if(i_valid)begin
        psum_q[nij_count] <= psum_q[nij_count] + in;
        nij_count <= nij_count + 1;
        kij_count <= kij_count;
      end
      else begin
        psum_q <= psum_q;
        nij_count <= nij_count;
        kij_count <= kij_count;
      end
    end
  end

assign o_valid = (kij_count == (kij_len)) ? 1'b1 : 1'b0;
assign out = psum_q;
endmodule
