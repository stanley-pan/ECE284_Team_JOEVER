// Please do not spread this code without permission 
module ififo(clk, in, out, rd, wr, o_full, reset, o_ready);

  parameter col  = 8;
  parameter bw = 4;

  input  clk;
  input  wr;
  input  rd;
  input  reset;
  input  [col-1:0][bw-1:0] in;
  output [col-1:0][bw-1:0] out;
  output o_full;
  output o_ready;

  wire [col-1:0] empty;
  wire [col-1:0] full;
  reg [col-1:0] rd_en;
  
  genvar i;

  assign o_ready = !full[0] && !full[1] && !full[2] && !full[3] &&
                   !full[4] && !full[5] && !full[6] && !full[7];
  assign o_full  = full[0] && full[1] && full[2] && full[3] &&
                   full[4] && full[5] && full[6] && full[7];

  generate
    for (i=0; i<col; i=i+1) begin : col_num
      fifo_depth64 #(.bw(bw)) fifo_instance (
        .rd_clk(clk),
        .wr_clk(clk),
        .rd(rd_en[i]),
        .wr(wr),
        .o_empty(empty[i]),
        .o_full(full[i]),
        .in(in[i]),
        .out(out[i]),
        .reset(reset)
      );
    end
  endgenerate

  always @ (posedge clk) begin
    if (reset) begin
      rd_en <= 8'b00000000;
    end
    else begin
      /////////////// version1: read all row at a time ////////////////
      // rd_en <= rd ? 8'b11111111 : 8'b00000000;
      ///////////////////////////////////////////////////////

      //////////////// version2: read 1 row at a time /////////////////
      if (rd) begin
        // shift left and insert 1 at LSB
        rd_en <= {rd_en[6:0], 1'b1};
      end
      else begin
        // shift left and insert 0 at LSB
        rd_en <= {rd_en[6:0], 1'b0};
      end
      ///////////////////////////////////////////////////////
    end
  end

endmodule

