// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sfu_adder (clk, in, out,i_valid,o_valid, reset);

  parameter col = 8;
  parameter bw = 16;
  parameter kij_len = 9;

  input  clk;
  input  reset;
  input i_valid;
  input  signed [col-1:0][bw-1:0] in;
  output o_valid;
  output signed [col-1:0][bw-1:0] out;
  
  reg [col-1:0][bw-1:0]psum_q;
  reg [$clog2(kij_len)+1:0] kij_count;
  wire [col-1:0][bw-1:0]psum;

  
  function [col-1:0][bw-1:0] add_by_channel([col-1:0][bw-1:0]psum_in,[col-1:0][bw-1:0]psum_old);
    integer i;
    for(i=0;i<col;i=i+1)begin
      
      add_by_channel[i] = psum_in[i] + psum_old[i];
    end
  endfunction
  

  always@(posedge clk)begin
    if(reset)begin
      psum_q <= 'b0;
      kij_count <= 'b0;
    end
    else begin
      if(i_valid & (kij_count == kij_len))begin
        psum_q <= in;
        kij_count <= 'b0;
      end
      else if(i_valid)begin
        psum_q <= add_by_channel(psum_q,in);
        kij_count <= kij_count+1;
      end
      else begin
        psum_q <= psum_q;
        kij_count <= kij_count;
      end
    end
    
  end

  assign out = psum_q;
  assign o_valid = kij_count == kij_len;
endmodule
