// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module ofifo (clk, in, out, rd, wr, o_full, reset, o_ready, o_valid);

  parameter col  = 8;
  parameter bw   = 4;

  input                clk;
  input  [col-1:0]     wr;
  input                rd;
  input                reset;
  input  [col*bw-1:0]  in;
  output [col*bw-1:0]  out;
  output               o_full;
  output               o_ready;
  output               o_valid;

  wire [col-1:0] empty;
  wire [col-1:0] full;

  reg  rd_en;

  // storage for concatenated FIFO outputs
  reg [col*bw-1:0] out_reg;
  assign out = out_reg;

  // status signals
  assign o_full  = &full;       // all columns full
  assign o_ready = ~(&full);    // can still write
  assign o_valid = &(~empty);   // all columns have >=1 data 

  // FIFO output wires
  wire [bw-1:0] fifo_out [0:col-1];

  // instantiate column FIFOs
  genvar i;
  generate
      for (i=0; i<col; i=i+1) begin : col_num
          fifo_depth64 #(.bw(bw)) fifo_instance (
             .rd_clk(clk),
             .wr_clk(clk),
             .rd(rd_en),
             .wr(wr[i]),
             .o_empty(empty[i]),
             .o_full(full[i]),
             .in(in[(i+1)*bw - 1 : i*bw]),
             .out(fifo_out[i]),
             .reset(reset)
          );
      end
  endgenerate

  // read-enable timing + output capture
  always @(posedge clk) begin
    if (reset) begin
        rd_en   <= 1'b0;
        out_reg <= 0;
    end
    else begin
        // generate 1-cycle read pulse
        rd_en <= rd & o_valid;

        // capture concatenated FIFO outputs only when valid read occurs
        if (rd & o_valid) begin
            out_reg <= { fifo_out[7], fifo_out[6], fifo_out[5], fifo_out[4],
                         fifo_out[3], fifo_out[2], fifo_out[1], fifo_out[0] };
        end
    end
  end

endmodule
