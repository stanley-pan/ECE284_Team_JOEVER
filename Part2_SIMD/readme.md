To test it independently in iverilog :
iverilog -g2012 -o core_tb.out \
mac.sv mac_tile.sv mac_row.sv mac_array.sv channel_adder.sv \
fifo_depth8.sv fifo_depth64.sv fifo_mux_2_1.sv fifo_mux_8_1.sv fifo_mux_16_1.sv \
l0.sv ofifo.sv sram_128b_w2048.sv sfp.sv corelet.sv core.sv core_tb.sv
