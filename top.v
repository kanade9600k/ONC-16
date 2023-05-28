// 周辺回路を含めたトップモジュール
`ifndef TOP_V
`define TOP_V
`include "cpu/onc_16.v"
`include "uart_tx.v"
`include "rom.v"
`include "dpram.v"
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
    wire w_inner_clock;
    wire [15:0] w_imem_addr, w_imem_d;
    wire [15:0] w_dmem_addr, w_dmem_din, w_dmem_dout;
    wire w_dmem_we;
    wire [15:0] w_dmem_uart_d;
    wire w_uart_start, w_uart_ready;
    reg uart_dmem_we;
    reg [11:0] uart_dmem_addr;
    reg uart_start;



    // // 内部クロック生成(IP: PLL)
    // pll pll_inst (
    //     .areset(1'b0),
    //     .inclk0(clock),
    //     .c0(w_inner_clock)
    // );
    assign w_inner_clock = clock;

    // CPU
    onc_16 onc_16_inst (
        .imem_din(w_imem_d),
        .dmem_din(w_dmem_din),
        .clock(w_inner_clock),
        .n_rst(n_rst),
        .imem_addr(w_imem_addr),
        .dmem_addr(w_dmem_addr),
        .dmem_dout(w_dmem_dout),
        .dmem_we(w_dmem_we)
    );

    // 命令メモリ
    rom rom_inst (
        .clock(w_inner_clock),
        .addr (w_imem_addr),
        .data (w_imem_d)
    );

    // データメモリ
    dpram dpram_inst (
        .clock(w_inner_clock),
        .addr1(w_dmem_addr[11:0]),
        .din1 (w_dmem_dout),
        .we1  (w_dmem_we),
        .dout1(w_dmem_din),
        .addr2(uart_dmem_addr),
        .din2 ({15'b0, w_uart_ready}),
        .we2  (uart_dmem_we),
        .dout2(w_dmem_uart_d)
    );

    assign w_uart_start = (w_dmem_addr == UART_DATA_ADDR) && w_dmem_we; // UARTにマップされたアドレスに書き込まれたとき1

    always @(posedge clock) begin
        uart_start <= ((w_dmem_addr == UART_DATA_ADDR) && w_dmem_we) ? 1'b1 : 1'b0;
        uart_dmem_we <= !uart_start;  // UARTがスタートした直後の1クロックだけ0(dmem書き込み禁止)
        uart_dmem_addr <= (!uart_start) ? UART_DATA_ADDR : UART_STATUS_ADDR;
    end

    // UART送信モジュール
    uart_tx uart_tx_inst (
        .clock_50M(w_inner_clock),
        .n_rst(n_rst),
        .start(w_uart_start), // データメモリのUARTに割り当てられた番地に書き込みがあった時に1
        .tx_data(w_dmem_uart_d[7:0]),  // 下位8ビットのみ送信する
        .ready(w_uart_ready),  // 最下位ビットがステータス
        .tx(TxD)
    );

    // UART IC 定数割当て
    assign TxD_test = TxD;
    assign RTS = 1'b0;
    assign WAKEUP = 1'b1;

endmodule

`endif
