module phase_accumulator_16bit_pipelined(
    input wire clk,
    input wire rst,
    input wire [31:0] FCW,
    output reg [31:0] phase
);

    wire [15:0] FCW_lower = FCW[15:0];
    wire [15:0] FCW_upper = FCW[31:16];

    reg [15:0] phase_lower;
    reg [15:0] phase_upper;

    wire carry;

    always @(posedge clk or posedge rst) begin
        if (rst)
            phase_lower <= 16'b0;
        else
            phase_lower <= phase_lower + FCW_lower;
    end

    assign carry = (phase_lower + FCW_lower < phase_lower) ? 1'b1 : 1'b0;

    always @(posedge clk or posedge rst) begin
        if (rst)
            phase_upper <= 16'b0;
        else
            phase_upper <= phase_upper + FCW_upper + carry;
            phase <= {phase_upper, phase_lower};
    end

endmodule