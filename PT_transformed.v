module PT #(
    parameter n = 18,
    parameter l = 6
)(
    input  wire [31:0] PA_out,
    output wire [2:0]  phi_r,
    output wire [l-1:0] phi_lut,
    output wire [n-4-l:0] phi_rot
);

    wire [n-1:0] phi;
    assign phi = PA_out[31 -: n];

    wire [n-4:0] phi_s_raw;
    assign phi_r = phi[n-1 -: 3];
    assign phi_s_raw = phi[n-4:0];

    wire [n-4:0] phi_s_transformed;

    assign phi_s_transformed = (phi_r[0] == 1'b0) ? phi_s_raw :  ~phi_s_raw;

    assign phi_lut = phi_s_transformed[n-4 -: l];
    assign phi_rot = phi_s_transformed[n-4-l:0];

endmodule
