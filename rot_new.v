module MBRT_ROT (
    input  wire        clk,        // clock
    input  wire        rst,        // synchronous reset
    input  wire [2:0]  en,         // enable signals for stages [en0,en1,en2]
    input  wire [8:0]  phi_rot,    // 9-bit rotation word (partitioned into 3 segments)
    input  wire signed [63:0] lut_data,
    output reg  signed [19:0] xs,  // 20-bit signed output X = xc + rotated_offset_x
    output reg  signed [19:0] ys   // 20-bit signed output Y = yc + rotated_offset_y
);

    wire signed [19:0] xc = lut_data[63:44];  // 20-bit signed coarse X (MSB int, rest frac)
    wire signed [19:0] yc = lut_data[43:24];  // 20-bit signed coarse Y
    wire signed [11:0] xp = lut_data[23:12];  // 12-bit signed fine X (to be rotated)
    wire signed [11:0] yp = lut_data[11:0];  // 12-bit signed fine Y


    // Sign-extend 12-bit inputs to 20-bit fixed-point (MSB rep.)
    wire signed [19:0] x0_ext = { 8'b0, xp };
    wire signed [19:0] y0_ext = { 8'b0, yp };

    // Partition phi_rot into three 3-bit signed segments for the stages
    wire signed [2:0] phi0 = phi_rot[2:0];   // stage 0 angle bits
    wire signed [2:0] phi1 = phi_rot[5:3];   // stage 1 angle bits
    wire signed [2:0] phi2 = phi_rot[8:6];   // stage 2 angle bits

    // Pipeline registers for intermediate X,Y values at each stage
    reg signed [19:0] stage1_x, stage1_y;
    reg signed [19:0] stage2_x, stage2_y;
    reg signed [19:0] stage3_x, stage3_y;

    always @(posedge clk) begin
        if (rst) begin
            stage1_x <= 20'b0;
            stage1_y <= 20'b0;
            stage2_x <= 20'b0;
            stage2_y <= 20'b0;
            stage3_x <= 20'b0;
            stage3_y <= 20'b0;
            xs       <= 20'b0;
            ys       <= 20'b0;
        end else begin
            // Stage 0 (first 3-bit rotation)
            if (en[0]) begin
                // Fixed-point multiply-add for rotation: shift right by 3 after multiply
                // dx0 = x0_ext * phi0 / 8; dy0 = y0_ext * phi0 / 8;
                // Then x1 = x0_ext - dy0; y1 = y0_ext + dx0;
                stage1_x <= xc - ( (x0_ext * phi0) >>> 6 );
                stage1_y <= yc + ( (y0_ext * phi0) >>> 6 );
            end else begin
                // Bypass this stage
                stage1_x <= x0_ext;
                stage1_y <= y0_ext;
            end

            // Stage 1 (second 3-bit rotation)
            if (en[1]) begin
                stage2_x <= stage1_x - ( (x0_ext * phi1) >>> 9 );
                stage2_y <= stage1_y + ( (y0_ext * phi1) >>> 9 );
            end else begin
                stage2_x <= stage1_x;
                stage2_y <= stage1_y;
            end

            // Stage 2 (third 3-bit rotation)
            if (en[2]) begin
                stage3_x <= stage2_x - ( (x0_ext * phi2) >>> 12 );
                stage3_y <= stage2_y + ( (y0_ext * phi2) >>> 12 );
            end else begin
                stage3_x <= stage2_x;
                stage3_y <= stage2_y;
            end

            // Final outputs: add coarse (xc,yc) to the rotated offset
            xs <= stage3_x;
            ys <= stage3_y;
        end
    end
endmodule
