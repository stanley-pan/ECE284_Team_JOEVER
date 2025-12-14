// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset,mode_2bit);

parameter bw = 4;
parameter psum_bw = 16;

input  clk;
input  reset;
input  mode_2bit;

input  [bw-1:0] in_w;         // activation / weight stream
input  [psum_bw-1:0] in_n;    // psum from north
input  [1:0] inst_w;          // inst[1]=execute, inst[0]=kernel load

output [bw-1:0] out_e;
output [psum_bw-1:0] out_s;
output [1:0] inst_e;

reg [bw-1:0] a_q0, a_q1;
reg [bw-1:0] b_q0, b_q1;
reg [psum_bw-1:0] c_q0, c_q1;

reg load_ready_q0, load_ready_q1;
reg [1:0] inst_q;
reg [bw-1:0] a_q;

/* latch mode to avoid mid-cycle hazards */
reg mode_2bit_q;

wire [psum_bw-1:0] mac_out0, mac_out1;

mac #(.bw(bw), .psum_bw(psum_bw)) mac0 (
  .a(a_q0), .b(b_q0), .c(c_q0), .out(mac_out0)
);

mac #(.bw(bw), .psum_bw(psum_bw)) mac1 (
  .a(a_q1), .b(b_q1), .c(c_q1), .out(mac_out1)
);

/* ---------------- Sequential logic ---------------- */

always @(posedge clk) begin
  if (reset) begin
    /* instruction + mode */
    inst_q        <= 2'b0;
    mode_2bit_q  <= 1'b0;

    /* activation forwarding */
    a_q           <= 'b0;
    a_q0          <= 'b0;
    a_q1          <= 'b0;

    /* weights */
    b_q0          <= 'b0;
    b_q1          <= 'b0;
    load_ready_q0 <= 1'b1;
    load_ready_q1 <= 1'b1;

    /* psum */
    c_q0          <= 'b0;
    c_q1          <= 'b0;
  end
  else begin
    /* latch mode (prevents execute-time glitches) */
    if (inst_w[0])
      mode_2bit_q <= mode_2bit;

    /* forward execute instruction */
    inst_q[1] <= inst_w[1];

    /* activation forwarding east */
    if (inst_w[1] | inst_w[0])
      a_q <= in_w;

    /* activation split */
    if (inst_w[1] | inst_w[0]) begin
      if (mode_2bit_q) begin
        a_q0 <= {2'b00, in_w[1:0]};
        a_q1 <= {2'b00, in_w[3:2]};
      end
      else begin
        a_q0 <= in_w;
        a_q1 <= 'b0;
      end
    end

    /* kernel loading */
    if (inst_w[0]) begin
      if (load_ready_q0) begin
        b_q0 <= in_w;
        load_ready_q0 <= 1'b0;
      end
      else if (mode_2bit_q && load_ready_q1) begin
        b_q1 <= in_w;
        load_ready_q1 <= 1'b0;
      end
    end

    /* forward kernel-load instruction only after weights are ready */
    if (~load_ready_q0 & (~mode_2bit_q | ~load_ready_q1))
      inst_q[0] <= inst_w[0];

    /* psum injection (ONLY once) */
    if (inst_w[1] & ~load_ready_q0 & (~mode_2bit_q | ~load_ready_q1)) begin
      c_q0 <= in_n;
      c_q1 <= 'b0;
    end
    else begin
      c_q0 <= 'b0;    // In_n + PE + PE for 2 bit, In_n + PE for 4 bit
      c_q1 <= 'b0;
    end
  end
end

/* ---------------- Outputs ---------------- */

assign out_e  = a_q;
assign inst_e = inst_q;
assign out_s  = mac_out0 + (mode_2bit_q ? mac_out1 : 'b0);

endmodule

