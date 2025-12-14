// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sfp (clk, in, out, A, i_valid, o_valid, reset);

  parameter col = 8;
  parameter bw = 16;
  parameter kij_len = 9;
  parameter nij_len = 36;

  input  clk;
  input  reset;
  input  i_valid;
  input  signed [col-1:0][bw-1:0] in;

  output o_valid;
  output signed [col-1:0][bw-1:0] out;
  output [10:0] A;
  
  reg signed [col-1:0][bw-1:0] psum_q;
  reg [$clog2(kij_len)+1:0] kij_count;
  reg [$clog2(nij_len)+1:0] nij_count;
  reg [5:0] fm_count;

  reg valid_mem_rd1, valid_mem_rd2;

  /* ------------------------------------------------------------ */
  /* Address + Valid Logic                                         */
  /* ------------------------------------------------------------ */
  assign A = nij_lut(nij_count, kij_count, fm_count) 
             + kij_count * nij_len;

  assign o_valid = ~valid_mem_rd1 & valid_mem_rd2;

  /* ------------------------------------------------------------ */
  /* Output ReLU + Channel Reverse                                 */
  /* ------------------------------------------------------------ */
  genvar j;
  generate
    for (j = 0; j < col; j = j + 1) begin : OUT_RELU
      assign out[j] = (psum_q[col-1-j] < 0) ? 'b0 : psum_q[col-1-j];
    end
  endgenerate

  /* ------------------------------------------------------------ */
  /* Functions                                                     */
  /* ------------------------------------------------------------ */
  function automatic [col-1:0][bw-1:0] add_by_channel;
    input [col-1:0][bw-1:0] psum_in;
    input [col-1:0][bw-1:0] psum_old;
    integer i;
    begin
      for (i = 0; i < col; i = i + 1) begin
        add_by_channel[i] = psum_in[i] + psum_old[i];
      end
    end
  endfunction

  function automatic [$clog2(nij_len)+1:0] kij_lut;
    input [$clog2(kij_len)+1:0] kij;
    begin
      if (kij < 3)
        kij_lut = 'd0;
      else if (kij < 6)
        kij_lut = 'd3;
      else
        kij_lut = 'd6;
    end
  endfunction

  function automatic [$clog2(nij_len)+1:0] nij_lut;
    input [$clog2(nij_len)+1:0] nij;
    input [$clog2(kij_len)+1:0] kij;
    input [5:0] fm;
    begin
      if (fm < 4)
        nij_lut = nij + kij_lut(kij) + 'd0;
      else if (fm < 8)
        nij_lut = nij + kij_lut(kij) + 'd2;
      else if (fm < 12)
        nij_lut = nij + kij_lut(kij) + 'd4;
      else
        nij_lut = nij + kij_lut(kij) + 'd6;
    end
  endfunction

  /* ------------------------------------------------------------ */
  /* Sequential Logic                                              */
  /* ------------------------------------------------------------ */
  always @(posedge clk) begin
    if (reset) begin
      psum_q        <= 'b0;
      kij_count     <= 'b0;
      nij_count     <= 'b0;
      fm_count      <= 'b0;
      valid_mem_rd1 <= 'b0;
      valid_mem_rd2 <= 'b0;
    end
    else begin
      // memory fetch counters
      if (i_valid && (kij_count == kij_len)) begin
        kij_count <= 'b0;
        nij_count <= nij_count - (kij_len - 1);
        fm_count  <= fm_count + 1;
      end
      else if (i_valid) begin
        kij_count <= kij_count + 1;
        nij_count <= nij_count + 1;
      end

      // PSUM accumulation
      if (valid_mem_rd2 && (kij_count == 'd2)) begin
        psum_q <= in;
      end
      else if (valid_mem_rd2) begin
        psum_q <= add_by_channel(in, psum_q);
      end

      valid_mem_rd1 <= i_valid;
      valid_mem_rd2 <= valid_mem_rd1;
    end
  end

endmodule

