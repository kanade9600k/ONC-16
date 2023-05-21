// UART送信回路
`ifndef UART_TX_V
`define UART_TX_V
`default_nettype none

module uart_tx (
    input wire clock_50M,
    input wire n_rst,
    input wire start,
    input wire [7:0] tx_data,
    output wire ready,  // 送信準備完了: 1, 送信中or送信準備中: 0
    output reg tx
);
    // 内部定数定義
    parameter UART_CLOCK = 9'd434;  // 50MHz(クロック)/115.2kHz(ポーレート)
    // 内部信号定義
    reg [7:0] data_buf;  // 送信データの一時保存用
    reg [3:0] tx_index;  // どのビットを送っているか
    reg [8:0] clock_count;  // クロック分周用
    reg is_send;  // 送信中(1: 送信中, 0: 待機中)

    always @(posedge clock_50M or negedge n_rst) begin
        if (!n_rst) begin  // リセット
            tx_index <= 4'b0;
            clock_count <= 5'd0;
            is_send <= 1'b0;

        end else if (is_send) begin  // 送信中
            if (clock_count == UART_CLOCK) begin  // URATのクロックタイミングの場合
                clock_count <= 9'd0;
                tx <= data_buf[0];  // 最下位ビットを送信
                tx_index <= tx_index + 4'd1;
                data_buf[7:0] <= {1'b1, data_buf[7:1]};  // 1ビット右シフト(左の1はストップビット)

                if (tx_index == 4'd9) begin
                    is_send <= 1'b0;  // 送信終了
                end

            end else begin  // URATのクロックタイミングでないとき
                clock_count <= clock_count + 9'd1;
            end

        end else if (start) begin  // 送信開始(送信中は反応しない)
            clock_count <= 9'd0;
            data_buf <= tx_data;  // 入力からデータをコピー
            tx_index <= 4'd0;  // 送信データのインデックスを初期化
            is_send <= 1'b1;  // 送信中に
            tx <= 1'b0;  // スタートビット

        end else begin
            tx <= 1'b1;  // 何もしないときは常時1を出力 
        end
    end

    assign ready = (!start) && (!is_send);  // 送信準備でないかつ送信中でない場合，送信準備完了信号を出力

endmodule

`endif
