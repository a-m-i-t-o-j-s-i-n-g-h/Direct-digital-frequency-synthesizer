`timescale 1ns/1ps
module conf_tb;
  reg clk = 0;
  reg reset;
  reg [1:0] mode;
  wire LM;
  wire [2:0] en;
  wire [3:0] L, R;

  // Instantiate the CONF module (DUT)
  CONF dut (
    .clk(clk),
    .reset(reset),
    .mode(mode),
    .LM(LM),
    .en(en),
    .L(L),
    .R(R)
  );

  // Clock generation: 1 GHz clock => 1 ns period
  always #0.5 clk = ~clk;

  initial begin
    // Waveform dump initialization
    $dumpfile("conf_tb.vcd");
    $dumpvars(0, conf_tb);

    // Apply synchronous reset
    reset = 1;
    mode = 2'b00;
    @(posedge clk); // wait 1 clock with reset asserted
    @(posedge clk);
    reset = 0;     // release reset

    // Test Mode = 2'b00
    mode = 2'b00;
    repeat (3) @(posedge clk); // wait 3 cycles
    $display("Mode=00: expected LM=1, en=000, L=9, R=0;  actual LM=%b, en=%03b, L=%0d, R=%0d",
             LM, en, L, R);

    // Test Mode = 2'b01
    mode = 2'b01;
    repeat (3) @(posedge clk);
    $display("Mode=01: expected LM=1, en=001, L=6, R=3;  actual LM=%b, en=%03b, L=%0d, R=%0d",
             LM, en, L, R);

    // Test Mode = 2'b10
    mode = 2'b10;
    repeat (3) @(posedge clk);
    $display("Mode=10: expected LM=0, en=011, L=3, R=6;  actual LM=%b, en=%03b, L=%0d, R=%0d",
             LM, en, L, R);

    // Test Mode = 2'b11
    mode = 2'b11;
    repeat (3) @(posedge clk);
    $display("Mode=11: expected LM=0, en=111, L=0, R=9;  actual LM=%b, en=%03b, L=%0d, R=%0d",
             LM, en, L, R);

    $finish; // End simulation (demonstrated in typical testbench examples:contentReference[oaicite:5]{index=5})
  end
endmodule
