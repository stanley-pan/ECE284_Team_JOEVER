// Created by Prof. Mingu Kang @VVIP Lab, UCSD ECE Department
// Please do not spread this code without permission

`timescale 1ns/1ps

module mac_row_Part4 (clk,reset,
     in_w,           // inst[1]: execute, inst[0]: kernel loading
   inst_w,
    in_n,
    os,
    mode_2bit,
     in_n_weight,
  out_s,
    out_s_weight,
    valid,
     out_sta
);
    input clk;
    input reset;
    input [bw-1:0] in_w;           // inst[1]: execute, inst[0]: kernel loading
    input [1:0] inst_w;
    input [psum_bw*col-1:0] in_n;
    input os;
    input mode_2bit;
    input [bw*col-1:0] in_n_weight;
    output signed [psum_bw*col-1:0] out_s;
    output [bw*col-1:0] out_s_weight;
    output [col-1:0] valid;
    output [psum_bw*col-1:0] out_sta;

 
    parameter bw = 4;
    parameter psum_bw = 16;
    parameter col = 8;

    // Internal wires for chaining
    wire [(col+1)*bw-1:0] temp;
    wire [(col+1)*2-1:0] temp_inst;

    // Connect input to first tile
    assign temp[bw-1:0] = in_w;
    assign temp_inst[1:0] = inst_w;

    genvar i;
    generate
        for (i = 1; i <= col; i = i + 1) begin : col_num
            mac_tile_Part4 #(.bw(bw), .psum_bw(psum_bw)) mac_tile_instance (
                .clk(clk),
                .reset(reset),
                .in_w(temp[bw*i-1 : bw*(i-1)]),
                .out_e(temp[bw*(i+1)-1 : bw*i]),
                .inst_w(temp_inst[2*i-1 : 2*(i-1)]),
                .inst_e(temp_inst[2*(i+1)-1 : 2*i]),
                .in_n(in_n[psum_bw*i-1 : psum_bw*(i-1)]),
                .out_s(out_s[psum_bw*i-1 : psum_bw*(i-1)]),
                .os(os),
                .out_sta(out_sta[psum_bw*i-1 : psum_bw*(i-1)]),
                .in_n_weight(in_n_weight[bw*i-1 : bw*(i-1)]),
                .out_s_weight(out_s_weight[bw*i-1 : bw*(i-1)]),.mode_2bit(mode_2bit)
            );

            // Assign valid from inst_e[1] of each tile
            assign valid[i-1] = temp_inst[2*(i+1)-1];
        end
    endgenerate

endmodule
