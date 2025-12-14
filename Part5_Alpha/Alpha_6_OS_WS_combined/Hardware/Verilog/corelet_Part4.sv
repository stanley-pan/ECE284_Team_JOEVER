module corelet_Part4 (
    clk, reset, in_w, in_n, inst_w, rd, 
    out, valid, load, os,mode_2bit,
    out_sta, in_n_weight, out_s_weight
);

  parameter bw       = 4;
  parameter psum_bw  = 16;
  parameter col      = 8;
  parameter row      = 8;

  parameter kij_len  = 9;
  parameter nij_len  = 36;
  parameter mij_len  = 16;

  input  clk, reset;
  input  os;
  input mode_2bit;
  // Flattened input buses
  input  [row*bw-1:0]           in_w; 
  input  [col*psum_bw-1:0]      in_n;

  input  [1:0] inst_w;
  input        rd, load;

  input  [col*bw-1:0]           in_n_weight;
  
  // Reduced output widths
  output [15:0] out_s_weight;          // slice of internal out_s_weight
  output [127:0] out_sta;              // slice of internal out_sta
  output valid;
  output [127:0] out;                  // reduced from 256 bits

  // Internal wires (full width)
  wire  [col-1:0] wr_ofifo;
  wire  [col*psum_bw-1:0] mac_array_out;
  wire  [col*bw-1:0] mac_in_w;
  wire  [col*psum_bw-1:0] in_n_l;
  wire  [col*mij_len*psum_bw-1:0] sfu_out_full;
  wire  [col*psum_bw-1:0] ofifo_out;
  wire  [row*col*psum_bw-1:0] out_sta_full;
  wire  [col*bw-1:0] out_s_weight_full;

  wire  [col-1:0] mac_array_valid;
  reg   [col-1:0] last_mac_array_valid;
  wire sfu_valid, ofifo_valid;
  wire ofifo_full, ofifo_ready;

  genvar g;
  generate
    for(g=0; g<col; g=g+1) begin : gen_wr_ofifo
      assign wr_ofifo[g] = (mac_array_valid[g] != last_mac_array_valid[g]) ? mac_array_valid[g] : 1'b0;
    end
  endgenerate

  // Slice internal buses to top-level outputs
  assign in_n_l       = (rd) ? ofifo_out : {col*psum_bw{1'b0}};
  assign out          = sfu_out_full[127:0];       // slice 128 bits (was 255:0)
  assign out_sta      = out_sta_full[127:0];      // slice 128 bits
  assign out_s_weight = out_s_weight_full[15:0];  // slice 16 bits
  assign valid        = ofifo_valid;

  // Connections for mac_array
  mac_array_Part4 #(.bw(bw), .psum_bw(psum_bw), .col(col), .row(row)) mac_array_instance (
    .clk(clk),
    .reset(reset | load),
    .out_s(mac_array_out),
    .in_w(mac_in_w),
    .inst_w(inst_w),
    .in_n(in_n_l),
    .valid(mac_array_valid),
    .in_n_weight(out_s_weight_full),
    .os(os),.mode_2bit(mode_2bit),
    .out_sta(out_sta_full)
  );

  ififo #(.bw(bw), .col(col)) ififo_inst (
    .clk(clk),
    .in(in_n_weight),
    .out(out_s_weight_full),
    .rd((inst_w[0]|inst_w[1]) & os),
    .wr((inst_w[0]|inst_w[1]) & os),
    .o_full(),
    .reset(reset),
    .o_ready()
  );

  l0 #(.bw(bw), .row(row)) l0_inst (
    .clk(clk),
    .in(in_w),
    .out(mac_in_w),
    .rd(inst_w[0]|inst_w[1]),
    .wr(inst_w[0]|inst_w[1]),
    .o_full(),
    .reset(reset),
    .o_ready()
  );

  ofifo #(.col(col), .bw(psum_bw)) ofifo_inst(
    .clk(clk),
    .reset(reset),
    .in(mac_array_out),
    .out(ofifo_out),
    .rd(ofifo_valid),
    .wr(mac_array_valid),
    .o_full(ofifo_full),
    .o_ready(ofifo_ready),
    .o_valid(ofifo_valid)
  );

  sfu_row #(
    .col(col),
    .bw(bw),
    .kij_len(kij_len),
    .nij_len(nij_len),
    .mij_len(mij_len),
    .psum_bw(psum_bw)
  ) sfu_row_inst (
    .clk(clk),
    .reset(reset),
    .in(ofifo_out),
    .out(sfu_out_full),
    .i_valid(ofifo_valid),
    .o_valid(sfu_valid)
  );

  always @(posedge clk) begin
    if (reset)
      last_mac_array_valid <= {col{1'b0}};
    else
      last_mac_array_valid <= mac_array_valid;
  end

endmodule
