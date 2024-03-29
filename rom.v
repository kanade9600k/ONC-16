// ROM
`ifndef ROM_V
`define ROM_V
`default_nettype none

module rom (
    input wire clock,
    input wire [15:0] addr,
    output reg [15:0] data
);
    // 内部信号定義
    reg [15:0] rom[0:65535];

    // 初期値読み込み
    initial begin
        $readmemh("asm/hello_pl.msn", rom);
    end

    always @(posedge clock) begin
        data <= rom[addr];
    end

endmodule

`endif
