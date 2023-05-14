// フラグレジスタ・デコーダ
`ifndef FLAG_REG_DEC_V
`define FLAG_REG_DEC_V
`include "def.v"
`default_nettype none

module flag_reg_dec (
    input wire [`FR_FLAG_W-1:0] flags,
    input wire [`FR_FUNC_W-1:0] func,
    input wire de,
    input wire clock,
    input wire n_rst,
    output wire bre
);

    // 内部信号
    reg [`FR_FLAG_W-1:0] flag_reg;
    reg tmp_dec;  //（reg型だが，always @(*) なので組み合わせ回路が生成される）

    // 機能記述
    // 順序回路（レジスタ部分）
    always @(posedge clock or negedge n_rst) begin
        if (!n_rst) begin
            flag_reg <= `FR_FLAG_W'b0;
        end else begin
            flag_reg <= flags;
        end
    end

    // 組み合わせ回路（デコーダ部分）
    always @(*) begin
        case (func)
            `FR_BAL: tmp_dec <= 1'b1;  // 常に分岐
            `FR_BEQ: tmp_dec <= flag_reg[`Z_FLAG];  // Z = 1で分岐
            `FR_BNE: tmp_dec <= !flag_reg[`Z_FLAG];  // Z = 0で分岐
            `FR_BLT: tmp_dec <= (!flag_reg[`N_FLAG] == flag_reg[`V_FLAG]);  // !N = Vで分岐
            `FR_BGE: tmp_dec <= (flag_reg[`N_FLAG] == flag_reg[`V_FLAG]);  // N = Vで分岐
            `FR_BLTU_BC: tmp_dec <= flag_reg[`C_FLAG];  // C = 1で分岐
            `FR_BGEU_BNC: tmp_dec <= !flag_reg[`C_FLAG];  // C = 0で分岐
            `FR_BVF: tmp_dec <= flag_reg[`V_FLAG];  // V = 1で分岐
            default: tmp_dec <= 1'b0;
        endcase
    end
    assign bre = tmp_dec & de;

endmodule
`endif
