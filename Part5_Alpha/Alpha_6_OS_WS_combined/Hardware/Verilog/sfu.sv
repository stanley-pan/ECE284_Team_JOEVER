module sfu (
    clk,
    in,
    out,
    i_valid,
    reset,
    o_valid
);

    parameter bw       = 4;
    parameter kij_len  = 9;
    parameter nij_len  = 36;
    parameter mij_len  = 16;
    parameter psum_bw  = 16;


    input clk;
    input i_valid;
    input reset;
    input [psum_bw-1:0] in;

    output [mij_len*psum_bw-1:0] out;

    output o_valid;

    reg [psum_bw-1:0] psum_q [0:mij_len-1];


    reg [6:0] nij_count;
    reg [4:0] kij_count;

    integer i;      // allowed
    reg [7:0] off;  // predeclared for groups
    reg [7:0] off2;


    always @(posedge clk) begin
        if (reset) begin
            nij_count <= 0;
            kij_count <= 0;

            for (i = 0; i < mij_len; i = i+1)
                psum_q[i] <= 0;
        end
        else begin
            if (i_valid) begin

                // nij_count rollover
                if (nij_count == nij_len-1) begin
                    nij_count <= 0;
                    kij_count <= kij_count + 1;
                end
                else begin
                    nij_count <= nij_count + 1;
                end

                // group 0..2
                if (kij_count==0 || kij_count==1 || kij_count==2) begin
                    // same as your logic
                    if (nij_count==(0 + kij_count))  psum_q[0] <= psum_q[0] + in;
                    if (nij_count==(1 + kij_count))  psum_q[1] <= psum_q[1] + in;
                    if (nij_count==(2 + kij_count))  psum_q[2] <= psum_q[2] + in;
                    if (nij_count==(3 + kij_count))  psum_q[3] <= psum_q[3] + in;

                    if (nij_count==(6 + kij_count))  psum_q[4] <= psum_q[4] + in;
                    if (nij_count==(7 + kij_count))  psum_q[5] <= psum_q[5] + in;
                    if (nij_count==(8 + kij_count))  psum_q[6] <= psum_q[6] + in;
                    if (nij_count==(9 + kij_count))  psum_q[7] <= psum_q[7] + in;

                    if (nij_count==(12 + kij_count)) psum_q[8]  <= psum_q[8]  + in;
                    if (nij_count==(13 + kij_count)) psum_q[9]  <= psum_q[9]  + in;
                    if (nij_count==(14 + kij_count)) psum_q[10] <= psum_q[10] + in;
                    if (nij_count==(15 + kij_count)) psum_q[11] <= psum_q[11] + in;

                    if (nij_count==(18 + kij_count)) psum_q[12] <= psum_q[12] + in;
                    if (nij_count==(19 + kij_count)) psum_q[13] <= psum_q[13] + in;
                    if (nij_count==(20 + kij_count)) psum_q[14] <= psum_q[14] + in;
                    if (nij_count==(21 + kij_count)) psum_q[15] <= psum_q[15] + in;
                end

                // group 3..5
                else if (kij_count==3 || kij_count==4 || kij_count==5) begin
                    off = kij_count + 3;

                    if (nij_count==(0  + off)) psum_q[0]  <= psum_q[0]  + in;
                    if (nij_count==(1  + off)) psum_q[1]  <= psum_q[1]  + in;
                    if (nij_count==(2  + off)) psum_q[2]  <= psum_q[2]  + in;
                    if (nij_count==(3  + off)) psum_q[3]  <= psum_q[3]  + in;

                    if (nij_count==(6  + off)) psum_q[4]  <= psum_q[4]  + in;
                    if (nij_count==(7  + off)) psum_q[5]  <= psum_q[5]  + in;
                    if (nij_count==(8  + off)) psum_q[6]  <= psum_q[6]  + in;
                    if (nij_count==(9  + off)) psum_q[7]  <= psum_q[7]  + in;

                    if (nij_count==(12 + off)) psum_q[8]  <= psum_q[8]  + in;
                    if (nij_count==(13 + off)) psum_q[9]  <= psum_q[9]  + in;
                    if (nij_count==(14 + off)) psum_q[10] <= psum_q[10] + in;
                    if (nij_count==(15 + off)) psum_q[11] <= psum_q[11] + in;

                    if (nij_count==(18 + off)) psum_q[12] <= psum_q[12] + in;
                    if (nij_count==(19 + off)) psum_q[13] <= psum_q[13] + in;
                    if (nij_count==(20 + off)) psum_q[14] <= psum_q[14] + in;
                    if (nij_count==(21 + off)) psum_q[15] <= psum_q[15] + in;
                end

                // group 6..8
                else if (kij_count==6 || kij_count==7 || kij_count==8) begin
                    off2 = kij_count + 6;

                    if (nij_count==(0  + off2)) psum_q[0]  <= psum_q[0]  + in;
                    if (nij_count==(1  + off2)) psum_q[1]  <= psum_q[1]  + in;
                    if (nij_count==(2  + off2)) psum_q[2]  <= psum_q[2]  + in;
                    if (nij_count==(3  + off2)) psum_q[3]  <= psum_q[3]  + in;

                    if (nij_count==(6  + off2)) psum_q[4]  <= psum_q[4]  + in;
                    if (nij_count==(7  + off2)) psum_q[5]  <= psum_q[5]  + in;
                    if (nij_count==(8  + off2)) psum_q[6]  <= psum_q[6]  + in;
                    if (nij_count==(9  + off2)) psum_q[7]  <= psum_q[7]  + in;

                    if (nij_count==(12 + off2)) psum_q[8]  <= psum_q[8]  + in;
                    if (nij_count==(13 + off2)) psum_q[9]  <= psum_q[9]  + in;
                    if (nij_count==(14 + off2)) psum_q[10] <= psum_q[10] + in;
                    if (nij_count==(15 + off2)) psum_q[11] <= psum_q[11] + in;

                    if (nij_count==(18 + off2)) psum_q[12] <= psum_q[12] + in;
                    if (nij_count==(19 + off2)) psum_q[13] <= psum_q[13] + in;
                    if (nij_count==(20 + off2)) psum_q[14] <= psum_q[14] + in;
                    if (nij_count==(21 + off2)) psum_q[15] <= psum_q[15] + in;
                end
            end
        end
    end


    genvar gi;
    generate
        for (gi = 0; gi < mij_len; gi = gi+1) begin: pack
            assign out[gi*psum_bw +: psum_bw] = (psum_q[gi][psum_bw-1]) ?
                                                {psum_bw{1'b0}} :
                                                psum_q[gi];
        end
    endgenerate

    assign o_valid = (kij_count == kij_len);

endmodule
