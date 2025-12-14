// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset);

parameter bw = 4;
parameter psum_bw = 16;

output [psum_bw-1:0] out_s;
input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
output [bw-1:0] out_e; 
input  [1:0] inst_w;
output [1:0] inst_e;
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;

reg [1:0 ] inst_q;
reg [bw-1:0] a_q, b_q;
reg [psum_bw-1:0] c_q;
reg load_ready_q;
wire [psum_bw-1:0] mac_out;

mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q), 
        .b(b_q),
        .c(c_q),
	.out(mac_out)
); 

always@(posedge clk) begin
  //on reset, rest instuction and load ready latches
  if(reset)begin
    inst_q <= 'b0;
    load_ready_q <= 'b1;
    a_q <= 'b0;
    b_q <= 'b0;
    c_q <= 'b0;
  end 
  else begin
    //pass the execute instuction into the inst_q latch
    inst_q[1] <= inst_w[1];
    //accept in_w into a_q if either execute or kernal loading
    if(inst_w[1] | inst_w[0]) begin
      a_q <= in_w;
    end
    else begin
      a_q <= a_q;
    end
    //if kernal loading and load ready accept new weight in latch
    if(inst_w[0] & load_ready_q) begin
      b_q <= in_w;
      load_ready_q <= 'b0;
    end
    else begin
      b_q <= b_q;
      load_ready_q <= load_ready_q;
    end
    //when weight already loaded, pass the kernal load instr into inst_q
    if(~load_ready_q)begin
      inst_q[0] <= inst_w[0];
    end
    else begin
      inst_q[0] <= inst_q[0];
    end
    //pass on psum if executing and has a weight loaded
    if(inst_w[1]& (~load_ready_q))begin
      c_q <= in_n;
    end
    else begin
      c_q <= 'b0;
    end
  end
  
end

assign out_e = a_q;
assign inst_e = inst_q;
assign out_s = mac_out;

endmodule
