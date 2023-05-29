// デュアルポートRAMのテストベンチ
`ifndef DPRAM_TB_V
`define DPRAM_TB_V
`default_nettype none
`include "dpram.v"
`timescale 1ns / 1ns

module dpram_tb;

    // 入出力の宣言
    reg clock_tb;
    reg [11:0] addr1_tb;
    reg [11:0] addr2_tb;
    reg [15:0] din1_tb;
    reg [15:0] din2_tb;
    reg we1_tb;
    reg we2_tb;
    wire [15:0] dout1_tb;
    wire [15:0] dout2_tb;

    // モジュールの宣言
    dpram dpram_inst (
        .clock(clock_tb),
        .addr1(addr1_tb),
        .din1 (din1_tb),
        .we1  (we1_tb),
        .dout1(dout1_tb),
        .addr2(addr2_tb),
        .din2 (din2_tb),
        .we2  (we2_tb),
        .dout2(dout2_tb)
    );

    // クロック記述
    always #5 clock_tb <= ~clock_tb;

    // テストパターン
    initial begin
        clock_tb <= 1'b1;
        we1_tb   <= 1'b0;
        we2_tb   <= 1'b1;
        addr1_tb <= 12'hxxx;
        addr2_tb <= 12'h800;
        din1_tb  <= 16'h0048;
        din2_tb  <= 16'h0001;
        #5;
        addr1_tb <= 12'h801;
        we1_tb   <= 1'b1;
        #5;
        addr2_tb <= 16'h0801;
        we1_tb   <= 1'b1;
        #5;
        // addr1_tb <= 12'hxxx;
        din1_tb <= 16'hxxxx;
        we1_tb  <= 1'b0;
        we2_tb  <= 1'b0;
        #5;
        addr2_tb <= 12'h800;
        #5;
        #20;
        addr2_tb <= 12'h801;
        #20;
        $finish;
    end

    initial begin
        $dumpfile("dpram.vcd");
        $dumpvars(0);
    end

endmodule

`endif
