// ALU

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
            `ALU_ADD: {tmp_flags[1], tmp_y} <= a + b;
            `ALU_SUB: {tmp_flags[1], tmp_y} <= a - b;
            `ALU_TH:  tmp_y <= b;
            `ALU_NOT: tmp_y <= ~b;
            `ALU_AND: tmp_y <= a & b;
            `ALU_OR:  tmp_y <= a | b;
            `ALU_XOR: tmp_y <= a ^ b;
            `ALU_SRA: {tmp_y, tmp_flags[1]} <= ($signed(a) >>> b);  // シフトは最後のあふれがキャリー
            `ALU_SRL: {tmp_y, tmp_flags[1]} <= a >> b;
            `ALU_SLL: {tmp_flags[1], tmp_y} <= a << b;
            default: begin
                tmp_y <= `DATA_W'bx;
                tmp_flags <= `FR_FLAG_W'b0;
            end
        endcase
    end

    // 出力割当て
    assign y = tmp_y;
    assign flags[3] = y[`DATA_W-1];  // ネガティブフラグ
    assign flags[2] = ~(&y);  // ゼロフラグ
    assign flags[1] = tmp_flags[1];  // キャリーフラグ
    assign flags[0] = (  // オーバーフローフラグ，同符号同士の加算結果が異符号，正-負の結果が負，負-正の結果が正の場合1
        (func[`ALU_FUNC_W-1:0] == `ALU_ADD) & ((~a[`DATA_W-1] & ~b[`DATA_W-1] & y[`DATA_W-1]) | (a[`DATA_W-1] & b[`DATA_W-1] & ~y[`DATA_W]))
    | ((func[`ALU_FUNC_W-1:0] == `ALU_SUB) & (~a[`DATA_W-1] & b[`DATA_W-1] & y[`DATA_W-1]) | (a[`DATA_W-1] & ~b[`DATA_W-1] & ~y[`DATA_W-1])));


endmodule
