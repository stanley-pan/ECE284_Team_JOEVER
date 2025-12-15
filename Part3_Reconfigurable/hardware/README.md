Hardware folder layout and quick run steps

Place sources in `verilog/`, data files in `datafiles/`, and the `filelist` in `sim/`.

Run steps (for reference):
```pwsh
cd Part3_Reconfigurable/hardware/sim
iveri filelist
irun
```

The default testbench should exercise all reconfigurable modes without recompilation.

In Part3_Reconfigurable/hardware/verilog , there are 2 testbenchs. core_tb.v for Output Stationary and core_tb_ws.v for weight stationary

Please ignore filelist2 in sim/ directory in Part3
