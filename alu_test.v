// ALUのテストベンチ
`ifndef ALU_TEST_V
`define ALU_TEST_V
`default_nettype none
`include "def.v"
`include "alu.v"
`timescale 1ns / 1ns

module alu_test;

    // 入出力の宣言
    reg [`DATA_W-1:0] a_tb;
    reg [`DATA_W-1:0] b_tb;
    reg [`ALU_FUNC_W-1:0] func_tb;
    wire [`DATA_W-1:0] y_tb;
    wire [`FR_FLAG_W-1:0] flags_tb;

    // モジュールの宣言
    alu alu_inst (
        .a(a_tb),
        .b(b_tb),
        .func(func_tb),
        .y(y_tb),
        .flags(flags_tb)
    );


    // テストパターン
    integer i;
    initial begin
        for (i = 0; i < 2 ** `FR_FLAG_W; i = i + 1) begin
            a_tb <= `DATA_W'hEEEE;
            b_tb <= `DATA_W'h000F;
            func_tb <= i;
            #10;
        end
        // 境界チェック
        for (i = 0; i < 2 ** `FR_FLAG_W; i = i + 1) begin
            a_tb <= `DATA_W'hFFFF;
            b_tb <= `DATA_W'h0001;
            func_tb <= i;
            #10;
        end
        for (i = 0; i < 2 ** `FR_FLAG_W; i = i + 1) begin
            a_tb <= `DATA_W'h0001;
            b_tb <= `DATA_W'hFFFF;
            func_tb <= i;
            #10;
        end
        // オーバーフローチェック
        a_tb <= `DATA_W'h7FFF;
        b_tb <= `DATA_W'h0001;
        func_tb <= `ALU_ADD;
        #10;
        a_tb <= `DATA_W'h8000;
        b_tb <= `DATA_W'hFFFF;
        func_tb <= `ALU_ADD;
        #10;
        a_tb <= `DATA_W'h7FFF;
        b_tb <= `DATA_W'hFFFF;
        func_tb <= `ALU_SUB;
        #10;
        a_tb <= `DATA_W'h8000;
        b_tb <= `DATA_W'h0001;
        func_tb <= `ALU_SUB;
        #10;
        // シフトチェック
        for (i = 0; i <= `DATA_W + 1; i = i + 1) begin
            a_tb <= `DATA_W'hF000;
            b_tb <= i;
            func_tb <= `ALU_SLL;
            #10;
        end
        for (i = 0; i <= `DATA_W + 1; i = i + 1) begin
            a_tb <= `DATA_W'hF000;
            b_tb <= i;
            func_tb <= `ALU_SRA;
            #10;
        end
        for (i = 0; i <= `DATA_W + 1; i = i + 1) begin
            a_tb <= `DATA_W'hF000;
            b_tb <= i;
            func_tb <= `ALU_SRL;
            #10;
        end
        // Borrowのチェック
        for (i = 0; i < 2 ** `DATA_W; i = i + 1) begin
            a_tb <= `DATA_W'h8000;
            b_tb <= i;
            func_tb <= `ALU_SUB;
            #10;
        end
        $finish;
    end

    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0);
    end

endmodule
`endif
