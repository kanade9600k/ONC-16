// デュアルポートRAM
`ifndef DPRAM_V
`define DPRAM_V
`default_nettype none

module dpram #(
    parameter D_WIDTH = 16,
    parameter A_WIDTH = 12,
    parameter WORDS   = 4096
) (
    input wire clock,
    input wire [A_WIDTH-1:0] addr1,
    input wire [A_WIDTH-1:0] addr2,
    input wire [D_WIDTH-1:0] din1,
    input wire [D_WIDTH-1:0] din2,
    input wire we1,
    input wire we2,
    output reg [D_WIDTH-1:0] dout1,
    output reg [D_WIDTH-1:0] dout2
);

    // 内部メモリ
    reg [D_WIDTH-1:0] ram[0:WORDS-1];

    // 読み出し優先
    always @(posedge clock) begin
        if (we1) begin
            ram[addr1] <= din1;
        end
        dout1 <= ram[addr1];
    end

    always @(posedge clock) begin
        if (we2) begin
            ram[addr2] <= din2;
        end
        dout2 <= ram[addr2];
    end


endmodule

`endif
