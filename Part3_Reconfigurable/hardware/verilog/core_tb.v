// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
`timescale 1ns/1ps

module core_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter len_kij = 9;
parameter len_onij = 16;
parameter col = 8;
parameter row = 8;
parameter len_nij = 36;

reg clk = 0;
reg reset = 1;

wire [44:0] inst_q; 

reg [1:0]  inst_w_q = 0; 
reg [bw*row-1:0] D_xmem_q = 0;
reg CEN_xmem = 1;
reg WEN_xmem = 1;
reg [10:0] A_xmem = 0;
reg [10:0] A_wmem=0;
reg [10:0] A_wmem_q=0;
reg CEN_xmem_q = 1;
reg WEN_xmem_q = 1;
reg [10:0] A_xmem_q = 0;
reg CEN_pmem = 1;
reg WEN_pmem = 1;
reg [10:0] A_pmem = 0;
reg CEN_pmem_q = 1;
reg WEN_pmem_q = 1;
reg [10:0] A_pmem_q = 0;
reg ofifo_rd_q = 0;
reg ififo_wr_q = 0;
reg ififo_rd_q = 0;
reg l0_rd_q = 0;
reg l0_wr_q = 0;
reg execute_q = 0;
reg load_q = 0;
reg acc_q = 0;
reg acc = 0;

reg [1:0]  inst_w; 
reg [bw*row-1:0] D_xmem;
reg [bw*row-1:0] D_xmem_temp;
reg [len_nij-1:0][bw*row-1:0] D_xmem_temp1;
reg [bw*col-1:0] D_wmem;
reg [bw*col-1:0] D_wmem_q;
reg [len_kij-1:0][bw*col-1:0] D_wmem_temp1;
reg [bw*row-1:0] D_wmem_temp;
reg [col-1:0][psum_bw-1:0] answer;
reg [col-1:0][psum_bw-1:0] result;

reg ofifo_rd;
reg ififo_wr;
reg ififo_rd;
reg l0_rd;
reg l0_wr;
reg execute;
reg load;
reg [8*30:1] stringvar;
reg [8*30:1] w_file_name;
wire ofifo_valid;
wire [col-1:0][psum_bw-1:0] sfp_out;

integer x_file, x_scan_file ; // file_handler
integer w_file, w_scan_file ; // file_handler
integer acc_file, acc_scan_file ; // file_handler
integer out_file, out_scan_file ; // file_handler
integer captured_data; 
integer t, i, j, k, kij;
integer error;
 reg os;
wire [row-1:0][col-1:0][psum_bw-1:0] out_sta;
reg [row-1:0][col-1:0][psum_bw-1:0] out_sta1;
assign inst_q[44:34]=A_wmem_q;
assign inst_q[33] = acc_q;
assign inst_q[32] = CEN_pmem_q;
assign inst_q[31] = WEN_pmem_q;
assign inst_q[30:20] = A_pmem_q;
assign inst_q[19]   = CEN_xmem_q;
assign inst_q[18]   = WEN_xmem_q;
assign inst_q[17:7] = A_xmem_q;
assign inst_q[6]   = ofifo_rd_q;
assign inst_q[5]   = ififo_wr_q;
assign inst_q[4]   = ififo_rd_q;
assign inst_q[3]   = l0_rd_q;
assign inst_q[2]   = l0_wr_q;
assign inst_q[1]   = execute_q; 
assign inst_q[0]   = load_q; 


core  #(.bw(bw), .col(col), .row(row), .nij_len(len_nij), .kij_len(len_kij)) core_instance (
	.clk(clk), 
	.inst(inst_q),
  .inst_w(inst_w_q),
	.ofifo_valid(ofifo_valid),
  .D_xmem(D_xmem_q), 
  .sfp_out(sfp_out), 
	.reset(reset),.os(os),.out_sta(out_sta),.D_wmem(D_wmem_q)); 


initial begin 
  os=1;
  inst_w   = 0; 
  D_xmem   = 0;
  CEN_xmem = 1;
  WEN_xmem = 1;
  A_xmem   = 0;
  ofifo_rd = 0;
  ififo_wr = 0;
  ififo_rd = 0;
  l0_rd    = 0;
  l0_wr    = 0;
  execute  = 0;
  load     = 0;

  $dumpfile("core_tb.vcd");
  $dumpvars(0,core_tb);

  x_file = $fopen("../datafiles/activation.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);

  //////// Reset /////////
  #0.5 clk = 1'b0;   reset = 1;
  #0.5 clk = 1'b1; 

  for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;   reset = 0;
  #0.5 clk = 1'b1; 

  #0.5 clk = 1'b0;   
  #0.5 clk = 1'b1;   
  /////////////////////////
if(os) begin 
   for (t=0; t<len_nij; t=t+1) begin  
    #0.5 clk = 1'b0;  x_scan_file = $fscanf(x_file,"%32b", D_xmem_temp); 
    D_xmem_temp1[t]=D_xmem_temp;
    #0.5 clk = 1'b1; 
   // WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
  end
  #0.5 clk=0;
  D_xmem={D_xmem_temp1[9][3:0],D_xmem_temp1[8][3:0],D_xmem_temp1[7][3:0],D_xmem_temp1[6][3:0],D_xmem_temp1[3][3:0],D_xmem_temp1[2][3:0],D_xmem_temp1[1][3:0],D_xmem_temp1[0][3:0]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
  #0.5 clk=0;
  D_xmem={D_xmem_temp1[10][3:0],D_xmem_temp1[9][3:0],D_xmem_temp1[8][3:0],D_xmem_temp1[7][3:0],D_xmem_temp1[4][3:0],D_xmem_temp1[3][3:0],D_xmem_temp1[2][3:0],D_xmem_temp1[1][3:0]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
   #0.5 clk=0;
  D_xmem={D_xmem_temp1[11][3:0],D_xmem_temp1[10][3:0],D_xmem_temp1[9][3:0],D_xmem_temp1[8][3:0],D_xmem_temp1[5][3:0],D_xmem_temp1[4][3:0],D_xmem_temp1[3][3:0],D_xmem_temp1[2][3:0]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[15][3:0],D_xmem_temp1[14][3:0],D_xmem_temp1[13][3:0],D_xmem_temp1[12][3:0],D_xmem_temp1[9][3:0],D_xmem_temp1[8][3:0],D_xmem_temp1[7][3:0],D_xmem_temp1[6][3:0]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1; 
   #0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[16][3:0],D_xmem_temp1[15][3:0],D_xmem_temp1[14][3:0],D_xmem_temp1[13][3:0],D_xmem_temp1[10][3:0],D_xmem_temp1[9][3:0],D_xmem_temp1[8][3:0],D_xmem_temp1[7][3:0]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[17][3:0],D_xmem_temp1[16][3:0],D_xmem_temp1[15][3:0],D_xmem_temp1[14][3:0],D_xmem_temp1[11][3:0],D_xmem_temp1[10][3:0],D_xmem_temp1[9][3:0],D_xmem_temp1[8][3:0]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[21][3:0],D_xmem_temp1[20][3:0],D_xmem_temp1[19][3:0],D_xmem_temp1[18][3:0],D_xmem_temp1[15][3:0],D_xmem_temp1[14][3:0],D_xmem_temp1[13][3:0],D_xmem_temp1[12][3:0]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;
  D_xmem={D_xmem_temp1[22][3:0],D_xmem_temp1[21][3:0],D_xmem_temp1[20][3:0],D_xmem_temp1[19][3:0],D_xmem_temp1[16][3:0],D_xmem_temp1[15][3:0],D_xmem_temp1[14][3:0],D_xmem_temp1[13][3:0]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;
  D_xmem={D_xmem_temp1[23][3:0],D_xmem_temp1[22][3:0],D_xmem_temp1[21][3:0],D_xmem_temp1[20][3:0],D_xmem_temp1[17][3:0],D_xmem_temp1[16][3:0],D_xmem_temp1[15][3:0],D_xmem_temp1[14][3:0]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;


#0.5 clk=0;
D_xmem={D_xmem_temp1[9][7:4],D_xmem_temp1[8][7:4],D_xmem_temp1[7][7:4],D_xmem_temp1[6][7:4],D_xmem_temp1[3][7:4],D_xmem_temp1[2][7:4],D_xmem_temp1[1][7:4],D_xmem_temp1[0][7:4]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
  #0.5 clk=0;
  D_xmem={D_xmem_temp1[10][7:4],D_xmem_temp1[9][7:4],D_xmem_temp1[8][7:4],D_xmem_temp1[7][7:4],D_xmem_temp1[4][7:4],D_xmem_temp1[3][7:4],D_xmem_temp1[2][7:4],D_xmem_temp1[1][7:4]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
   #0.5 clk=0;
  D_xmem={D_xmem_temp1[11][7:4],D_xmem_temp1[10][7:4],D_xmem_temp1[9][7:4],D_xmem_temp1[8][7:4],D_xmem_temp1[5][7:4],D_xmem_temp1[4][7:4],D_xmem_temp1[3][7:4],D_xmem_temp1[2][7:4]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[15][7:4],D_xmem_temp1[14][7:4],D_xmem_temp1[13][7:4],D_xmem_temp1[12][7:4],D_xmem_temp1[9][7:4],D_xmem_temp1[8][7:4],D_xmem_temp1[7][7:4],D_xmem_temp1[6][7:4]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1; 
   #0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[16][7:4],D_xmem_temp1[15][7:4],D_xmem_temp1[14][7:4],D_xmem_temp1[13][7:4],D_xmem_temp1[10][7:4],D_xmem_temp1[9][7:4],D_xmem_temp1[8][7:4],D_xmem_temp1[7][7:4]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[17][7:4],D_xmem_temp1[16][7:4],D_xmem_temp1[15][7:4],D_xmem_temp1[14][7:4],D_xmem_temp1[11][7:4],D_xmem_temp1[10][7:4],D_xmem_temp1[9][7:4],D_xmem_temp1[8][7:4]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[21][7:4],D_xmem_temp1[20][7:4],D_xmem_temp1[19][7:4],D_xmem_temp1[18][7:4],D_xmem_temp1[15][7:4],D_xmem_temp1[14][7:4],D_xmem_temp1[13][7:4],D_xmem_temp1[12][7:4]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;
  D_xmem={D_xmem_temp1[22][7:4],D_xmem_temp1[21][7:4],D_xmem_temp1[20][7:4],D_xmem_temp1[19][7:4],D_xmem_temp1[16][7:4],D_xmem_temp1[15][7:4],D_xmem_temp1[14][7:4],D_xmem_temp1[13][7:4]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;
  D_xmem={D_xmem_temp1[23][7:4],D_xmem_temp1[22][7:4],D_xmem_temp1[21][7:4],D_xmem_temp1[20][7:4],D_xmem_temp1[17][7:4],D_xmem_temp1[16][7:4],D_xmem_temp1[15][7:4],D_xmem_temp1[14][7:4]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;

D_xmem={D_xmem_temp1[9][11:8],D_xmem_temp1[8][11:8],D_xmem_temp1[7][11:8],D_xmem_temp1[6][11:8],D_xmem_temp1[3][11:8],D_xmem_temp1[2][11:8],D_xmem_temp1[1][11:8],D_xmem_temp1[0][11:8]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
  #0.5 clk=0;
  D_xmem={D_xmem_temp1[10][11:8],D_xmem_temp1[9][11:8],D_xmem_temp1[8][11:8],D_xmem_temp1[7][11:8],D_xmem_temp1[4][11:8],D_xmem_temp1[3][7:4],D_xmem_temp1[2][11:8],D_xmem_temp1[1][11:8]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
   #0.5 clk=0;
  D_xmem={D_xmem_temp1[11][11:8],D_xmem_temp1[10][11:8],D_xmem_temp1[9][11:8],D_xmem_temp1[8][11:8],D_xmem_temp1[5][11:8],D_xmem_temp1[4][11:8],D_xmem_temp1[3][11:8],D_xmem_temp1[2][11:8]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[15][11:8],D_xmem_temp1[14][11:8],D_xmem_temp1[13][11:8],D_xmem_temp1[12][11:8],D_xmem_temp1[9][11:8],D_xmem_temp1[8][11:8],D_xmem_temp1[7][11:8],D_xmem_temp1[6][11:8]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1; 
   #0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[16][11:8],D_xmem_temp1[15][11:8],D_xmem_temp1[14][11:8],D_xmem_temp1[13][11:8],D_xmem_temp1[10][11:8],D_xmem_temp1[9][11:8],D_xmem_temp1[8][11:8],D_xmem_temp1[7][11:8]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[17][11:8],D_xmem_temp1[16][11:8],D_xmem_temp1[15][11:8],D_xmem_temp1[14][11:8],D_xmem_temp1[11][11:8],D_xmem_temp1[10][11:8],D_xmem_temp1[9][11:8],D_xmem_temp1[8][11:8]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[21][11:8],D_xmem_temp1[20][11:8],D_xmem_temp1[19][11:8],D_xmem_temp1[18][11:8],D_xmem_temp1[15][11:8],D_xmem_temp1[14][11:8],D_xmem_temp1[13][11:8],D_xmem_temp1[12][11:8]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;
  D_xmem={D_xmem_temp1[22][11:8],D_xmem_temp1[21][11:8],D_xmem_temp1[20][11:8],D_xmem_temp1[19][11:8],D_xmem_temp1[16][11:8],D_xmem_temp1[15][11:8],D_xmem_temp1[14][11:8],D_xmem_temp1[13][11:8]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;
  D_xmem={D_xmem_temp1[23][11:8],D_xmem_temp1[22][11:8],D_xmem_temp1[21][11:8],D_xmem_temp1[20][11:8],D_xmem_temp1[17][11:8],D_xmem_temp1[16][11:8],D_xmem_temp1[15][11:8],D_xmem_temp1[14][11:8]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;

D_xmem={D_xmem_temp1[9][15:12],D_xmem_temp1[8][15:12],D_xmem_temp1[7][15:12],D_xmem_temp1[6][15:12],D_xmem_temp1[3][15:12],D_xmem_temp1[2][15:12],D_xmem_temp1[1][15:12],D_xmem_temp1[0][15:12]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
  #0.5 clk=0;
  D_xmem={D_xmem_temp1[10][15:12],D_xmem_temp1[9][15:12],D_xmem_temp1[8][15:12],D_xmem_temp1[7][15:12],D_xmem_temp1[4][15:12],D_xmem_temp1[3][15:12],D_xmem_temp1[2][15:12],D_xmem_temp1[1][15:12]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
   #0.5 clk=0;
  D_xmem={D_xmem_temp1[11][15:12],D_xmem_temp1[10][15:12],D_xmem_temp1[9][15:12],D_xmem_temp1[8][15:12],D_xmem_temp1[5][15:12],D_xmem_temp1[4][15:12],D_xmem_temp1[3][15:12],D_xmem_temp1[2][15:12]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[15][15:12],D_xmem_temp1[14][15:12],D_xmem_temp1[13][15:12],D_xmem_temp1[12][15:12],D_xmem_temp1[9][15:12],D_xmem_temp1[8][15:12],D_xmem_temp1[7][15:12],D_xmem_temp1[6][15:12]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1; 
   #0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[16][15:12],D_xmem_temp1[15][15:12],D_xmem_temp1[14][15:12],D_xmem_temp1[13][15:12],D_xmem_temp1[10][15:12],D_xmem_temp1[9][15:12],D_xmem_temp1[8][15:12],D_xmem_temp1[7][15:12]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[17][15:12],D_xmem_temp1[16][15:12],D_xmem_temp1[15][15:12],D_xmem_temp1[14][15:12],D_xmem_temp1[11][15:12],D_xmem_temp1[10][15:12],D_xmem_temp1[9][15:12],D_xmem_temp1[8][15:12]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[21][15:12],D_xmem_temp1[20][15:12],D_xmem_temp1[19][15:12],D_xmem_temp1[18][15:12],D_xmem_temp1[15][15:12],D_xmem_temp1[14][15:12],D_xmem_temp1[13][15:12],D_xmem_temp1[12][15:12]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;
  D_xmem={D_xmem_temp1[22][15:12],D_xmem_temp1[21][15:12],D_xmem_temp1[20][15:12],D_xmem_temp1[19][15:12],D_xmem_temp1[16][15:12],D_xmem_temp1[15][15:12],D_xmem_temp1[14][15:12],D_xmem_temp1[13][15:12]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;
  D_xmem={D_xmem_temp1[23][15:12],D_xmem_temp1[22][15:12],D_xmem_temp1[21][15:12],D_xmem_temp1[20][15:12],D_xmem_temp1[17][15:12],D_xmem_temp1[16][15:12],D_xmem_temp1[15][15:12],D_xmem_temp1[14][15:12]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;


D_xmem={D_xmem_temp1[9][19:16],D_xmem_temp1[8][19:16],D_xmem_temp1[7][19:16],D_xmem_temp1[6][19:16],D_xmem_temp1[3][19:16],D_xmem_temp1[2][19:16],D_xmem_temp1[1][19:16],D_xmem_temp1[0][19:16]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
  #0.5 clk=0;
  D_xmem={D_xmem_temp1[10][19:16],D_xmem_temp1[9][19:16],D_xmem_temp1[8][19:16],D_xmem_temp1[7][19:16],D_xmem_temp1[4][19:16],D_xmem_temp1[3][19:16],D_xmem_temp1[2][19:16],D_xmem_temp1[1][19:16]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
   #0.5 clk=0;
  D_xmem={D_xmem_temp1[11][19:16],D_xmem_temp1[10][19:16],D_xmem_temp1[9][19:16],D_xmem_temp1[8][19:16],D_xmem_temp1[5][19:16],D_xmem_temp1[4][19:16],D_xmem_temp1[3][19:16],D_xmem_temp1[2][19:16]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[15][19:16],D_xmem_temp1[14][19:16],D_xmem_temp1[13][19:16],D_xmem_temp1[12][19:16],D_xmem_temp1[9][19:16],D_xmem_temp1[8][19:16],D_xmem_temp1[7][19:16],D_xmem_temp1[6][19:16]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1; 
   #0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[16][19:16],D_xmem_temp1[15][19:16],D_xmem_temp1[14][19:16],D_xmem_temp1[13][19:16],D_xmem_temp1[10][19:16],D_xmem_temp1[9][19:16],D_xmem_temp1[8][19:16],D_xmem_temp1[7][19:16]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[17][19:16],D_xmem_temp1[16][19:16],D_xmem_temp1[15][19:16],D_xmem_temp1[14][19:16],D_xmem_temp1[11][19:16],D_xmem_temp1[10][19:16],D_xmem_temp1[9][19:16],D_xmem_temp1[8][19:16]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[21][19:16],D_xmem_temp1[20][19:16],D_xmem_temp1[19][19:16],D_xmem_temp1[18][19:16],D_xmem_temp1[15][19:16],D_xmem_temp1[14][19:16],D_xmem_temp1[13][19:16],D_xmem_temp1[12][19:16]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;
  D_xmem={D_xmem_temp1[22][19:16],D_xmem_temp1[21][19:16],D_xmem_temp1[20][19:16],D_xmem_temp1[19][19:16],D_xmem_temp1[16][19:16],D_xmem_temp1[15][19:16],D_xmem_temp1[14][19:16],D_xmem_temp1[13][19:16]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;
  D_xmem={D_xmem_temp1[23][19:16],D_xmem_temp1[22][19:16],D_xmem_temp1[21][19:16],D_xmem_temp1[20][19:16],D_xmem_temp1[17][19:16],D_xmem_temp1[16][19:16],D_xmem_temp1[15][19:16],D_xmem_temp1[14][19:16]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=1'b0;


D_xmem={D_xmem_temp1[9][23:20],D_xmem_temp1[8][23:20],D_xmem_temp1[7][23:20],D_xmem_temp1[6][23:20],D_xmem_temp1[3][23:20],D_xmem_temp1[2][23:20],D_xmem_temp1[1][23:20],D_xmem_temp1[0][23:20]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
  #0.5 clk=0;
  D_xmem={D_xmem_temp1[10][23:20],D_xmem_temp1[9][23:20],D_xmem_temp1[8][23:20],D_xmem_temp1[7][23:20],D_xmem_temp1[4][23:20],D_xmem_temp1[3][23:20],D_xmem_temp1[2][23:20],D_xmem_temp1[1][23:20]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
   #0.5 clk=0;
  D_xmem={D_xmem_temp1[11][23:20],D_xmem_temp1[10][23:20],D_xmem_temp1[9][23:20],D_xmem_temp1[8][23:20],D_xmem_temp1[5][23:20],D_xmem_temp1[4][23:20],D_xmem_temp1[3][23:20],D_xmem_temp1[2][23:20]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[15][23:20],D_xmem_temp1[14][23:20],D_xmem_temp1[13][23:20],D_xmem_temp1[12][23:20],D_xmem_temp1[9][23:20],D_xmem_temp1[8][23:20],D_xmem_temp1[7][23:20],D_xmem_temp1[6][23:20]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1; 
   #0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[16][23:20],D_xmem_temp1[15][23:20],D_xmem_temp1[14][23:20],D_xmem_temp1[13][23:20],D_xmem_temp1[10][23:20],D_xmem_temp1[9][23:20],D_xmem_temp1[8][23:20],D_xmem_temp1[7][23:20]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[17][23:20],D_xmem_temp1[16][23:20],D_xmem_temp1[15][23:20],D_xmem_temp1[14][23:20],D_xmem_temp1[11][23:20],D_xmem_temp1[10][23:20],D_xmem_temp1[9][23:20],D_xmem_temp1[8][23:20]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[21][23:20],D_xmem_temp1[20][23:20],D_xmem_temp1[19][23:20],D_xmem_temp1[18][23:20],D_xmem_temp1[15][23:20],D_xmem_temp1[14][23:20],D_xmem_temp1[13][23:20],D_xmem_temp1[12][23:20]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;
  D_xmem={D_xmem_temp1[22][23:20],D_xmem_temp1[21][23:20],D_xmem_temp1[20][23:20],D_xmem_temp1[19][23:20],D_xmem_temp1[16][23:20],D_xmem_temp1[15][23:20],D_xmem_temp1[14][23:20],D_xmem_temp1[13][23:20]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;
  D_xmem={D_xmem_temp1[23][23:20],D_xmem_temp1[22][23:20],D_xmem_temp1[21][23:20],D_xmem_temp1[20][23:20],D_xmem_temp1[17][23:20],D_xmem_temp1[16][23:20],D_xmem_temp1[15][23:20],D_xmem_temp1[14][23:20]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=1'b0;

D_xmem={D_xmem_temp1[9][27:24],D_xmem_temp1[8][27:24],D_xmem_temp1[7][27:24],D_xmem_temp1[6][27:24],D_xmem_temp1[3][27:24],D_xmem_temp1[2][27:24],D_xmem_temp1[1][27:24],D_xmem_temp1[0][27:24]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
  #0.5 clk=0;
  D_xmem={D_xmem_temp1[10][27:24],D_xmem_temp1[9][27:24],D_xmem_temp1[8][27:24],D_xmem_temp1[7][27:24],D_xmem_temp1[4][27:24],D_xmem_temp1[3][27:24],D_xmem_temp1[2][27:24],D_xmem_temp1[1][27:24]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
   #0.5 clk=0;
  D_xmem={D_xmem_temp1[11][27:24],D_xmem_temp1[10][27:24],D_xmem_temp1[9][27:24],D_xmem_temp1[8][27:24],D_xmem_temp1[5][27:24],D_xmem_temp1[4][27:24],D_xmem_temp1[3][27:24],D_xmem_temp1[2][27:24]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[15][27:24],D_xmem_temp1[14][27:24],D_xmem_temp1[13][27:24],D_xmem_temp1[12][27:24],D_xmem_temp1[9][27:24],D_xmem_temp1[8][27:24],D_xmem_temp1[7][27:24],D_xmem_temp1[6][27:24]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1; 
   #0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[16][27:24],D_xmem_temp1[15][27:24],D_xmem_temp1[14][27:24],D_xmem_temp1[13][27:24],D_xmem_temp1[10][27:24],D_xmem_temp1[9][27:24],D_xmem_temp1[8][27:24],D_xmem_temp1[7][27:24]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[17][27:24],D_xmem_temp1[16][27:24],D_xmem_temp1[15][27:24],D_xmem_temp1[14][27:24],D_xmem_temp1[11][27:24],D_xmem_temp1[10][27:24],D_xmem_temp1[9][27:24],D_xmem_temp1[8][27:24]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[21][27:24],D_xmem_temp1[20][27:24],D_xmem_temp1[19][27:24],D_xmem_temp1[18][27:24],D_xmem_temp1[15][27:24],D_xmem_temp1[14][27:24],D_xmem_temp1[13][27:24],D_xmem_temp1[12][27:24]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;
  D_xmem={D_xmem_temp1[22][27:24],D_xmem_temp1[21][27:24],D_xmem_temp1[20][27:24],D_xmem_temp1[19][27:24],D_xmem_temp1[16][27:24],D_xmem_temp1[15][27:24],D_xmem_temp1[14][27:24],D_xmem_temp1[13][27:24]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;
  D_xmem={D_xmem_temp1[23][27:24],D_xmem_temp1[22][27:24],D_xmem_temp1[21][27:24],D_xmem_temp1[20][27:24],D_xmem_temp1[17][27:24],D_xmem_temp1[16][27:24],D_xmem_temp1[15][27:24],D_xmem_temp1[14][27:24]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=1'b0;

D_xmem={D_xmem_temp1[9][31:28],D_xmem_temp1[8][31:28],D_xmem_temp1[7][31:28],D_xmem_temp1[6][31:28],D_xmem_temp1[3][31:28],D_xmem_temp1[2][31:28],D_xmem_temp1[1][31:28],D_xmem_temp1[0][31:28]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
  #0.5 clk=0;
  D_xmem={D_xmem_temp1[10][31:28],D_xmem_temp1[9][31:28],D_xmem_temp1[8][31:28],D_xmem_temp1[7][31:28],D_xmem_temp1[4][31:28],D_xmem_temp1[3][31:28],D_xmem_temp1[2][31:28],D_xmem_temp1[1][31:28]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
   #0.5 clk=0;
  D_xmem={D_xmem_temp1[11][31:28],D_xmem_temp1[10][31:28],D_xmem_temp1[9][31:28],D_xmem_temp1[8][31:28],D_xmem_temp1[5][31:28],D_xmem_temp1[4][31:28],D_xmem_temp1[3][31:28],D_xmem_temp1[2][31:28]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;   
   #0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[15][31:28],D_xmem_temp1[14][31:28],D_xmem_temp1[13][31:28],D_xmem_temp1[12][31:28],D_xmem_temp1[9][31:28],D_xmem_temp1[8][31:28],D_xmem_temp1[7][31:28],D_xmem_temp1[6][31:28]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1; 
   #0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[16][31:28],D_xmem_temp1[15][31:28],D_xmem_temp1[14][31:28],D_xmem_temp1[13][31:28],D_xmem_temp1[10][31:28],D_xmem_temp1[9][31:28],D_xmem_temp1[8][31:28],D_xmem_temp1[7][31:28]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[17][31:28],D_xmem_temp1[16][31:28],D_xmem_temp1[15][31:28],D_xmem_temp1[14][31:28],D_xmem_temp1[11][31:28],D_xmem_temp1[10][31:28],D_xmem_temp1[9][31:28],D_xmem_temp1[8][31:28]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
 #0.5 clk=0;
  D_xmem={D_xmem_temp1[21][31:28],D_xmem_temp1[20][31:28],D_xmem_temp1[19][31:28],D_xmem_temp1[18][31:28],D_xmem_temp1[15][31:28],D_xmem_temp1[14][31:28],D_xmem_temp1[13][31:28],D_xmem_temp1[12][31:28]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;
  D_xmem={D_xmem_temp1[22][31:28],D_xmem_temp1[21][31:28],D_xmem_temp1[20][31:28],D_xmem_temp1[19][31:28],D_xmem_temp1[16][31:28],D_xmem_temp1[15][31:28],D_xmem_temp1[14][31:28],D_xmem_temp1[13][31:28]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=0;
  D_xmem={D_xmem_temp1[23][31:28],D_xmem_temp1[22][31:28],D_xmem_temp1[21][31:28],D_xmem_temp1[20][31:28],D_xmem_temp1[17][31:28],D_xmem_temp1[16][31:28],D_xmem_temp1[15][31:28],D_xmem_temp1[14][31:28]};
   WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
#0.5 clk=1'b1;
#0.5 clk=1'b0;
#0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
  #0.5 clk = 1'b1; 

  $fclose(x_file);
    #0.5 clk=1'b0;
     A_wmem = 11'b00000000000;
 for (kij=0; kij<9; kij=kij+1) begin  // kij loop

    case(kij)
     0: w_file_name = "../datafiles/weight_k0.txt";
     1: w_file_name = "../datafiles/weight_k1.txt";
     2: w_file_name = "../datafiles/weight_k2.txt";
     3: w_file_name = "../datafiles/weight_k3.txt";
     4: w_file_name = "../datafiles/weight_k4.txt";
     5: w_file_name = "../datafiles/weight_k5.txt";
     6: w_file_name = "../datafiles/weight_k6.txt";
     7: w_file_name = "../datafiles/weight_k7.txt";
     8: w_file_name = "../datafiles/weight_k8.txt";
    endcase
    w_file = $fopen(w_file_name, "r");
    // Following three lines are to remove the first three comment lines of the file
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);

    #0.5 clk = 1'b0;   //reset = 1;
    #0.5 clk = 1'b1; 

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;   reset = 0;
    #0.5 clk = 1'b1; 

    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
    // A_wmem = 11'b00000000000;
    D_wmem = 'b0;
   for (t=0; t<col; t=t+1) begin  
      #0.5 clk = 1'b0;  w_scan_file = $fscanf(w_file,"%32b", D_wmem_temp);
        D_wmem_temp1[t]=D_wmem_temp;
       
      // WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1; 
      #0.5 clk = 1'b1;  
    end
   #0.5 clk=1'b0;
//write memory to weight memory bank
   D_wmem={D_wmem_temp1[7][3:0],D_wmem_temp1[6][3:0],D_wmem_temp1[5][3:0],D_wmem_temp1[4][3:0],D_wmem_temp1[3][3:0],D_wmem_temp1[2][3:0],D_wmem_temp1[1][3:0],D_wmem_temp1[0][3:0]};
       WEN_xmem = 0; CEN_xmem = 0; A_wmem = A_wmem + 1;
    //#0.5 clk=1'b0;
    #0.5 clk=1'b1;
#0.5 clk=1'b0;
   D_wmem={D_wmem_temp1[7][7:4],D_wmem_temp1[6][7:4],D_wmem_temp1[5][7:4],D_wmem_temp1[4][7:4],D_wmem_temp1[3][7:4],D_wmem_temp1[2][7:4],D_wmem_temp1[1][7:4],D_wmem_temp1[0][7:4]};
       WEN_xmem = 0; CEN_xmem = 0; A_wmem = A_wmem + 9;
    //#0.5 clk=1'b0;
    #0.5 clk=1'b1;

#0.5 clk=1'b0;
   D_wmem={D_wmem_temp1[7][11:8],D_wmem_temp1[6][11:8],D_wmem_temp1[5][11:8],D_wmem_temp1[4][11:8],D_wmem_temp1[3][11:8],D_wmem_temp1[2][11:8],D_wmem_temp1[1][11:8],D_wmem_temp1[0][11:8]};
       WEN_xmem = 0; CEN_xmem = 0; A_wmem = A_wmem + 9;
    //#0.5 clk=1'b0;
    #0.5 clk=1'b1;

#0.5 clk=1'b0;
   D_wmem={D_wmem_temp1[7][15:12],D_wmem_temp1[6][15:12],D_wmem_temp1[5][15:12],D_wmem_temp1[4][15:12],D_wmem_temp1[3][15:12],D_wmem_temp1[2][15:12],D_wmem_temp1[1][15:12],D_wmem_temp1[0][15:12]};
       WEN_xmem = 0; CEN_xmem = 0; A_wmem = A_wmem + 9;
    //#0.5 clk=1'b0;
    #0.5 clk=1'b1;

#0.5 clk=1'b0;
   D_wmem={D_wmem_temp1[7][19:16],D_wmem_temp1[6][19:16],D_wmem_temp1[5][19:16],D_wmem_temp1[4][19:16],D_wmem_temp1[3][19:16],D_wmem_temp1[2][19:16],D_wmem_temp1[1][19:16],D_wmem_temp1[0][19:16]};
       WEN_xmem = 0; CEN_xmem = 0; A_wmem = A_wmem + 9;
   // #0.5 clk=1'b0;
    #0.5 clk=1'b1;

#0.5 clk=1'b0;
   D_wmem={D_wmem_temp1[7][23:20],D_wmem_temp1[6][23:20],D_wmem_temp1[5][23:20],D_wmem_temp1[4][23:20],D_wmem_temp1[3][23:20],D_wmem_temp1[2][23:20],D_wmem_temp1[1][23:20],D_wmem_temp1[0][23:20]};
       WEN_xmem = 0; CEN_xmem = 0; A_wmem = A_wmem + 9;
   // #0.5 clk=1'b0;
    #0.5 clk=1'b1;

#0.5 clk=1'b0;
   D_wmem={D_wmem_temp1[7][27:24],D_wmem_temp1[6][27:24],D_wmem_temp1[5][27:24],D_wmem_temp1[4][27:24],D_wmem_temp1[3][27:24],D_wmem_temp1[2][27:24],D_wmem_temp1[1][27:24],D_wmem_temp1[0][27:24]};
       WEN_xmem = 0; CEN_xmem = 0; A_wmem = A_wmem + 9;
   // #0.5 clk=1'b0;
    #0.5 clk=1'b1;

#0.5 clk=1'b0;
   D_wmem={D_wmem_temp1[7][31:28],D_wmem_temp1[6][31:28],D_wmem_temp1[5][31:28],D_wmem_temp1[4][31:28],D_wmem_temp1[3][31:28],D_wmem_temp1[2][31:28],D_wmem_temp1[1][31:28],D_wmem_temp1[0][31:28]};
       WEN_xmem = 0; CEN_xmem = 0; A_wmem = A_wmem + 9;
   // #0.5 clk=1'b0;
    #0.5 clk=1'b1;
  #0.5 clk=1'b0;
  A_wmem=kij+1;
  CEN_xmem=1;
  WEN_xmem=1;
end
  /////// Activation data writing to L0 ///////
    A_xmem = 'b0;
    A_wmem='b0;
    
    for(k=0;k<72;k=k+1)begin
      #0.5 clk = 1'b0;  WEN_xmem = 1; CEN_xmem = 0; A_xmem = A_xmem + 1;A_wmem = A_wmem + 1; inst_w = 2'b10;execute = 1'b1;
      #0.5 clk = 1'b1;  
    end
    /////////////////////////////////////
       /////// Execution ///////
    for(k=0;k<17;k=k+1)begin
        #0.5 clk = 1'b0;  WEN_xmem = 1; CEN_xmem = 0; 
        #0.5 clk = 1'b1;  
        inst_w = 'b00;
    end
    #0.5 clk = 1'b0;  CEN_xmem=1;
    #0.5 clk = 1'b1; 
    #0.5 clk =1'b1;
    ////////// Accumulation /////////
  out_file = $fopen("../datafiles/output.txt", "r");  

  // Following three lines are to remove the first three comment lines of the file
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 

  error = 0;
  


  $display("############ Verification Start during accumulation #############"); 
   
    #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
   
    #0.5 clk = 1'b0; //reset = 1;  
     out_scan_file = $fscanf(out_file,"%b128", answer); // reading from out file to answer
     out_sta1[0][0]=(out_sta[0][0][15]) ? 16'b0 : out_sta[0][0];
     out_sta1[0][1]=(out_sta[0][1][15]) ? 16'b0 : out_sta[0][1];
     out_sta1[0][2]=(out_sta[0][2][15]) ? 16'b0 : out_sta[0][2];
     out_sta1[0][3]=(out_sta[0][3][15]) ? 16'b0 : out_sta[0][3];
     out_sta1[0][4]=(out_sta[0][4][15]) ? 16'b0 : out_sta[0][4];
     out_sta1[0][5]=(out_sta[0][5][15]) ? 16'b0 : out_sta[0][5];
     out_sta1[0][6]=(out_sta[0][6][15]) ? 16'b0 : out_sta[0][6];
     out_sta1[0][7]=(out_sta[0][7][15]) ? 16'b0 : out_sta[0][7];
     result={out_sta1[0][0],out_sta1[0][1],out_sta1[0][2],out_sta1[0][3],out_sta1[0][4],out_sta1[0][5],out_sta1[0][6],out_sta1[0][7]};
      if (result == answer)
         $display("%2d-th output featuremap Data matched! :D", 0); 
       else begin
         $display("%2d-th output featuremap Data ERROR!!", 0); 
         $display("result: %32h", result);
         $display("answer: %32h", answer);
         error = 1;
       end
   
     #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
   
    #0.5 clk = 1'b0; //reset = 1;  
     out_scan_file = $fscanf(out_file,"%b128", answer); // reading from out file to answer
     out_sta1[1][0]=(out_sta[1][0][15]) ? 16'b0 : out_sta[1][0];
     out_sta1[1][1]=(out_sta[1][1][15]) ? 16'b0 : out_sta[1][1];
     out_sta1[1][2]=(out_sta[1][2][15]) ? 16'b0 : out_sta[1][2];
     out_sta1[1][3]=(out_sta[1][3][15]) ? 16'b0 : out_sta[1][3];
     out_sta1[1][4]=(out_sta[1][4][15]) ? 16'b0 : out_sta[1][4];
     out_sta1[1][5]=(out_sta[1][5][15]) ? 16'b0 : out_sta[1][5];
     out_sta1[1][6]=(out_sta[1][6][15]) ? 16'b0 : out_sta[1][6];
     out_sta1[1][7]=(out_sta[1][7][15]) ? 16'b0 : out_sta[1][7];
     result={out_sta1[1][0],out_sta1[1][1],out_sta1[1][2],out_sta1[1][3],out_sta1[1][4],out_sta1[1][5],out_sta1[1][6],out_sta1[1][7]};
      if (result == answer)
         $display("%2d-th output featuremap Data matched! :D", 1); 
       else begin
         $display("%2d-th output featuremap Data ERROR!!", 1); 
         $display("result: %32h", result);
         $display("answer: %32h", answer);
         error = 1;
       end   

     #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
   
    #0.5 clk = 1'b0; //reset = 1;  
     out_scan_file = $fscanf(out_file,"%b128", answer); // reading from out file to answer
out_scan_file = $fscanf(out_file,"%b128", answer); // reading from out file to answer
     out_sta1[2][0]=(out_sta[2][0][15]) ? 16'b0 : out_sta[2][0];
     out_sta1[2][1]=(out_sta[2][1][15]) ? 16'b0 : out_sta[2][1];
     out_sta1[2][2]=(out_sta[2][2][15]) ? 16'b0 : out_sta[2][2];
     out_sta1[2][3]=(out_sta[2][3][15]) ? 16'b0 : out_sta[2][3];
     out_sta1[2][4]=(out_sta[2][4][15]) ? 16'b0 : out_sta[2][4];
     out_sta1[2][5]=(out_sta[2][5][15]) ? 16'b0 : out_sta[2][5];
     out_sta1[2][6]=(out_sta[2][6][15]) ? 16'b0 : out_sta[2][6];
     out_sta1[2][7]=(out_sta[2][7][15]) ? 16'b0 : out_sta[2][7];
     result={out_sta1[2][0],out_sta1[2][1],out_sta1[2][2],out_sta1[2][3],out_sta1[2][4],out_sta1[2][5],out_sta1[2][6],out_sta1[2][7]};
      if (result == answer)
         $display("%2d-th output featuremap Data matched! :D", 2); 
       else begin
         $display("%2d-th output featuremap Data ERROR!!", 2); 
         $display("result: %32h", result);
         $display("answer: %32h", answer);
         error = 1;
       end
    
#0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
   
    #0.5 clk = 1'b0; //reset = 1;  
     out_scan_file = $fscanf(out_file,"%b128", answer); // reading from out file to answer
out_scan_file = $fscanf(out_file,"%b128", answer); // reading from out file to answer
     out_sta1[3][0]=(out_sta[3][0][15]) ? 16'b0 : out_sta[3][0];
     out_sta1[3][1]=(out_sta[3][1][15]) ? 16'b0 : out_sta[3][1];
     out_sta1[3][2]=(out_sta[3][2][15]) ? 16'b0 : out_sta[3][2];
     out_sta1[3][3]=(out_sta[3][3][15]) ? 16'b0 : out_sta[3][3];
     out_sta1[3][4]=(out_sta[3][4][15]) ? 16'b0 : out_sta[3][4];
     out_sta1[3][5]=(out_sta[3][5][15]) ? 16'b0 : out_sta[3][5];
     out_sta1[3][6]=(out_sta[3][6][15]) ? 16'b0 : out_sta[3][6];
     out_sta1[3][7]=(out_sta[3][7][15]) ? 16'b0 : out_sta[3][7];
     result={out_sta1[3][0],out_sta1[3][1],out_sta1[3][2],out_sta1[3][3],out_sta1[3][4],out_sta1[3][5],out_sta1[3][6],out_sta1[3][7]};
      if (result == answer)
         $display("%2d-th output featuremap Data matched! :D", 3); 
       else begin
         $display("%2d-th output featuremap Data ERROR!!", 3); 
         $display("result: %32h", result);
         $display("answer: %32h", answer);
         error = 1;
       end

#0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
   
    #0.5 clk = 1'b0; //reset = 1;  
     out_scan_file = $fscanf(out_file,"%b128", answer); // reading from out file to answer
out_scan_file = $fscanf(out_file,"%b128", answer); // reading from out file to answer
     out_sta1[4][0]=(out_sta[4][0][15]) ? 16'b0 : out_sta[4][0];
     out_sta1[4][1]=(out_sta[4][1][15]) ? 16'b0 : out_sta[4][1];
     out_sta1[4][2]=(out_sta[4][2][15]) ? 16'b0 : out_sta[4][2];
     out_sta1[4][3]=(out_sta[4][3][15]) ? 16'b0 : out_sta[4][3];
     out_sta1[4][4]=(out_sta[4][4][15]) ? 16'b0 : out_sta[4][4];
     out_sta1[4][5]=(out_sta[4][5][15]) ? 16'b0 : out_sta[4][5];
     out_sta1[4][6]=(out_sta[4][6][15]) ? 16'b0 : out_sta[4][6];
     out_sta1[4][7]=(out_sta[4][7][15]) ? 16'b0 : out_sta[4][7];
     result={out_sta1[4][0],out_sta1[4][1],out_sta1[4][2],out_sta1[4][3],out_sta1[4][4],out_sta1[4][5],out_sta1[4][6],out_sta1[4][7]};
      if (result == answer)
         $display("%2d-th output featuremap Data matched! :D", 4); 
       else begin
         $display("%2d-th output featuremap Data ERROR!!",4); 
         $display("result: %32h", result);
         $display("answer: %32h", answer);
         error = 1;
       end

#0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
   
    #0.5 clk = 1'b0; //reset = 1;  
     out_scan_file = $fscanf(out_file,"%b128", answer); // reading from out file to answer
out_scan_file = $fscanf(out_file,"%b128", answer); // reading from out file to answer
     out_sta1[5][0]=(out_sta[5][0][15]) ? 16'b0 : out_sta[5][0];
     out_sta1[5][1]=(out_sta[5][1][15]) ? 16'b0 : out_sta[5][1];
     out_sta1[5][2]=(out_sta[5][2][15]) ? 16'b0 : out_sta[5][2];
     out_sta1[5][3]=(out_sta[5][3][15]) ? 16'b0 : out_sta[5][3];
     out_sta1[5][4]=(out_sta[5][4][15]) ? 16'b0 : out_sta[5][4];
     out_sta1[5][5]=(out_sta[5][5][15]) ? 16'b0 : out_sta[5][5];
     out_sta1[5][6]=(out_sta[5][6][15]) ? 16'b0 : out_sta[5][6];
     out_sta1[5][7]=(out_sta[5][7][15]) ? 16'b0 : out_sta[5][7];
     result={out_sta1[5][0],out_sta1[5][1],out_sta1[5][2],out_sta1[5][3],out_sta1[5][4],out_sta1[5][5],out_sta1[5][6],out_sta1[5][7]};
      if (result == answer)
         $display("%2d-th output featuremap Data matched! :D", 5); 
       else begin
         $display("%2d-th output featuremap Data ERROR!!", 5); 
         $display("result: %32h", result);
         $display("answer: %32h", answer);
         error = 1;
       end

#0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
   
    #0.5 clk = 1'b0; //reset = 1;  
     out_scan_file = $fscanf(out_file,"%b128", answer); // reading from out file to answer
out_scan_file = $fscanf(out_file,"%b128", answer); // reading from out file to answer
     out_sta1[6][0]=(out_sta[6][0][15]) ? 16'b0 : out_sta[6][0];
     out_sta1[6][1]=(out_sta[6][1][15]) ? 16'b0 : out_sta[6][1];
     out_sta1[6][2]=(out_sta[6][2][15]) ? 16'b0 : out_sta[6][2];
     out_sta1[6][3]=(out_sta[6][3][15]) ? 16'b0 : out_sta[6][3];
     out_sta1[6][4]=(out_sta[6][4][15]) ? 16'b0 : out_sta[6][4];
     out_sta1[6][5]=(out_sta[6][5][15]) ? 16'b0 : out_sta[6][5];
     out_sta1[6][6]=(out_sta[6][6][15]) ? 16'b0 : out_sta[6][6];
     out_sta1[6][7]=(out_sta[6][7][15]) ? 16'b0 : out_sta[6][7];
     result={out_sta1[6][0],out_sta1[6][1],out_sta1[6][2],out_sta1[6][3],out_sta1[6][4],out_sta1[6][5],out_sta1[6][6],out_sta1[6][7]};
      if (result == answer)
         $display("%2d-th output featuremap Data matched! :D", 6); 
       else begin
         $display("%2d-th output featuremap Data ERROR!!", 6); 
         $display("result: %32h", result);
         $display("answer: %32h", answer);
         error = 1;
       end

#0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
   
    #0.5 clk = 1'b0; //reset = 1;  
     out_scan_file = $fscanf(out_file,"%b128", answer); // reading from out file to answer
out_scan_file = $fscanf(out_file,"%b128", answer); // reading from out file to answer
     out_sta1[7][0]=(out_sta[7][0][15]) ? 16'b0 : out_sta[7][0];
     out_sta1[7][1]=(out_sta[7][1][15]) ? 16'b0 : out_sta[7][1];
     out_sta1[7][2]=(out_sta[7][2][15]) ? 16'b0 : out_sta[7][2];
     out_sta1[7][3]=(out_sta[7][3][15]) ? 16'b0 : out_sta[7][3];
     out_sta1[7][4]=(out_sta[7][4][15]) ? 16'b0 : out_sta[7][4];
     out_sta1[7][5]=(out_sta[7][5][15]) ? 16'b0 : out_sta[7][5];
     out_sta1[7][6]=(out_sta[7][6][15]) ? 16'b0 : out_sta[7][6];
     out_sta1[7][7]=(out_sta[7][7][15]) ? 16'b0 : out_sta[7][7];
     result={out_sta1[7][0],out_sta1[7][1],out_sta1[7][2],out_sta1[7][3],out_sta1[7][4],out_sta1[7][5],out_sta1[7][6],out_sta1[7][7]};
      if (result == answer)
         $display("%2d-th output featuremap Data matched! :D", 7); 
       else begin
         $display("%2d-th output featuremap Data ERROR!!", 7); 
         $display("result: %32h", result);
         $display("answer: %32h", answer);
         error = 1;
       end





    if (error == 0) begin
  	$display("############ No error detected ##############"); 
  	$display("########### Project Completed !! ############"); 

  end

  //$fclose(acc_file);
  //////////////////////////////////

  for (t=0; t<10; t=t+1) begin  
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;  
  end

  #10 $finish;
    
end 
if(!os) begin 
  /////// Activation data writing to memory ///////
  for (t=0; t<len_nij; t=t+1) begin  
    #0.5 clk = 1'b0;  x_scan_file = $fscanf(x_file,"%32b", D_xmem); WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
    #0.5 clk = 1'b1;   
  end
  #0.5 clk=1'b0;
  

  #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
  #0.5 clk = 1'b1; 

  $fclose(x_file);
  /////////////////////////////////////////////////


  for (kij=0; kij<9; kij=kij+1) begin  // kij loop

    case(kij)
     0: w_file_name = "../datafiles/weight_k0.txt";
     1: w_file_name = "../datafiles/weight_k1.txt";
     2: w_file_name = "../datafiles/weight_k2.txt";
     3: w_file_name = "../datafiles/weight_k3.txt";
     4: w_file_name = "../datafiles/weight_k4.txt";
     5: w_file_name = "../datafiles/weight_k5.txt";
     6: w_file_name = "../datafiles/weight_k6.txt";
     7: w_file_name = "../datafiles/weight_k7.txt";
     8: w_file_name = "../datafiles/weight_k8.txt";
    endcase
    

    w_file = $fopen(w_file_name, "r");
    // Following three lines are to remove the first three comment lines of the file
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);

    #0.5 clk = 1'b0;   //reset = 1;
    #0.5 clk = 1'b1; 

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;   reset = 0;
    #0.5 clk = 1'b1; 

    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   





    /////// Kernel data writing to memory ///////

    A_xmem = 11'b10000000000;
    D_xmem = 'b0;

    for (t=0; t<col; t=t+1) begin  
      #0.5 clk = 1'b0;  w_scan_file = $fscanf(w_file,"%32b", D_xmem); WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1; 
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;  load = 1'b1;
    #0.5 clk = 1'b1; 
    /////////////////////////////////////



    /////// Kernel data writing to L0 ///////
    //load kernal
    #0.5 clk = 1'b0;
    load = 1'b0;
    inst_w = 2'b01; 
    A_xmem = 11'b10000000000;
    for (t=0; t<col; t=t+1) begin  
      #0.5 clk = 1'b0;  WEN_xmem = 1; CEN_xmem = 0; A_xmem = A_xmem + 1;
      #0.5 clk = 1'b1;  
    end
    /////////////////////////////////////



    /////// Kernel loading to PEs ///////
     

    #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; 
    #0.5 clk = 1'b1; 
    inst_w = 2'b00; 
    for(i=0;i<13;i=i+1)begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1; 
    end      
    /////////////////////////////////////
  


    ////// provide some intermission to clear up the kernel loading ///
    #0.5 clk = 1'b0;  load = 0; l0_rd = 0;
    #0.5 clk = 1'b1;  
  

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end
    /////////////////////////////////////



    /////// Activation data writing to L0 ///////
    A_xmem = 'b0;
    
    
    for(k=0;k<len_nij;k=k+1)begin
      #0.5 clk = 1'b0;  WEN_xmem = 1; CEN_xmem = 0; A_xmem = A_xmem + 1; inst_w = 2'b10;execute = 1'b1;
      #0.5 clk = 1'b1;  
    end
    /////////////////////////////////////


    
    /////// Execution ///////
    for(k=0;k<17;k=k+1)begin
        #0.5 clk = 1'b0;  WEN_xmem = 1; CEN_xmem = 0; 
        #0.5 clk = 1'b1;  
        inst_w = 'b00;
    end
    
  
    /////////////////////////////////////



    //////// OFIFO READ ////////
    // Ideally, OFIFO should be read while execution, but we have enough ofifo
    // depth so we can fetch out after execution.
    
    /////////////////////////////////////


  end  // end of kij loop
end



  ////////// Accumulation /////////
  out_file = $fopen("../datafiles/output.txt", "r");  

  // Following three lines are to remove the first three comment lines of the file
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 

  error = 0;



  $display("############ Verification Start during accumulation #############"); 

  for (i=0; i<len_onij+1; i=i+1) begin 
    #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
   
    #0.5 clk = 1'b0; //reset = 1;
    #0.5 clk = 1'b1;  
     if (i>0) begin
     out_scan_file = $fscanf(out_file,"%b128", answer); // reading from out file to answer
       if (sfp_out == answer)
         $display("%2d-th output featuremap Data matched! :D", i); 
       else begin
         $display("%2d-th output featuremap Data ERROR!!", i); 
         $display("sfpout: %32h", sfp_out);
         $display("answer: %32h", answer);
         error = 1;
       end
    #0.5 clk = 1'b0; //reset = 0; 
    #0.5 clk = 1'b1;  
    
    end

    for (j=0; j<len_kij+1; j=j+1) begin 

      #0.5 clk = 1'b0;   
       // if (j<len_kij) begin CEN_pmem = 0; WEN_pmem = 1; acc_scan_file = $fscanf(acc_file,"%11b", A_pmem); end
       //                else  begin CEN_pmem = 1; WEN_pmem = 1; end

        acc = 1;  
      #0.5 clk = 1'b1;   
    end

    #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 
    acc = 0;
  end


  if (error == 0) begin
  	$display("############ No error detected ##############"); 
  	$display("########### Project Completed !! ############"); 

  end

  //$fclose(acc_file);
  //////////////////////////////////

  for (t=0; t<10; t=t+1) begin  
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;  
  end

  #10 $finish;

end

always @ (posedge clk) begin
   inst_w_q   <= inst_w; 
   D_xmem_q   <= D_xmem;
   CEN_xmem_q <= CEN_xmem;
   WEN_xmem_q <= WEN_xmem;
   A_pmem_q   <= A_pmem;
   CEN_pmem_q <= CEN_pmem;
   WEN_pmem_q <= WEN_pmem;
   A_xmem_q   <= A_xmem;
   ofifo_rd_q <= ofifo_rd;
   acc_q      <= acc;
   ififo_wr_q <= ififo_wr;
   ififo_rd_q <= ififo_rd;
   l0_rd_q    <= l0_rd;
   l0_wr_q    <= l0_wr ;
   execute_q  <= execute;
   load_q     <= load;
   A_wmem_q <= A_wmem;
   D_wmem_q   <= D_wmem;
end


endmodule
