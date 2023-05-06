// ビット拡張器のテストベンチ
`ifndef EXTENDER_TEST_V
`define EXTENDER_TEST_V
`default_nettype none
`include "def.v"
`include "extender.v"
`timescale 1ns / 1ns

module extender_test;

    // 入出力の宣言
    reg [`IMM_W-1:0] in_tb;
    wire [`DATA_W-1:0] out_z_tb, out_s_tb;

    // verilog_format: off モジュールの宣言
    extender extender_inst (.in(in_tb), .out_z(out_z_tb), .out_s(out_s_tb));
    // verilog_format: on

    // テストパターン
    integer i;
    initial begin
        for (i = 0; i < 2 ** `IMM_W; i = i + 1) begin
            in_tb <= i;
            #10;
        end
        $finish;
    end

    initial begin
        $dumpfile("extender.vcd");
        $dumpvars(0);
    end

endmodule

`endif
