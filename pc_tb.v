// プログラムカウンタモジュールのテストベンチ
`ifndef PC_TB_V
`define PC_TB_V
`default_nettype none
`include "def.v"
`include "pc.v"
`timescale 1ns / 1ns

module pc_tb;

    // 入出力の宣言
    reg [`DATA_W-1:0] imm_tb;
    reg [`DATA_W-1:0] rs_tb;
    reg [`PC_IMR_SEL_W-1:0] imr_sel_tb;
    reg bre_tb;
    reg clock_tb;
    reg n_rst_tb;
    wire [`DATA_W-1:0] out_tb;

    // verilog_format: off モジュールの宣言
    pc pc_inst(.imm(imm_tb), .rs(rs_tb), .imr_sel(imr_sel_tb), .bre(bre_tb), .clock(clock_tb), .n_rst(n_rst_tb), .out(out_tb));
    // verilog_format: on

    // クロック記述
    always #5 clock_tb <= ~clock_tb;

    // テストパターン
    initial begin
        clock_tb <= 1'b0;
        n_rst_tb <= 1'b0;
        imm_tb <= `DATA_W'b0;
        rs_tb <= `DATA_W'b0;
        #2;
        n_rst_tb <= 1'b1;
        // カウントアップの確認
        imr_sel_tb <= `PC_IMR_SEL_W'b0;
        bre_tb <= 1'b0;
        #1000;
        imr_sel_tb <= `PC_IMR_SEL_W'b1;
        bre_tb <= 1'b0;
        #1000;
        // PC相対アドレッシング（イミディエイト）の確認
        imm_tb <= `DATA_W'h0080;
        imr_sel_tb <= `PC_IMR_SEL_W'b0;
        bre_tb <= 1'b1;
        #10;
        imr_sel_tb <= `PC_IMR_SEL_W'b0;
        bre_tb <= 1'b0;
        #100;
        imm_tb <= `DATA_W'hFFF0;  // -16
        imr_sel_tb <= `PC_IMR_SEL_W'b0;
        bre_tb <= 1'b1;
        #10;
        imr_sel_tb <= `PC_IMR_SEL_W'b0;
        bre_tb <= 1'b0;
        #100;
        // レジスタ絶対アドレッシングの確認
        rs_tb <= `DATA_W'h8000;
        imr_sel_tb <= `PC_IMR_SEL_W'b1;
        bre_tb <= 1'b1;
        #10;
        imr_sel_tb <= `PC_IMR_SEL_W'b1;
        bre_tb <= 1'b0;
        #100;
        rs_tb <= `DATA_W'hFFFF;
        imr_sel_tb <= `PC_IMR_SEL_W'b1;
        bre_tb <= 1'b1;
        #10;
        imr_sel_tb <= `PC_IMR_SEL_W'b1;
        bre_tb <= 1'b0;
        #100;
        n_rst_tb <= 1'b0;
        #10;
        n_rst_tb <= 1'b1;
        #100;
        $finish;
    end

    initial begin
        $dumpfile("pc.vcd");
        $dumpvars(0);
    end

endmodule

`endif
