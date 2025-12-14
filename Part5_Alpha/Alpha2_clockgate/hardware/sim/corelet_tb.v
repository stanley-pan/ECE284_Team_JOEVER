// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
`timescale 1ns/1ps

module corelet_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter len_kij = 9;
parameter len_onij = 1;
parameter col = 8;
parameter row = 8;
parameter len_nij = 36;

reg clk = 0;
reg reset = 1;
//init activation(easy 1)
//init weight(easy 0-8,-1)

reg [row-1:0][bw-1:0] in_w_q;
reg [1:0] inst_w_q = 'b00;
reg [col-1:0][psum_bw-1:0] in_n = 'b0;
reg ofifo_rd_q ='b0;
reg rd_q = 'b0;
reg load_q;
wire [col-1:0][psum_bw-1:0] out;
wire valid;

integer x_file, x_scan_file ; // file_handler
integer w_file, w_scan_file ; // file_handler

corelet #(.bw(bw), .psum_bw(psum_bw), .col(col), .row(row), .nij_len(len_nij), .kij_len(len_kij)) core_instance (
  .clk(clk), 
  .reset(reset), 
  .in_w(in_w_q), 
  .in_n(in_n), 
  .inst_w(inst_w_q),
  .rd(rd_q),
  .out(out),
  .valid(valid),
  .load(load_q));

reg ofifo_rd = 'b0;
reg [1:0] inst_w = 'b0;
reg [row-1:0][bw-1:0] in_w_l = 'b0;
reg rd = 'b0;
reg signed [len_nij-1:0][psum_bw-1:0] answer = 'b0;
reg [len_nij-1:0][row-1:0][bw-1:0] act='b0;
reg [row-1:0][bw-1:0] act_temp='b0;
reg [len_kij-1:0][row-1:0][bw-1:0] weight='b0;
reg [row-1:0][bw-1:0] weight_temp = 'b0;
reg load = 'b0;

integer kj,j,t,i,k,a,w,v,error,captured_data;
initial begin 

$dumpfile("corelet_tb.vcd");
$dumpvars(0,corelet_tb);


act ='b0;
ofifo_rd = 'b0;
inst_w = 'b0;
rd = 'b0;

x_file = $fopen("activation_1.txt", "r");
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

  /////// Activation data writing to memory ///////
  for(a=0;a<len_nij;a=a+1)begin
    x_scan_file = $fscanf(x_file,"%32b", act_temp);
    act[a] = act_temp;
  end

  /////// Weight data writing to memory ///////
  w_file = $fopen("weight_0_neg_8.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  w_scan_file = $fscanf(w_file,"%s", captured_data);
  w_scan_file = $fscanf(w_file,"%s", captured_data);
  w_scan_file = $fscanf(w_file,"%s", captured_data);

  for(w=0;w<len_kij;w=w+1)begin
    w_scan_file = $fscanf(w_file,"%32b", weight_temp);
    weight[w] = weight_temp;
  end
  for (j=0; j<len_kij; j=j+1) begin 

    #0.5 clk = 1'b0;   
    //send kij
    in_w_l = weight[j];
    load = 1'b1;
    #0.5 clk = 1'b1;
    //load kernal
    #0.5 clk = 1'b0; 
    //load kernal instuction sent
    load = 1'b0;
    inst_w = 'b01;
    #0.5 clk = 1'b1;

    for(i=0;i<22;i=i+1)begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1; 
    end      

    for (t=0; t<len_nij; t=t+1) begin  
      #0.5 clk = 1'b0;  
      //assign activation
      in_w_l = act[t];
      inst_w = 'b10;
      //answer verification
      weight_temp = weight[j];
      act_temp = act[t];
      answer[t] += ({{bw*3{1'b0}},act_temp[0]} * {{bw*3{weight_temp[0][bw-1]}},weight_temp[0]})*8;

    
      #0.5 clk = 1'b1;  
    end   
    
    for(k=0;k<15;k=k+1)begin
        #0.5 clk = 1'b0;
        #0.5 clk = 1'b1; 
        inst_w = 'b00;
    end

end
  
  #0.5 clk = 1'b0;  
  #0.5 clk = 1'b1; 
  #0.5 clk = 1'b0;  
  #0.5 clk = 1'b1; 
  #0.5 clk = 1'b0;  
  #0.5 clk = 1'b1; 

  /////////////////////////////////////////////////

  

  $display("############ Verification Start #############"); 

  //rd = 'b1;
  for (t=0; t<(len_nij); t=t+1) begin  
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;  
    error = ($signed(out[0]) == $signed(answer[t]))? 0:1;
    if (error == 0) begin
      $display("PASS | psum : %h | expected : %h | nij = %d",$signed(out),answer[t],t+1);
    end
    else begin
      $display("FAIL | psum : %h | expected : %h | nij = %d",$signed(out),answer[t],t+1);
    end
  end
   //rd = 'b0;
  for(k=0;k<len_nij;k=k+1)begin
        #0.5 clk = 1'b0;
        #0.5 clk = 1'b1; 
        inst_w = 'b00;
    end

  // end
 

  #10 $finish;

end

always @ (posedge clk) begin
   inst_w_q   <= inst_w; 
   ofifo_rd_q <= ofifo_rd;
   rd_q <= rd;
   in_w_q <= in_w_l;
   load_q <= load;

end


endmodule




