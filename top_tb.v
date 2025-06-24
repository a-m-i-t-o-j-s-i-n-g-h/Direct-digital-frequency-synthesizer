`timescale 1ps/1ps

module testbench;
  // Clock and reset
  reg               clk, rst;
  // DDS inputs
  reg       [31:0]  FCW;
  reg        [1:0]  mode;
  // DDS outputs
  wire signed [19:0] sin_out, cos_out;

  // Instantiate the DDFS top module
  top uut (
    .clk     (clk),
    .rst     (rst),
    .FCW     (FCW),
    .mode    (mode),
    .sin_out (sin_out),
    .cos_out (cos_out)
  );

  integer out_file;

  // 800 MHz clock → period = 1.25 ns → half-period = 0.625 ns
  initial begin
    clk = 0;
    forever #625 clk = ~clk;
  end

  initial begin
    // initialize & open file
    rst      = 1;
    mode     = 2'b11;
    FCW      = 32'h12345678;   
    out_file = $fopen("output.txt", "w");

    // hold reset for 2 half-cycles (1.25 ns)
    #1250;
    rst = 0;

    // run for 100 full cycles → 100 × 1.25 ns = 125 ns
    #125000;

    // finish up
    $fclose(out_file);
    $finish;
  end

  // Log on every clock edge
  always @(posedge clk) begin
    $display("%0t ps: sin=%b, cos=%b", $time, sin_out, cos_out);
    $fdisplay(out_file, "%0t, %b, %b", $time, sin_out, cos_out);
  end
endmodule
