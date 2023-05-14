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
    reg tmp_c_flag;

    // verilog_format: off 機能記述
    // funcによって機能を分岐（組み合わせ回路）
    always @(*) begin
        case (func)
            `ALU_ADD: begin {tmp_c_flag, tmp_y} <= a + b; end
            `ALU_SUB: begin {tmp_c_flag, tmp_y} <= a - b; end
            `ALU_TH:  begin tmp_y <= b;     tmp_c_flag <= 1'b0; end
            `ALU_NOT: begin tmp_y <= ~b;    tmp_c_flag <= 1'b0; end
            `ALU_AND: begin tmp_y <= a & b; tmp_c_flag <= 1'b0; end
            `ALU_OR:  begin tmp_y <= a | b; tmp_c_flag <= 1'b0; end
            `ALU_XOR: begin tmp_y <= a ^ b; tmp_c_flag <= 1'b0; end
            // シフトは最後のあふれがキャリー，桁あふれを保持するため1bit拡張して演算
            `ALU_SRA: begin {tmp_y, tmp_c_flag} <= ($signed({a, 1'b0}) >>> b); end
            `ALU_SRL: begin {tmp_y, tmp_c_flag} <= ({a, 1'b0}) >> b; end
            `ALU_SLL: begin {tmp_c_flag, tmp_y} <= ({1'b0, a}) << b; end
            default:  begin tmp_y <= `DATA_W'bx; tmp_c_flag <= 1'bx; end
        endcase
    end

    // 出力割当て
    assign y = tmp_y;
    assign flags[`N_FLAG] = y[`DATA_W-1];  // ネガティブフラグ
    assign flags[`Z_FLAG] = ~(|y);  // ゼロフラグ
    assign flags[`C_FLAG] = tmp_c_flag;  // キャリーフラグ
    assign flags[`V_FLAG] = (  // オーバーフローフラグ，同符号同士の加算結果が異符号，正-負の結果が負，負-正の結果が正の場合1
        ((func == `ALU_ADD) && ((!a[`DATA_W-1] && !b[`DATA_W-1] && y[`DATA_W-1]) || (a[`DATA_W-1] && b[`DATA_W-1] && !y[`DATA_W-1])))
     || ((func == `ALU_SUB) && ((!a[`DATA_W-1] && b[`DATA_W-1] && y[`DATA_W-1]) || (a[`DATA_W-1] && !b[`DATA_W-1] && !y[`DATA_W-1]))));


endmodule

`endif
