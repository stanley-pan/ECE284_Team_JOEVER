module sfu_row (clk, in, out, i_valid,  reset, o_valid);

  parameter col  = 8;
  parameter bw = 4;
  parameter kij_len = 9;
  parameter nij_len = 36;

  input  clk;
  input  i_valid;
  input  reset;
  input  [col-1:0][bw-1:0] in;
  output [col-1:0][bw-1:0] out;
  output o_valid;

  wire [col-1:0] sfu_valid;
  wire [col-1:0][nij_len-1:0][bw-1:0]sfu_out;
  reg [$clog2(nij_len)+1:0] nij_count;

  assign o_valid = &sfu_valid;

  genvar j;
  generate
    for(j=0;j<col;j=j+1) begin : gen_out
      assign out[j] = sfu_out[j][nij_count];
    end
  endgenerate
  
  genvar i;
  generate
    for(i=0;i<col;i=i+1)begin : col_num
      sfu #(.bw(bw), .kij_len(kij_len), .nij_len(nij_len)) sfu_inst (
        .clk(clk), 
        .reset(reset),
        .in(in[i]), 
        .out(sfu_out[i]), 
        .i_valid(i_valid), 
        .o_valid(sfu_valid[i]));
    end
  endgenerate
  

  always@(posedge clk)begin
    if(reset)begin
      nij_count <= 'b0;
    end
    else begin
      if(&sfu_valid)begin
        nij_count <= nij_count + 'b1;
      end
      else begin
        nij_count <= nij_count;
      end
    end
  end
endmodule
