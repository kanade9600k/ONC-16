// UART受信回路
`ifndef UART_RX_V
`define UART_RX_V
`default_nettype none

module uart_rx (
    input wire clock_50M,
    input wire n_rst,
    input wire rx,
    output wire ready,  // 受信準備完了: 1, 受信中or受信準備中: 0
    output reg [7:0] rx_data
);
    // 内部定数定義
    parameter UART_CLOCK = 9'd434;  // 50MHz(クロック)/115.2kHz(ポーレート)
    // parameter UART_CLOCK = 9'd217;  // 25MHz(クロック)/115.2kHz(ポーレート)
    // 内部信号定義
    reg [7:0] data_buf;  // 受信データの一時保存用
    reg [3:0] rx_index;  // どのビットを受信中か
    reg [8:0] clock_count;  // クロック分周用
    reg is_receive;  // 受信中(1: 受信中, 0: 待機中)

    always @(posedge clock_50M or negedge n_rst) begin
        if (!n_rst) begin  // リセット
            rx_index <= 4'b0;
            clock_count <= 5'd0;
            is_receive <= 1'b0;

        end else if (is_receive) begin  // 受信中
            if (clock_count == UART_CLOCK) begin  // URATのクロックタイミングの場合
                clock_count <= 9'd0;
                data_buf[rx_index] <= rx;  // 受信ビットを保存
                rx_index <= rx_index + 4'd1;

                if (rx_index == 4'd9) begin
                    is_receive <= 1'b0;  // 受信終了
                    rx_data <= data_buf;  // 受信データを出力
                end

            end else begin  // URATのクロックタイミングでないとき
                clock_count <= clock_count + 9'd1;
            end

        end else if (rx == 1'b0) begin  // 受信開始(受信中は反応しない)
            clock_count <= 9'd0;
            rx_index <= 4'd0;  // 受信データのインデックスを初期化
            is_receive <= 1'b1;  // 受信中に

        end
    end

    assign ready = !is_receive;  // 受信中でない場合，受信準備完了信号を出力

endmodule

`endif
