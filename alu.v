// ALU
`ifndef ALU_V
`define ALU_V
`include "def.v"
`default_nettype none

module alu (
    input wire [`DATA_W-1:0] a,
    input wire [`DATA_W-1:0] b,
    input wire [`ALU_FUNC_W-1:0] func,  // N, Z, C, V
    output wire [`DATA_W-1:0] y,
    output wire [`FR_FLAG_W-1:0] flags
);

    // 内部信号（reg型だが，always @(*) なので組み合わせ回路が生成される）
    reg [`DATA_W-1:0] tmp_y;
    reg [`DATA_W-1:0] tmp_flags;

    // 機能記述
    // funcによって機能を分岐（組み合わせ回路）
    always @(*) begin
        case (func)
            `ALU_ADD: {tmp_flags[`C_FLAG], tmp_y} <= a + b;
            `ALU_SUB: {tmp_flags[`C_FLAG], tmp_y} <= a - b;
            `ALU_TH:  tmp_y <= b;
            `ALU_NOT: tmp_y <= ~b;
            `ALU_AND: tmp_y <= a & b;
            `ALU_OR:  tmp_y <= a | b;
            `ALU_XOR: tmp_y <= a ^ b;
            // シフトは最後のあふれがキャリー，桁あふれを保持するため1bit拡張して演算
            `ALU_SRA: {tmp_y, tmp_flags[`C_FLAG]} <= ($signed({a, 1'b0}) >>> b);
            `ALU_SRL: {tmp_y, tmp_flags[`C_FLAG]} <= ({a, 1'b0}) >> b;
            `ALU_SLL: {tmp_flags[`C_FLAG], tmp_y} <= ({1'b0, a}) << b;
            default: begin
                tmp_y <= `DATA_W'bx;
                tmp_flags <= `FR_FLAG_W'b0;
            end
        endcase
    end

    // 出力割当て
    assign y = tmp_y;
    assign flags[`N_FLAG] = y[`DATA_W-1];  // ネガティブフラグ
    assign flags[`Z_FLAG] = ~(|y);  // ゼロフラグ
    assign flags[`C_FLAG] = tmp_flags[`C_FLAG];  // キャリーフラグ
    assign flags[`V_FLAG] = (  // オーバーフローフラグ，同符号同士の加算結果が異符号，正-負の結果が負，負-正の結果が正の場合1
        ((func == `ALU_ADD) && ((!a[`DATA_W-1] && !b[`DATA_W-1] && y[`DATA_W-1]) || (a[`DATA_W-1] && b[`DATA_W-1] && !y[`DATA_W-1])))
     || ((func == `ALU_SUB) && ((!a[`DATA_W-1] && b[`DATA_W-1] && y[`DATA_W-1]) || (a[`DATA_W-1] && !b[`DATA_W-1] && !y[`DATA_W-1]))));


endmodule

`endif
