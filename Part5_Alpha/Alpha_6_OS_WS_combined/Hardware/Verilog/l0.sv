module l0 (
    clk,
    wr,
    rd,
    reset,
    in,
    out,
    o_full,
    o_ready
);

parameter row = 8;
parameter bw  = 4;

input clk;
input wr;
input rd;
input reset;
input  [row*bw-1:0] in;
output [row*bw-1:0] out;
output o_full;
output o_ready;

wire [row-1:0] empty;
wire [row-1:0] full;

reg  [row-1:0] rd_en;

assign o_full  = &full;
assign o_ready = ~o_full;

wire [bw-1:0] fifo_out  [0:row-1];

genvar i;
generate
    for (i=0; i<row; i=i+1) begin : fifo_rows
        fifo_depth64 #( .bw(bw) ) fifo_inst (
            .rd_clk(clk),
            .wr_clk(clk),
            .rd(rd_en[i]),
            .wr(wr),
            .o_empty(empty[i]),
            .o_full(full[i]),
            .in(in[(i+1)*bw-1 : i*bw]),
            .out(fifo_out[i]),
            .reset(reset)
        );
    end
endgenerate

assign out = { fifo_out[7],
               fifo_out[6],
               fifo_out[5],
               fifo_out[4],
               fifo_out[3],
               fifo_out[2],
               fifo_out[1],
               fifo_out[0] };

always @(posedge clk or posedge reset) begin
    if (reset)
        rd_en <= 0;
    else begin
        if (rd)
            rd_en <= { rd_en[row-1:1], 1'b1 };
        else
            rd_en <= { rd_en[row-1:1], 1'b0 };
    end
end

endmodule
