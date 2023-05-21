// UART送信回路のテストベンチ
`ifndef UART_TX_TB_V
`define UART_TX_TB_V
`default_nettype none
`include "uart_tx.v"
`timescale 1ns / 1ns

module uart_tx_tb;

    //　入出力の宣言
    reg clock_50M_tb;
    reg n_rst_tb;
    reg start_tb;
    reg [7:0] tx_data_tb;
    wire ready_tb;
    wire tx_tb;

    // モジュールの宣言
    uart_tx uart_tx_inst (
        .clock_50M(clock_50M_tb),
        .n_rst(n_rst_tb),
        .start(start_tb),
        .tx_data(tx_data_tb),
        .ready(ready_tb),
        .tx(tx_tb)
    );

    // クロック記述
    always #5 clock_50M_tb <= ~clock_50M_tb;

    // テストパターン
    initial begin
        clock_50M_tb <= 1'b0;
        n_rst_tb <= 1'b0;
        start_tb <= 1'b0;
        tx_data_tb <= 8'b00000000;
        #2;
        n_rst_tb <= 1'b1;
        #10;
        tx_data_tb <= 8'b00110111;
        start_tb   <= 1'b1;
        #20;
        start_tb <= 1'b0;
        #1000;
        start_tb   <= 1'b1;
        tx_data_tb <= 8'b11001100;
        #10;
        start_tb <= 1'b0;
        #100000;
        start_tb <= 1'b1;
        #10;
        start_tb <= 1'b0;
        #100000;
        $finish;
    end

    initial begin
        $dumpfile("uart_tx.vcd");
        $dumpvars(0);
    end

endmodule

`endif

