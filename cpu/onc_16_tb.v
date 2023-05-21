// CPUのテストベンチ
`ifndef ONC_16_TB_V
`define ONC_16_TB_V
`include "def.v"
`include "onc_16.v"
`default_nettype none

module onc_16_tb;

    reg [`INST_W-1:0] imem_din_tb;
    reg [`DATA_W-1:0] dmem_din_tb;
    reg clock_tb;
    reg n_rst_tb;
    wire [`DATA_W-1:0] imem_addr_tb;
    wire [`DATA_W-1:0] dmem_addr_tb;
    wire [`DATA_W-1:0] dmem_dout_tb;
    wire dmem_we_tb;

    // モジュールの宣言
    onc_16 onc_16_inst (
        .imem_din(imem_din_tb),
        .dmem_din(dmem_din_tb),
        .clock(clock_tb),
        .n_rst(n_rst_tb),
        .imem_addr(imem_addr_tb),
        .dmem_addr(dmem_addr_tb),
        .dmem_dout(dmem_dout_tb),
        .dmem_we(dmem_we_tb)
    );

    // 実行する命令メモリの内容をファイルから読み込み
    reg [`INST_W-1:0] imem[0:2**`DATA_W-1];
    initial begin
        $readmemh("rom_multiplication.txt", imem);
    end
    // 命令メモリにCPUの命令メモリ入力と命令メモリアドレスを接続
    always @(negedge clock_tb) begin    // アドレスとデータが1クロックずれる問題に対処するために，データは立ち下がりエッジで読み込む
        imem_din_tb <= imem[imem_addr_tb];
    end

    // クロック記述
    always #5 clock_tb <= ~clock_tb;

    // テストパターン
    initial begin
        clock_tb <= 1'b0;
        n_rst_tb <= 1'b0;
        #10;
        n_rst_tb <= 1'b1;
        dmem_din_tb <= `DATA_UD;
        #100000;
        $finish;
    end

    initial begin
        $dumpfile("onc_16.vcd");
        $dumpvars(0);
    end

endmodule

`endif
