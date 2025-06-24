module conf_block (
    input              clk,
    input              rst,
    input      [1:0]   mode,
    output reg         LM,    // LUT mode: 1=LUT1, 0=LUT0
    output reg [2:0]   en,    // rotation block enables (en2,en1,en0)
    output reg [3:0]   L,     // number of MSBs for LUT (phi_lut bits)
    output reg [3:0]   R      // number of LSBs for rotation (phi_rot bits)
);
    // Decode mode into new control signals (before pipelining)
    reg new_LM;
    reg [2:0] new_en;
    reg [3:0] new_L, new_R;
    always @(*) begin
        case (mode)
            2'b00: begin new_LM = 1'b1; new_en = 3'b000; new_L = 4'd6; new_R = 4'd9; end
            2'b01: begin new_LM = 1'b1; new_en = 3'b001; new_L = 4'd6; new_R = 4'd9; end
            2'b10: begin new_LM = 1'b1; new_en = 3'b011; new_L = 4'd6; new_R = 4'd9; end
            2'b11: begin new_LM = 1'b1; new_en = 3'b111; new_L = 4'd6; new_R = 4'd9; end
            default: begin new_LM = 1'b1; new_en = 3'b000; new_L = 4'd9; new_R = 4'd0; end
        endcase
    end

    // Pipeline registers (3-cycle delay) for control signals
    reg LM_d0, LM_d1;
    reg [2:0] en_d0, en_d1;
    reg [3:0] L_d0, L_d1;
    reg [3:0] R_d0, R_d1;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // On reset, clear all registers and outputs
            LM     <= 1'b0;
            en     <= 3'b000;
            L      <= 4'd0;
            R      <= 4'd0;
            LM_d0  <= 1'b0; LM_d1 <= 1'b0;
            en_d0  <= 3'b000; en_d1 <= 3'b000;
            L_d0   <= 4'd0;   L_d1   <= 4'd0;
            R_d0   <= 4'd0;   R_d1   <= 4'd0;
        end else begin
            // Stage 1: capture new config
            LM_d0  <= new_LM;
            en_d0  <= new_en;
            L_d0   <= new_L;
            R_d0   <= new_R;
            // Stage 2
            LM_d1  <= LM_d0;
            en_d1  <= en_d0;
            L_d1   <= L_d0;
            R_d1   <= R_d0;
            // Stage 3: output registers (final delayed signals)
            LM     <= LM_d1;
            en     <= en_d1;
            L      <= L_d1;
            R      <= R_d1;
        end
    end
endmodule
