`timescale 1ns / 1ns

module PT_tb;

    parameter n = 17;
    parameter l = 6;

    reg [31:0] PA_out;

    wire [2:0]  phi_r;
    wire [l-1:0] phi_lut;
    wire [n-4-l:0] phi_rot;

    PT #(n, l) uut (
        .PA_out(PA_out),
        .phi_r(phi_r),
        .phi_lut(phi_lut),
        .phi_rot(phi_rot)
    );

    initial begin
        $display("Time\t\tPA_out\t\t\tphi_r\tphi_lut\tphi_rot");

        PA_out = 32'b1000_0000_0000_0000_0000_0000_0000_0000;
        #10;
        $display("%0t\t%b\t%b\t%b\t%b", $time, PA_out, phi_r, phi_lut, phi_rot);

        PA_out = 32'b1110_0000_0000_0000_0000_0000_0000_0000;
        #10;
        $display("%0t\t%b\t%b\t%b\t%b", $time, PA_out, phi_r, phi_lut, phi_rot);

        PA_out = 32'hABCD_1234;
        #10;
        $display("%0t\t%b\t%b\t%b\t%b", $time, PA_out, phi_r, phi_lut, phi_rot);

        PA_out = 32'b0;
        #10;
        $display("%0t\t%b\t%b\t%b\t%b", $time, PA_out, phi_r, phi_lut, phi_rot);

        PA_out = 32'hFFFF_FFFF;
        #10;
        $display("%0t\t%b\t%b\t%b\t%b", $time, PA_out, phi_r, phi_lut, phi_rot);

        $finish;
    end

endmodule
