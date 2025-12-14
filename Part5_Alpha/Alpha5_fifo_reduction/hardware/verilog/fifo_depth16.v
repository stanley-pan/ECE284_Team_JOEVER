// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fifo_depth16 (
    rd_clk,
    wr_clk,
    in,
    out,
    rd,
    wr,
    o_full,
    o_empty,
    reset
);

  parameter bw        = 4;
  parameter lrf_depth = 16;

  input  rd_clk;
  input  wr_clk;
  input  rd;
  input  wr;
  input  reset;
  output o_full;
  output o_empty;
  input  [bw-1:0] in;
  output [bw-1:0] out;

  wire full, empty;

  // For depth-16 FIFO, we need 4 index bits + 1 wrap bit (same scheme as depth8)
  reg [4:0] rd_ptr = 5'b00000;
  reg [4:0] wr_ptr = 5'b00000;

  // 16-deep storage
  reg [bw-1:0] mem [0:lrf_depth-1];

  // Empty: pointers equal
  assign empty = (wr_ptr == rd_ptr);

  // Full: index equal but wrap bits different
  assign full  = ((wr_ptr[3:0] == rd_ptr[3:0]) && (wr_ptr[4] != rd_ptr[4]));

  assign o_full  = full;
  assign o_empty = empty;

  // Combinational read from the current read address
  assign out = mem[rd_ptr[3:0]];

  // Read pointer update
  always @(posedge rd_clk) begin
    if (reset) begin
      rd_ptr <= 5'b00000;
    end
    else if (rd && !empty) begin
      rd_ptr <= rd_ptr + 1'b1;
    end
  end

  // Write pointer + memory write
  always @(posedge wr_clk) begin
    if (reset) begin
      wr_ptr <= 5'b00000;
    end
    else begin 
      if (wr && !full) begin
        mem[wr_ptr[3:0]] <= in;
        wr_ptr <= wr_ptr + 1'b1;
      end
    end
  end

endmodule