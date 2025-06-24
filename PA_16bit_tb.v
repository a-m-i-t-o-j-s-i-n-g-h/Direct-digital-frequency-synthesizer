`timescale 1ns / 1ns

module tb_phase_accumulator_16bit_pipelined;

    reg clk;
    reg rst;
    reg [31:0] FCW;
    wire [31:0] phase;

    phase_accumulator_16bit_pipelined uut (
        .clk(clk),
        .rst(rst),
        .FCW(FCW),
        .phase(phase)
    );

    always #5 clk = ~clk;

    always @(posedge clk) begin
        $display("Time: %0t | FCW: 0x%08h | Phase: 0x%08h", $time, FCW, phase);
    end
    
    initial begin
        $dumpfile("phase_accumulator.vcd");
        $dumpvars(0, tb_phase_accumulator_16bit_pipelined);

        clk = 0;
        rst = 1;
        FCW = 32'd0;

        #20;
        rst = 0;

        FCW = 32'h0001_0001;
        #100;

        FCW = 32'h0002_0003;
        #100;

        FCW = 32'hFFFF_FFFF;
        #100;

        $finish;
    end

endmodule
