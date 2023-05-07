// レジスタファイル 分散RAM（同期書き込み，非同期読み出し）
`ifndef REG_FILE_V
`define REG_FILE_V
`include "def.v"
`default_nettype none

module reg_file (
    input wire [`RF_ADDR_W-1:0] r1_addr,
    input wire [`RF_ADDR_W-1:0] r2_addr,
    input wire [`RF_ADDR_W-1:0] w_addr,
    input wire [`DATA_W-1:0] w_data,
    input wire we,
    input wire clock,
    input wire n_rst,
    output wire [`DATA_W-1:0] r1_data,
    output wire [`DATA_W-1:0] r2_data
);

    // 内部信号
    reg [`DATA_W-1:0] regs[0:`RF_REG-1];  // DATA_Wビット幅のレジスタをRF_REG個宣言

    // 機能記述
    // 順序回路（書き込み）
    always @(posedge clock or negedge n_rst) begin
        // ゼロレジスタのみ初期化
        if (!n_rst) begin
            regs[`RF_ZERO] <= `DATA_W'b0;
        end
        // 書き込みが有効かつ書き込み先がゼロレジスタでない場合，書き込み
        if (we && (w_addr != `RF_ZERO)) begin
            regs[w_addr] <= w_data;
        end
    end

    // 組み合わせ回路（読み出し）（書き込みデータ即反映）
    assign r1_data = regs[r1_addr];
    assign r2_data = regs[r2_addr];

endmodule

`endif
