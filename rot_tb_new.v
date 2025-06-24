`timescale 1ns/1ps
module MBRT_ROT_tb;
  // Clock and reset
  reg clk;
  reg reset;

  // Inputs to MBRT_ROT
  reg signed [19:0] xc, yc;   // 20-bit signed (coarse LUT amplitude)
  reg signed [11:0] xp, yp;   // 12-bit signed (fine rotation increments)
  reg [8:0] phi_rot;          // 9-bit rotation angle (3x3-bit segments)
  reg [2:0] en;              // 3-bit enable for each rotation block

  // Outputs from MBRT_ROT
  wire signed [19:0] xs, ys;  // 20-bit signed outputs

  // Instantiate the DUT (assumed available)
  MBRT_ROT dut (
    .clk(clk),
    .reset(reset),
    .xc(xc), .yc(yc),
    .xp(xp), .yp(yp),
    .phi_rot(phi_rot),
    .en(en),
    .xs(xs), .ys(ys)
  );

  // Clock generation: 1 GHz => 1 ns period, so toggle every 0.5 ns
  initial begin
    clk = 0;
    forever #0.5 clk = ~clk;
  end

  // Main stimulus and dumping
  initial begin
    // Initialize dump for waveform inspection
    $dumpfile("MBRT_ROT_tb.vcd");
    $dumpvars(0, MBRT_ROT_tb);
    $display("Starting MBRT_ROT test...");

    // Apply reset
    reset = 1;
    #5;
    reset = 0;
    #5;

    // Base coordinate (from LUT) - use 0 for simplicity
    xc = 20'sd0;
    yc = 20'sd0;

    // Test different en configurations
    // Example fixed-point values: 0.5 => 0.5*(2^11)=1024, -0.25 => -0.25*(2^11)=-512
    xp = 12'sd1024;  // +0.5 in Q1.11 format
    yp = 12'sd512;  // -0.25 in Q1.11 format

    // Loop over all en = 000 to 111
    integer i;
    for (i = 0; i < 8; i = i+1) begin
      en = i[2:0];
      // Select a phi_rot for test: e.g., small fractional angles in each block
      case (en)
        3'b000: phi_rot = 9'b000_000_000; // no rotation (all blocks off)
        3'b001: phi_rot = 9'b000_000_100; // only block1: ~0.78°
        3'b010: phi_rot = 9'b000_001_000; // only block2: ~1.6°
        3'b011: phi_rot = 9'b000_001_100; // block1+2: ~2.3°
        3'b100: phi_rot = 9'b001_000_000; // only block3: ~45°
        3'b101: phi_rot = 9'b001_000_100; // block1+3
        3'b110: phi_rot = 9'b001_001_000; // block2+3
        3'b111: phi_rot = 9'b001_001_100; // block1+2+3: combined ~47°
        default: phi_rot = 9'b000_000_000;
      endcase

      // Wait a short time for outputs to settle (assuming pipelined/mux logic)
      #2;

      // Display test configuration and results
      $display("en=%b, xp=%0d, yp=%0d, phi_rot=%b => xs=%0d, ys=%0d", 
               en, xp, yp, phi_rot, $signed(xs), $signed(ys));
      // Expected values (approximate):
      //  - For en=000 (no rotation): xs = xc = 0, ys = yc = 0.
      //  - For small phi: use x'=x*cos - y*sin, y'=x*sin + y*cos (adding xc,yc).
      //  E.g. xp=0.5, yp=-0.25, phi≈45° (0b001_000_000): 
      //    cos(45°)=0.707 => x'≈0.5*0.707 - (-0.25)*0.707 = 0.53, y'≈0.5*0.707 + (-0.25)*0.707 = 0.177.
      //  The DUT outputs xs, ys in fixed-point; compare to these hand-computed values.
    end

    $display("Test complete.");
    $finish;
  end

endmodule
