# ECE 284 — Final Project Deliverables

![Folder structure preview](images/folder_structure.svg)


Top-level folders (required):
- `Part1_Vanilla`
- `Part2_SIMD`
- `Part3_Reconfigurable`
- `Part4_Poster`
- `Part5_Alpha`
- `Part6_Report`
- `Part7_ProgressReport`

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
SIMD and Weight/Output-Reconfigurable 2D Systolic Array AI Accelerator

ECE 284: Low Power VLSI for Machine Learning

Team: Jesse Vernallis, Sankalpa Hota, Ned Bitar, Stanley Pan, Rohon Ray, Madeleine McSwain
Department: Electrical and Computer Engineering
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Part 1: Vanilla Weight-Stationary Accelerator

A 4-bit quantization-aware VGG16 model was trained to 92% accuracy, with layer 27 compressed to an 8×8 channel convolution. When mapped to hardware (with padding), this resulted in 36 input pixels and 16 output pixels.

The systolic array executes dot products between input activations and kernel weights, producing partial sums stored in PSUM memory. A Special Function Processor (SFP) uses a LUT to accumulate final outputs across channels and applies ReLU activation. Functional correctness was verified through simulation.

Part 2: 2-bit / 4-bit Lane-Reconfigurable SIMD Array

To reduce activation precision, the model was retrained using 2-bit activations and 4-bit weights, achieving 90% accuracy. The MAC tile was redesigned to operate over two cycles, allowing two 2-bit activations (packed into 4 bits) to be processed per cycle.

Runtime configurability enables switching between 2-bit and 4-bit activation modes without recompilation. The SFU was updated to correctly support both precisions, ensuring correct PSUM accumulation across modes.

Part 3: Weight-Stationary and Output-Stationary Reconfigurable Array

An Output-Stationary (OS) dataflow was added using a dedicated control signal. In OS mode, partial sums are accumulated locally while weights stream from the north and activations from the west. A FIFO-based buffering scheme supports this routing, enabling seamless switching between WS and OS mappings at runtime.
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
Part 4: Alpha Explorations (Summary)

Alpha 1 – ResNet Mapping: Demonstrated efficient mapping of ResNet layers, leveraging structured dataflow and activation reuse.

Alpha 2 – Clock Gating: Introduced FIFO-based clock gating, reducing unnecessary switching activity with minimal performance impact.

Alpha 3 – Pruning: Combined structured and unstructured pruning achieved ~80% sparsity with 82% accuracy.

Alpha 4 – Nij LUT & In-Place PSUM: Eliminated unused MACs and PSUM memory, achieving up to 45% convolution speedup.

Alpha 5 – FIFO Depth Reduction: Reduced FIFO depth from 64 to 16, cutting FIFO register usage by 75%.

Alpha 6 – Full Integration: Unified SIMD precision (2/4-bit) with WS/OS dataflows in a single architecture.

Logic Utilization: 23% ALMs

DSP Blocks: 30

Alpha 7 – FPGA Mapping: Successfully synthesized on Cyclone V FPGA, validating feasibility under hardware constraints.

Alpha 8 – 2-bit Activations & Weights: Reduced logic utilization to 16% ALMs, exploring efficiency vs. accuracy tradeoffs.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Conclusion

This project demonstrates a highly flexible systolic-array-based AI accelerator supporting runtime reconfiguration of precision and dataflow, with multiple architectural optimizations that significantly improve performance, area efficiency, and power characteristics. FPGA synthesis confirms the practicality of the design, while alpha explorations highlight future optimization opportunities.
