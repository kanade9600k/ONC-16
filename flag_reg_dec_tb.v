// フラグレジスタ・デコーダのテストベンチ
`ifndef FLAG_REG_DEC_TB_V
`define FLAG_REG_DEC_TB_V
`default_nettype none
`include "def.v"
`include "flag_reg_dec.v"
`timescale 1ns / 1ns

module flag_reg_dec_tb;

    // 入出力の宣言
    reg [`FR_FLAG_W-1:0] flags_tb;
    reg [`FR_FUNC_W-1:0] func_tb;
    reg de_tb;
    reg clock_tb;
    reg n_rst_tb;
    wire bre_tb;

    // モジュールの宣言
    flag_reg_dec flag_reg_dec_inst (
        .flags(flags_tb),
        .func(func_tb),
        .de(de_tb),
        .clock(clock_tb),
        .n_rst(n_rst_tb),
        .bre(bre_tb)
    );

    // クロック記述
    always #5 clock_tb <= ~clock_tb;

    // テストパターン
    integer i, j;
    initial begin
        clock_tb <= 1'b0;
        n_rst_tb <= 1'b1;
        #2;
        for (i = 0; i < 2 ** `FR_FUNC_W; i = i + 1) begin
            for (j = 0; j < 2 ** `FR_FLAG_W; j = j + 1) begin
                de_tb <= 1'b1;
                func_tb <= i;
                flags_tb <= j;
                #10;
            end
        end
        for (i = 0; i < 2 ** `FR_FUNC_W; i = i + 1) begin
            for (j = 0; j < 2 ** `FR_FLAG_W; j = j + 1) begin
                de_tb <= 1'b0;
                func_tb <= i;
                flags_tb <= j;
                #10;
            end
        end
        n_rst_tb <= 1'b0;
        for (i = 0; i < 2 ** `FR_FUNC_W; i = i + 1) begin
            for (j = 0; j < 2 ** `FR_FLAG_W; j = j + 1) begin
                de_tb <= 1'b1;
                func_tb <= i;
                flags_tb <= j;
                #10;
            end
        end
        n_rst_tb <= 1'b1;
        for (i = 0; i < 2 ** `FR_FUNC_W; i = i + 1) begin
            for (j = 0; j < 2 ** `FR_FLAG_W; j = j + 1) begin
                de_tb <= 1'b1;
                func_tb <= i;
                flags_tb <= j;
                #10;
            end
        end
        $finish;
    end

    initial begin
        $dumpfile("flag_reg_dec.vcd");
        $dumpvars(0);
    end

endmodule
`endif
