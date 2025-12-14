module sfu_row (
    clk,
    in,
    out,
    i_valid,
    reset,
    o_valid
);

  parameter col      = 8;
  parameter bw       = 4;
  parameter kij_len  = 9;
  parameter nij_len  = 36;
  parameter mij_len  = 16;
  parameter psum_bw  = 16;

  input  clk;
  input  i_valid;
  input  reset;
  input  signed [col*psum_bw-1:0] in;
  output [col*mij_len*psum_bw-1:0] out;
  output o_valid;
  wire [col-1:0] sfu_valid;

  wire signed [col*mij_len*psum_bw-1:0] sfu_out;

  reg [$clog2(nij_len)+1:0] nij_count;

  assign o_valid = &sfu_valid;

  genvar j, k;
  generate
    for (j = 0; j < col; j = j + 1) begin : OUT_COL
      for (k = 0; k < mij_len; k = k + 1) begin : OUT_MIJ
        assign out[ (j*mij_len + k)*psum_bw +: psum_bw ] =
            sfu_out[( j*mij_len*psum_bw + k*psum_bw ) +: psum_bw];
      end
    end
  endgenerate

  genvar i;
  generate
    for (i = 0; i < col; i = i + 1) begin : COL_NUM
      wire signed [psum_bw-1:0] in_slice = in[i*psum_bw +: psum_bw];
      wire [mij_len*psum_bw-1:0] out_slice;
      assign sfu_out[i*mij_len*psum_bw +: mij_len*psum_bw] = out_slice;

      sfu #(
        .bw(bw),
        .kij_len(kij_len),
        .nij_len(nij_len),
        .mij_len(mij_len),
        .psum_bw(psum_bw)
      ) sfu_inst (
        .clk(clk),
        .reset(reset),
        .in(in_slice),
        .out(out_slice),
        .i_valid(i_valid),
        .o_valid(sfu_valid[i])
      );
    end
  endgenerate

  always @(posedge clk) begin
    if (reset) begin
      nij_count <= 'b0;
    end
    else begin
      if (&sfu_valid)
        nij_count <= nij_count + 1'b1;
    end
  end

endmodule
