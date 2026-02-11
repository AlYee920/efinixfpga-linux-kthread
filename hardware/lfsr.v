// Code your design here
module lfsr #(
    parameter WIDTH = 16,
    parameter [WIDTH-1:0] POLY_N = 16'hB400,
    parameter [WIDTH-1:0] SEED = 16'hACE1
)(
    input  wire             clk,
    input  wire             rstn,
    input  wire             lfsr_enable,
    output reg  [WIDTH-1:0] lfsr_out,
    output reg  [WIDTH-1:0] lfsr_out_r,
    output wire             lfsr_bit
);

    wire [WIDTH-1:0] lfsr_next;
    
    assign lfsr_bit = lfsr_out[0];
    
    // Galois LFSR: XOR feedback with polynomial taps
    genvar i;
    generate
        for (i = 0; i < WIDTH-1; i = i + 1) begin : lfsr_xor
            assign lfsr_next[i] = lfsr_out[i+1] ^ (POLY_N[i] & lfsr_out[0]);
        end
    endgenerate
    
    assign lfsr_next[WIDTH-1] = lfsr_out[0];
    
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            lfsr_out <= SEED;
            lfsr_out_r <= SEED;
        end else if (lfsr_enable) begin
            lfsr_out <= lfsr_next;
            lfsr_out_r <= lfsr_out;
        end
    end
endmodule