// 周辺回路を含めたトップモジュールのテストベンチ
`ifndef TOP_TB_V
`define TOP_TB_V
`default_nettype none
`include "top.v"
`timescale 1ns / 1ns

module top_tb;

    // 入出力の宣言
    reg clock_tb, n_rst_tb;
    wire TxD_tb, RTS_tb, WAKEUP_tb;

    // モジュールの宣言
    top top_inst (
        .clock(clock_tb),
        .n_rst(n_rst_tb),
        .TxD(TxD_tb),
        .RTS(RTS_tb),
        .WAKEUP(WAKEUP_tb)
    );

    // クロック記述
    always #10 clock_tb <= ~clock_tb;

    // テストパターン
    initial begin
        clock_tb <= 1'b0;
        n_rst_tb <= 1'b0;
        #20;
        n_rst_tb <= 1'b1;
        #4000000;
        $finish;
    end

    initial begin
        $dumpfile("top.vcd");
        $dumpvars(0);
    end

endmodule

`endif
