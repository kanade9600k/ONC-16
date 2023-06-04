// 周辺回路を含めたトップモジュール
`ifndef TOP_V
`define TOP_V
`include "cpu/onc_16.v"
`include "uart_tx.v"
`include "rom.v"
`include "dpram.v"
`include "divider.v"
`default_nettype none

module top (
    input  wire clock,
    input  wire n_rst,
    output wire TxD,
    output wire TxD_test,
    output wire RTS,
    output wire WAKEUP
);
    // 内部パラメータ
    parameter UART_STATUS_ADDR = 12'h800;
    parameter UART_DATA_ADDR = 12'h801;

    // 内部信号定義
    wire clock_100M, clock_50M, clock_25M;
    wire [15:0] w_imem_addr, w_imem_d;
    wire [15:0] w_dmem_addr, w_dmem_din, w_dmem_dout;
    wire w_dmem_we;
    wire w_uart_ready;
    wire [15:0] w_uart_dmem_data;
    reg [11:0] uart_dmem_addr;
    reg uart_start;


    // // 内部クロック生成(IP: PLL)
    // pll pll_inst (
    //     .inclk0(clock),
    //     .c0(clock_100M),
    //     .c1(clock_50M),
    //     .c2(clock_25M)
    // );

    assign clock_100M = clock;
    divider divider_100_to_50 (
        .clock_in(clock),
        .n_rst(n_rst),
        .clock_out(clock_50M)
    );
    divider divider_50_to_25 (
        .clock_in(clock_50M),
        .n_rst(n_rst),
        .clock_out(clock_25M)
    );

    // CPU
    onc_16 onc_16_inst (
        .imem_din(w_imem_d),
        .dmem_din(w_dmem_din),
        .clock(clock_50M),
        .n_rst(n_rst),
        .imem_addr(w_imem_addr),
        .dmem_addr(w_dmem_addr),
        .dmem_dout(w_dmem_dout),
        .dmem_we(w_dmem_we)
    );

    // 命令メモリ
    rom rom_inst (
        .clock(!clock_100M),
        .addr (w_imem_addr),
        .data (w_imem_d)
    );

    // データメモリ
    dpram dpram_inst (
        .clock(clock_100M),
        .addr1(w_dmem_addr[11:0]),
        .din1 (w_dmem_dout),
        .we1  (w_dmem_we),
        .dout1(w_dmem_din),
        .addr2(uart_dmem_addr),
        .din2 ({15'b0, w_uart_ready}),
        .we2  (!is_uart_w_detect),
        .dout2(w_uart_dmem_data)
    );

    reg is_uart_w_detect;
    always @(posedge clock_100M or negedge n_rst) begin
        if (!n_rst) begin
            is_uart_w_detect <= 1'b0;
            uart_start <= 1'b0;
            uart_dmem_addr <= UART_STATUS_ADDR;  // デフォルトはステータスアドレスにアクセス
        end else if (!w_uart_ready) begin  // UART送信確認でフラグ降ろす
            is_uart_w_detect <= 1'b0;
            uart_start <= 1'b0;
            uart_dmem_addr <= UART_STATUS_ADDR;  // デフォルトはステータスアドレスにアクセス
        end else if ((w_dmem_addr[11:0] == UART_DATA_ADDR) && w_dmem_we) begin
            is_uart_w_detect <= 1'b1;  // 書き込み検知
            uart_dmem_addr   <= UART_DATA_ADDR;  // データアドレスにアクセス
        end else if (is_uart_w_detect) begin
            uart_start <= 1'b1;  // UART送信用データの準備完了(送信開始)
        end
    end

    // UART送信モジュール
    uart_tx uart_tx_inst (
        .clock_50M(clock_50M),
        .n_rst(n_rst),
        .start(uart_start),
        .tx_data(w_uart_dmem_data[7:0]),  // 下位8ビットのみ送信する
        .ready(w_uart_ready),  // 最下位ビットがステータス
        .tx(TxD)
    );

    // UART IC 定数割当て
    assign TxD_test = TxD;
    assign RTS = 1'b0;
    assign WAKEUP = 1'b1;

endmodule

`endif
