// プログラムカウンタモジュール
`ifndef PC_V
`define PC_V
`include "def.v"
`default_nettype none

module pc (
    input wire [`DATA_W-1:0] imm,
    input wire [`DATA_W-1:0] rs,
    input wire [`PC_IMR_SEL_W-1:0] imr_sel,
    input wire [`PC_BR_SEL_W-1:0] br_sel,
    input wire clock,
    input wire n_rst,
    output reg [`DATA_W-1:0] out
);

    // 内部信号
    wire [`DATA_W-1:0] w_inc_pc, w_inc_pc_imm, w_imr, w_br;

    // 機能記述
    // 順序回路
    always @(posedge clock or negedge n_rst) begin
        if (!n_rst) begin
            out <= `DATA_W'b0;
        end else if (br_sel) begin  // 分岐有効の場合
            out <= (imr_sel) ? rs : out + imm + `DATA_W'b1;  // 0: 相対アドレッシング，1: 絶対アドレッシング
        end else begin
            out <= out + `DATA_W'b1;  // 分岐無効の場合PC + 1 
        end
    end

endmodule

`endif
