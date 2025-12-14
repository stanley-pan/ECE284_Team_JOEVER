module mac (out, a, b, c, mode_2bit);
    parameter bw = 4;
    parameter psum_bw = 16;
    
    // --- New Parameters for 2-bit Path ---
    // Minimum safe width for multiplication factors (e.g., 4 bits to simplify logic)
    localparam term_factor_bw = 4;
    // Product of term_factor_bw * term_factor_bw = 8 bits
    localparam term_prod_bw   = term_factor_bw * 2; 

    output signed [psum_bw-1:0] out;
    input  signed [bw-1:0] a;      // activation (signed)
    input          [bw-1:0] b;      // weight (unsigned)
    input  signed [psum_bw-1:0] c;
    input  mode_2bit;

    // split (2 bits wide)
    wire signed [1:0] a_lo = a[1:0];
    wire signed [1:0] a_hi = a[3:2];

    wire [1:0] b_lo = b[1:0];      // unsigned weight pieces
    wire [1:0] b_hi = b[3:2];

    // ==========================================================
    // --- 2-bit Fused MAC Path (mac2_out) ---
    // ==========================================================

    // 1. Extend factors (2 bits) to term_factor_bw (4 bits)
    //    - activations: sign-extend
    //    - weights: zero-extend
    wire signed [term_factor_bw-1:0] a_lo_ext_4b = $signed({{(term_factor_bw-2){a_lo[1]}}, a_lo});
    wire signed [term_factor_bw-1:0] b_lo_ext_4b = $signed({{(term_factor_bw-2){1'b0}}, b_lo});
    
    wire signed [term_factor_bw-1:0] a_hi_ext_4b = $signed({{(term_factor_bw-2){a_hi[1]}}, a_hi});
    wire signed [term_factor_bw-1:0] b_hi_ext_4b = $signed({{(term_factor_bw-2){1'b0}}, b_hi});

    // 2. Calculate Product: 4-bit * 4-bit = 8-bit signed product
    wire signed [term_prod_bw-1:0] prod_lo_8b = a_lo_ext_4b * b_lo_ext_4b;
    wire signed [term_prod_bw-1:0] prod_hi_8b = a_hi_ext_4b * b_hi_ext_4b;

    // 3. Extend 8-bit products to psum_bw (16 bits) for accumulation
    wire signed [psum_bw-1:0] prod_lo_ext = $signed({{(psum_bw-term_prod_bw){prod_lo_8b[term_prod_bw-1]}}, prod_lo_8b});
    wire signed [psum_bw-1:0] prod_hi_ext = $signed({{(psum_bw-term_prod_bw){prod_hi_8b[term_prod_bw-1]}}, prod_hi_8b});
    
    wire signed [psum_bw-1:0] mac2_out = prod_lo_ext + prod_hi_ext;

    // ==========================================================
    // --- Full 4-bit MAC Path (mac4_out) ---
    // (This path was correct as it used sign extension to psum_bw only for the factor *after* full 4-bit multiplication)
    // ==========================================================

    // 4-bit factors extended to psum_bw (16 bits)
    wire signed [psum_bw-1:0] a_ext_full = $signed({{(psum_bw-bw){a[bw-1]}}, a}); // sign-extend a (signed)
    wire signed [psum_bw-1:0] b_ext_full = $signed({{(psum_bw-bw){1'b0}}, b});    // zero-extend b (unsigned)
    
    // 4-bit * 4-bit multiplication result would be 8 bits, but since we extended to 16 bits,
    // the result of 16-bit * 16-bit will be 32 bits, which is WRONGLY truncated to 16 bits here!
    // The 4-bit path has the SAME bug, but you likely *intended* it to be a full 4-bit multiply.
    
    // Correct 4-bit Path (Fixing the same bug in the 4-bit path):
    localparam full_prod_bw = bw * 2; // 8 bits
    wire signed [full_prod_bw-1:0] full_product_8b;
    
    // A. Extend factors to minimum safe width (4 bits) for multiplication:
    wire signed [bw-1:0] a_4b_factor = a; 
    wire signed [bw-1:0] b_4b_factor = $signed({{(bw-bw){1'b0}}, b}); // zero-extend (not needed here, but shows intent)

    // B. Calculate 8-bit product
    assign full_product_8b = a_4b_factor * b_4b_factor; 

    // C. Extend 8-bit product to 16 bits for accumulation
    wire signed [psum_bw-1:0] mac4_out = $signed({{(psum_bw-full_prod_bw){full_product_8b[full_prod_bw-1]}}, full_product_8b});


    // output select
    assign out = mode_2bit ? (mac2_out + c) : (mac4_out + c);

endmodule

