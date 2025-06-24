# Direct-digital-frequency-synthesizer
**Configurable Direct Digital Frequency Synthesizer based on LUT and rotation**

**OVERVIEW**

This project provides a hardware implementation of a **Direct Digital Frequency Synthesizer (DDFS)** using HDL (Verilog). By utilizing a Phase-Lookup Table (LUT) and phase rotation technique, it generates highly configurable sinusoidal waveforms with fine frequency control.

**FEATURES**
- Supports variable output frequencies determined by a **Frequency Control Word (FCW)**
- Efficient implementation using **phase-LUT + rotation** for waveform generation
- Implemented in **Verilog**
- Modular design: **phase accumulator**, **LUT lookup**, **phase rotation**, and **output logic**
- Targeted for synthesis on modern FPGA platforms

**PROJECT STRUCTURE**

/verilog/ – Verilog implementation files

/sim/ – Testbenches and stimulus files

/README.md – This document

/BTP.pdf - Contains project report for better visual understanding

Each HDL folder contains top-level modules—`ddfs_accumulator`, `phase_to_amplitude`, and LUT modules—along with vendor-specific wrapper files.

**HOW IT WORKS**

1. **Phase Accumulator**  
A digital phase accumulator updates the phase on each clock cycle:
 
 phase_next = phase_current + FCW

 The FCW sets the step size and therefore the output frequency.

2. **Phase-to-Amplitude Conversion**  
Uses a LUT to map the high-order bits of the phase to amplitude values, typically representing a sine wave.

3. **Phase Rotation / Interpolation**  
Optional rotation improves resolution between LUT entries, enhancing spectral purity and reducing spurs.

4. **DAC Output**  
The digital amplitude is output to a DAC or digital interface for waveform generation.

FCW = (2^N * f_out) / f_clk

- **N**: number of accumulator bits (e.g. 32 or 16 bits)  
- **f_clk**: system clock frequency  
- This allows precise digital tuning and fine frequency resolution.

 **SIMULATION AND TESTING**

Testbenches (in `/sim/`) instantiate the full DDFS pipeline with:
- Parameterizable clocks and sample rates
- Various FCW inputs
- Waveform verification via waveform viewers (e.g., GTKWave)

**SYNTHESIS GUIDELINES**

Defined generics/parameters allow customizing bit-width, LUT depth, clock frequency, etc.
Verify resource usage (LUTs, BRAM, DSP blocks) based on target FPGA.
Consider adding an output reconstruction filter post-DAC to suppress Nyquist images.

**GETTING STARTED**

- Clone this repository
- Choose your HDL (/vhdl/ or /verilog/)
- Modify parameters as needed (accumulator width, LUT size, clock rate)
- Run the simulation and examine the output waveforms
- Synthesize and implement on your target FPGA

**SUMMARY**

This project provides a ready-to-use and parameterizable DDFS core, ideal for FPGA-based DDS applications, from signal generation to communications. It’s modular, test-driven, and optimized for high spectral purity using LUT-based waveform synthesis and phase rotation techniques.

**CONTACT AND SUPPORT**

Developed by **AMITOJ SINGH**

Email: 2022eeb1295@iitrpr.ac.in

Feel free to open issues, request features, or submit pull requests!
