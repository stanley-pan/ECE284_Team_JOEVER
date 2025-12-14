// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module l0 (clk, in, out, rd, wr, o_full, reset, o_ready);

  parameter row  = 8;
  parameter bw = 4;

  input  clk;
  input  wr;
  input  rd;
  input  reset;
  input  [row-1:0][bw-1:0] in;
  output [row-1:0][bw-1:0] out;
  output o_full;
  output o_ready;

  wire [row-1:0] empty;
  wire [row-1:0] full;
  reg [row-1:0] rd_en;
  
  genvar i;

  assign o_ready = !full[0]&&!full[1]&&!full[2]&&!full[3]&&!full[4]&&!full[5]&&!full[6]&&!full[7];
  assign o_full  = full[0]&&full[1]&&full[2]&&full[3]&&full[4]&&full[5]&&full[6]&&full[7];


  for (i=0; i<row ; i=i+1) begin : row_num
      fifo_depth16 #(.bw(bw)) fifo_instance (
	 .rd_clk(clk),
	 .wr_clk(clk),
	 .rd(rd_en[i]),
	 .wr(wr),
    .o_empty(empty[i]),
    .o_full(full[i]),
	 .in(in[i]),
	 .out(out[i]),
    .reset(reset));
  end


  always @ (posedge clk) begin
   if (reset) begin
      rd_en <= 8'b00000000;
   end
   else

      /////////////// version1: read all row at a time ////////////////
      //rd_en <= rd ? 8'b11111111 : 8'b00000000;
      ///////////////////////////////////////////////////////



      //////////////// version2: read 1 row at a time /////////////////
      if(rd)begin
        rd_en <=  (rd_en[0]=='b0) ? {rd_en[row:1],1'b1} : rd_en << 1 | rd_en;
      end
      else begin
        rd_en <=  (rd_en[0]=='b1) ? {rd_en[row:1],1'b0} : rd_en << 1;
      end
      ///////////////////////////////////////////////////////
    end

endmodule
