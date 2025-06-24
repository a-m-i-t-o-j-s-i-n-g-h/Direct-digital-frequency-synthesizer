module top (
    input  wire         clk,          // system clock
    input  wire         rst,          // synchronous reset
    input  wire [31:0]  FCW,          // 32-bit frequency control word
    input  wire [1:0]   mode,         // 2-bit mode select (LUT/ROT configuration)
    output wire signed [19:0] sin_out, // 20-bit sine output (Aφ)
    output wire signed [19:0] cos_out  // 20-bit cosine output (Aφ)
);

// Internal phase accumulator output
wire [31:0] phase;          // full 32-bit phase from PA

// Phase transformation outputs
wire [2:0] phi_r;           // 3-bit quadrant indicator from PT
wire [5:0] phi_lut;         // 6-bit address for LUT (phi_lut bits)
wire [8:0] phi_rot;         // 9-bit rotation word (phi_rot bits)

// LUT output
wire [63:0] lut_data;       // 64-bit packed sine/cosine data from LUT

// Rotation block outputs
wire signed [19:0] xs;      // 20-bit rotated sine (coarse + offset)
wire signed [19:0] ys;      // 20-bit rotated cosine (coarse + offset)

// Configuration signals
wire        LM;            // LUT mode select (1=LUT1, 0=LUT0)
wire [2:0]  en;            // enable signals for rotation stages [en0, en1, en2]
wire [3:0]  L;             // number of MSBs for LUT (phi_lut width)
wire [3:0]  R;             // number of LSBs for rotation (phi_rot width)

// Instantiate Phase Accumulator (PA)
// Accumulates FCW into 32-bit phase with two 16-bit pipelined accumulators
phase_accumulator_16bit_pipelined PA_inst (
    .clk   (clk),
    .rst   (rst),
    .FCW   (FCW),
    .phase (phase)
);

// Instantiate Configuration block (CONF)
// Decodes mode into control signals for LUT/ROT partitioning
conf_block CONF_inst (
    .clk  (clk),
    .rst  (rst),
    .mode (mode),
    .LM   (LM),
    .en   (en),
    .L    (L),
    .R    (R)
);

// Instantiate Phase Transformation (PT)
// Splits the phase into quadrant bits, LUT index, and rotation index
PT #(
    .n(18),     // total phase bits used (set to L+R+3 = 6+9+3 = 18)
    .l(6)       // LUT address width (number of MSBs for LUT)
) PT_inst (
    .PA_out   (phase),
    .phi_r    (phi_r),
    .phi_lut  (phi_lut),
    .phi_rot  (phi_rot)
);

// Instantiate Look-Up Table (LUT)
// Selects sine/cosine values from ROM based on phi_lut and LM
LUT_ROM LUT_inst (
    .phi_lut  (phi_lut),
    .LM       (LM),
    .lut_data (lut_data)
);

// Instantiate Rotation block (MBRT_ROT)
// Performs micro-rotation on LUT outputs using phi_rot and enable signals en[2:0]
MBRT_ROT ROT_inst (
    .clk      (clk),
    .rst      (rst),
    .en       (en),
    .phi_rot  (phi_rot),
    .lut_data (lut_data),
    .xs       (xs),
    .ys       (ys)
);

// Instantiate Inverse Symmetry (AT_block)
// Maps the rotated outputs (xs, ys) to final sine/cosine outputs (sin_out, cos_out)
// based on the quadrant indicator phi_r
AT_block AT_inst (
    .phi_r   (phi_r),
    .xs      (xs),
    .ys      (ys),
    .sin_out (sin_out),
    .cos_out (cos_out)
);

endmodule
