// レジスタファイル 分散RAM（同期書き込み，非同期読み出し）
`ifndef REG_FILE_TB_V
`define REG_FILE_TB_V
`default_nettype none
`include "def.v"
`include "reg_file.v"
`timescale 1ns / 1ns

module reg_file_tb;

    // 入出力の宣言
    reg [`RF_ADDR_W-1:0] r1_addr_tb;
    reg [`RF_ADDR_W-1:0] r2_addr_tb;
    reg [`RF_ADDR_W-1:0] w_addr_tb;
    reg [`DATA_W-1:0] w_data_tb;
    reg we_tb;
    reg clock_tb;
    reg n_rst_tb;
    wire [`DATA_W-1:0] r1_data_tb;
    wire [`DATA_W-1:0] r2_data_tb;

    // verilog_format: off モジュールの宣言
    reg_file reg_file_inst(.r1_addr(r1_addr_tb), .r2_addr(r2_addr_tb), .w_addr(w_addr_tb), .w_data(w_data_tb), .we(we_tb), .clock(clock_tb), .n_rst(n_rst_tb), .r1_data(r1_data_tb), .r2_data(r2_data_tb));
    // verilog_format: on

    // クロック記述
    always #10 clock_tb <= ~clock_tb;

    // テストパターン
    integer i, j, k;
    initial begin
        clock_tb <= 1'b0;
        n_rst_tb <= 1'b0;
        #2;
        n_rst_tb <= 1'b1;
        // weの確認
        for (i = 0; i < 2 ** `RF_ADDR_W; i = i + 1) begin
            for (j = 0; j < 2 ** `RF_ADDR_W; j = j + 1) begin
                for (k = 0; k < 2 ** `RF_ADDR_W; k = k + 1) begin
                    we_tb <= 1'b0;
                    w_addr_tb <= i;
                    r1_addr_tb <= j;
                    r2_addr_tb <= k;
                    w_data_tb <= `DATA_W'hFFFF;
                    #2;
                end
            end
        end
        // 書き込みの確認
        for (i = 0; i < 2 ** `RF_ADDR_W; i = i + 1) begin
            for (j = 0; j < 2 ** `RF_ADDR_W; j = j + 1) begin
                for (k = 0; k < 2 ** `RF_ADDR_W; k = k + 1) begin
                    we_tb <= 1'b1;
                    w_addr_tb <= i;
                    r1_addr_tb <= j;
                    r2_addr_tb <= k;
                    w_data_tb <= `DATA_W'hFFFF;
                    #2;
                end
            end
        end
        // 読み出し中に書き込みが起こった場合の確認
        we_tb <= 1'b1;
        w_addr_tb <= `RF_ADDR_W'h8;
        w_data_tb <= `DATA_W'h8000;
        r1_addr_tb <= `RF_ADDR_W'h8;
        #10;
        w_data_tb <= `DATA_W'h0008;
        #20;
        $finish;
    end

    initial begin
        $dumpfile("reg_file.vcd");
        $dumpvars(0);
    end

endmodule

`endif
