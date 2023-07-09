// UART受信回路のテストベンチ
`ifndef UART_RX_TB_V
`define UART_RX_TB_V
`default_nettype none
`include "uart_rx.v"
`timescale 1ns / 1ns

module uart_rx_tb;
    parameter UART_PERIOD = 4340;

    // 入出力の宣言
    reg clock_50M_tb;
    reg n_rst_tb;
    reg rx_tb;
    wire ready_tb;
    wire [7:0] rx_data_tb;

    // モジュールの宣言
    uart_rx uart_rx_inst (
        .clock_50M(clock_50M_tb),
        .n_rst(n_rst_tb),
        .rx(rx_tb),
        .ready(ready_tb),
        .rx_data(rx_data_tb)
    );

    // クロック記述
    always #5 clock_50M_tb <= ~clock_50M_tb;

    // テストパターン
    initial begin
        clock_50M_tb <= 1'b0;
        n_rst_tb <= 1'b0;
        rx_tb <= 1'b1;
        #2;
        n_rst_tb <= 1'b1;
        #10;
        rx_tb <= 1'b0;
        #10000;
        rx_tb <= 1'b1;
        #200000;
        rx_tb <= 1'b0;
        #(UART_PERIOD);
        rx_tb <= 1'b1;
        #(UART_PERIOD);
        rx_tb <= 1'b0;
        #(UART_PERIOD);
        rx_tb <= 1'b1;
        #(UART_PERIOD);
        rx_tb <= 1'b0;
        #(UART_PERIOD);
        rx_tb <= 1'b1;
        #(UART_PERIOD);
        rx_tb <= 1'b0;
        #(UART_PERIOD);
        rx_tb <= 1'b1;
        #(UART_PERIOD);
        rx_tb <= 1'b0;
        #(UART_PERIOD);
        rx_tb <= 1'b1;
        #100000;
        rx_tb <= 1'b0;
        #(UART_PERIOD);
        rx_tb <= 1'b0;
        #(UART_PERIOD);
        rx_tb <= 1'b1;
        #(UART_PERIOD);
        rx_tb <= 1'b0;
        #(UART_PERIOD);
        rx_tb <= 1'b1;
        #(UART_PERIOD);
        rx_tb <= 1'b0;
        #(UART_PERIOD);
        rx_tb <= 1'b1;
        #(UART_PERIOD);
        rx_tb <= 1'b0;
        #(UART_PERIOD);
        rx_tb <= 1'b1;
        #100000;
        $finish;
    end

    initial begin
        $dumpfile("uart_rx.vcd");
        $dumpvars(0);
    end

endmodule

`endif
