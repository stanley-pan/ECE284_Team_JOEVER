// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_tile_Part4 (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset,mode_2bit,os,in_n_weight,out_s_weight,out_sta);

parameter bw = 4;
parameter psum_bw = 16;

input mode_2bit;
output [psum_bw-1:0] out_s;
input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
output [bw-1:0] out_e; 
input  [1:0] inst_w;
output [1:0] inst_e;
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;
input os;
input [bw-1:0] in_n_weight;       // Weight input from north
output [bw-1:0] out_s_weight;     // Weight output to south
output [psum_bw-1:0] out_sta;
reg [1:0 ] inst_q;
reg [bw-1:0] a_q, b_q;
reg [psum_bw-1:0] c_q;
reg load_ready_q;
wire [psum_bw-1:0] mac_out;
reg [psum_bw-1:0] out_sta_q;

mac_Part4 #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q), 
        .b(b_q),
        .c(c_q),
	.out(mac_out),
	.mode_2bit(mode_2bit)
); 

assign out_e        = a_q;
assign inst_e       = inst_q;
assign out_s        = mac_out;
assign out_s_weight = in_n_weight;
assign out_sta      = mac_out;

always@(posedge clk) begin
  //on reset, rest instuction and load ready latches
  if(reset)begin
    inst_q <= 'b0;
    load_ready_q <= 'b1;
    a_q <= 'b0;
    b_q <= 'b0;
    c_q <= 'b0;
  end 
  else if(os) 
  begin 
    out_sta_q <= mac_out;
    inst_q  <= inst_w;

    if (inst_w[1]) begin
     a_q <= in_w;
     b_q <= in_n_weight;
     c_q <= out_sta;
     end
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



endmodule
