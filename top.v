// 周辺回路を含めたトップモジュール
`ifndef TOP_V
`define TOP_V
`include "cpu/onc_16.v"
`include "uart_tx.v"
`include "uart_rx.v"
`include "rom.v"
`include "dpram.v"
`include "divider.v"
`default_nettype none

module top (
    input  wire clock,
    input  wire n_rst,
    input  wire RxD,
    output wire RxD_ex,
    output wire TxD,
    output wire TxD_ex,
    output wire RTS,
    output wire WAKEUP
);
    // 内部パラメータ
    parameter UART_STATUS_ADDR = 12'h800;
    parameter UART_TX_DATA_ADDR = 12'h801;
    parameter UART_RX_DATA_ADDR = 12'h802;

    // 内部信号定義
    wire clock_100M, clock_50M, clock_25M;
    wire [15:0] w_cpu_imem_addr, w_cpu_imem_d;
    wire [15:0] w_cpu_dmem_addr, w_cpu_dmem_din, w_cpu_dmem_dout;
    wire w_cpu_dmem_we;
    wire w_uart_tx_ready, w_uart_rx_ready;
    wire [15:0] w_uart_dmem_dout;
    wire [7:0] w_rx_data;
    reg [15:0] uart_dmem_din;
    reg [11:0] uart_dmem_addr;
    reg uart_tx_start;
    reg uart_dmem_we;
    reg uart_tx_status;
    reg before_rx_ready;
    reg is_rx_recieved;
    reg [1:0] uart_tx_mode;

    // FPGA書き込み時コメントアウト解除
    // 内部クロック生成(IP: PLL)
    pll pll_inst (
        .inclk0(clock),
        .c0(clock_100M),
        .c1(clock_50M),
        .c2(clock_25M)
    );

    // FPGA書き込み時コメントアウト
    // assign clock_100M = clock;
    // divider divider_100_to_50 (
    //     .clock_in(clock),
    //     .n_rst(n_rst),
    //     .clock_out(clock_50M)
    // );
    // divider divider_50_to_25 (
    //     .clock_in(clock_50M),
    //     .n_rst(n_rst),
    //     .clock_out(clock_25M)
    // );

    // CPU
    onc_16 onc_16_inst (
        .imem_din(w_cpu_imem_d),
        .dmem_din(w_cpu_dmem_din),
        .clock(clock_50M),
        .n_rst(n_rst),
        .en(1'b1),
        .imem_addr(w_cpu_imem_addr),
        .dmem_addr(w_cpu_dmem_addr),
        .dmem_dout(w_cpu_dmem_dout),
        .dmem_we(w_cpu_dmem_we)
    );

    // 命令メモリ
    rom rom_inst (
        .clock(!clock_100M),
        .addr (w_cpu_imem_addr),
        .data (w_cpu_imem_d)
    );

    // データメモリ
    dpram dpram_inst (
        .clock(clock_100M),
        .addr1(w_cpu_dmem_addr[11:0]),
        .din1 (w_cpu_dmem_dout),
        .we1  (w_cpu_dmem_we),
        .dout1(w_cpu_dmem_din),
        .addr2(uart_dmem_addr),
        .din2 (uart_dmem_din),
        .we2  (uart_dmem_we),
        .dout2(w_uart_dmem_dout)
    );

    always @(posedge clock_100M or negedge n_rst) begin
        if (!n_rst) begin
            uart_dmem_din <= {14'b0, w_uart_rx_ready, uart_tx_status};
            uart_dmem_addr <= UART_STATUS_ADDR;  // デフォルトはステータスアドレスにアクセス
            uart_dmem_we <= 1'b1;
            uart_tx_start <= 1'b0;
            uart_tx_status <= 1'b1;
            uart_tx_mode <= 2'd0;
            before_rx_ready <= 1'b1;
            is_rx_recieved <= 1'b0;
        end else begin
            // ここからUART受信(RX)
            if ({before_rx_ready, w_uart_rx_ready} == 2'b01) begin  // rx_readyの立ち上がり検知
                uart_dmem_din  <= {8'b0, w_rx_data};  // メモリ入力をRXデータに
                uart_dmem_addr <= UART_RX_DATA_ADDR;  // RXデータアドレスにアクセス
                uart_dmem_we   <= 1'b1;
                is_rx_recieved <= 1'b1;  // rxデータ受信フラグを立てる
            end else if (is_rx_recieved) begin
                // メモリ入力をステータスデータに 16~3bit目: ダミーデータ, 2bit目: 0: 受信中, 1: 受信準備完了, 1bit目: 0: 送信中, 1: 送信準備完了
                uart_dmem_din  <= {14'b0, w_uart_rx_ready, uart_tx_status};
                uart_dmem_addr <= UART_STATUS_ADDR;  // ステータスアドレスにアクセス
                uart_dmem_we   <= 1'b1;
                is_rx_recieved <= 1'b0;
            end else begin
                // ここからUART送信(TX)
                uart_dmem_din <= {14'b0, w_uart_rx_ready, uart_tx_status};
                case (uart_tx_mode)
                    2'd0: begin  // CPUからTXへの書き込み検知
                        if ((w_cpu_dmem_addr[11:0] == UART_TX_DATA_ADDR) && w_cpu_dmem_we) begin  // CPUからTXへの書き込み検知
                            uart_dmem_addr <= UART_STATUS_ADDR;  // ステータスアドレスにアクセス
                            uart_dmem_we   <= 1'b1;  // ram(uart側)の書き込み許可
                            uart_tx_status <= 1'b0;  // ステータスを送信中に設定
                            uart_tx_mode   <= 2'd1;
                        end
                    end
                    2'd1: begin  // TXがメモリからデータを読み出す
                        uart_dmem_addr <= UART_TX_DATA_ADDR;
                        uart_dmem_we   <= 1'b0;  // ram(uart側)の書き込み禁止
                        uart_tx_mode   <= 2'd2;
                    end
                    2'd2: begin // TX送信開始待ち(uart_tx_readyが1になるまで, uart_tx内の送信データバッファがラッチされる)
                        uart_tx_start <= 1'b1;  // UART送信用データの準備完了(送信開始)
                        uart_tx_mode <= (!w_uart_tx_ready) ? 2'd3: 2'd2; // UARTが送信開始したことを確認したらモード3へ
                    end
                    2'd3: begin  // TX送信終了待ち
                        uart_tx_start  <= 1'b0;
                        uart_dmem_addr <= UART_STATUS_ADDR;
                        uart_dmem_we   <= 1'b1;  // ram(uart側)の書き込み許可
                        if (w_uart_tx_ready) begin
                            uart_tx_status <= 1'b1;  // ステータスに送信準備完了を設定
                            uart_tx_mode   <= 2'd0;
                        end
                    end
                    default: uart_tx_mode <= 2'd0;
                endcase
            end
            before_rx_ready <= w_uart_rx_ready;
        end
    end

    // UART送信モジュール
    uart_tx uart_tx_inst (
        .clock_50M(clock_50M),
        .n_rst(n_rst),
        .start(uart_tx_start),
        .tx_data(w_uart_dmem_dout[7:0]),  // 下位8ビットのみ送信する
        .ready(w_uart_tx_ready),  // 最下位ビットがステータス
        .tx(TxD)
    );

    // UART受信モジュール
    uart_rx uart_rx_inst (
        .clock_50M(clock_50M),
        .n_rst(n_rst),
        .rx(RxD),
        .ready(w_uart_rx_ready),
        .rx_data(w_rx_data)
    );

    // UART IC 定数割当て
    assign RxD_ex = RxD;
    assign TxD_ex = TxD;
    assign RTS = 1'b0;
    assign WAKEUP = 1'b1;

endmodule

`endif
