// プログラムカウンタモジュール
`ifndef PC_V
`define PC_V
`include "def.v"
`default_nettype none

module pc (
    input wire [`DATA_W-1:0] imm,
    input wire [`DATA_W-1:0] rs,
    input wire [`PC_IMR_SEL_W-1:0] imr_sel,
    input wire bre,
    input wire clock,
    input wire n_rst,
    output reg [`DATA_W-1:0] out
);

    // 機能記述
    // 順序回路
    always @(posedge clock or negedge n_rst) begin
        if (!n_rst) begin
            out <= `DATA_W'b0;
        end else if (bre) begin  // 分岐有効の場合
            out <= (imr_sel == `PC_REG) ? rs : out + imm + `DATA_W'b1;
        end else begin
            out <= out + `DATA_W'b1;  // 分岐無効の場合PC + 1 
        end
    end

endmodule

`endif
