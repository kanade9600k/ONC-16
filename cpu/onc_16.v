// CPUのトップモジュール
`ifndef ONC_16_V
`define ONC_16_V
`include "def.v"
`include "alu.v"
`include "decoder.v"
`include "extender.v"
`include "flag_reg_dec.v"
`include "pc.v"
`include "reg_file.v"
`default_nettype none

module onc_16 (
    input wire [`INST_W-1:0] imem_din,
    input wire [`DATA_W-1:0] dmem_din,
    input wire clock,
    input wire n_rst,
    input wire en,
    output wire [`DATA_W-1:0] imem_addr,
    output wire [`DATA_W-1:0] dmem_addr,
    output wire [`DATA_W-1:0] dmem_dout,
    output wire dmem_we
);
    // 内部信号定義
    wire w_rf_we, w_fr_de, w_dmem_we, w_pc_bre;  // 各種イネーブル
    wire [`IMM_W-1:0] w_imm;  // イミディエイトデータ（オリジナル）
    wire [`DATA_W-1:0] w_imm_z, w_imm_s;  // イミディエイトデータ（ゼロ拡張，符号拡張）
    wire [ `ALU_FUNC_W-1:0] w_alu_func;  // ALU機能選択
    wire [`ALU_A_SEL_W-1:0] w_alu_a_sel;  // ALUaポート入力選択
    wire [`ALU_B_SEL_W-1:0] w_alu_b_sel;  // ALUbポート入力選択
    wire [`DATA_W-1:0] w_alu_a, w_alu_b, w_alu_y;  // ALUa, bポート入力，出力
    wire [`RF_ADDR_W-1:0] w_rf_r1_addr, w_rf_r2_addr, w_rf_w_addr;  // レジスタファイル各種アドレス
    wire [`DATA_W-1:0] w_w_data;  // レジスタファイル書き込みデータ
    wire [`RF_W_SEL_W-1:0] w_rf_w_sel;  // レジスタファイル書き込み元選択
    wire [`DATA_W-1:0] w_r1_data, w_r2_data;  // レジスタファイル出力
    wire [`FR_FUNC_W-1:0] w_fr_func;  // フラグレジスタ分岐条件選択
    wire [`FR_FLAG_W-1:0] w_fr_flags;  // フラグレジスタフラグ
    wire [`PC_IMR_SEL_W-1:0] w_pc_imr_sel;  // プログラムカウンタイミディエイト・レジスタ選択
    wire [`DATA_W-1:0] w_imem_addr;  // プログラムカウンタのアドレス

    // 機能記述（接続）
    // CPUデータメモリ接続
    assign dmem_dout = (en) ? w_r1_data : `DATA_UD;
    assign dmem_addr = (en) ? w_r2_data : `DATA_UD;
    // 命令デコーダ
    decoder decoder_inst (
        .in(imem_din),
        .alu_func(w_alu_func),
        .alu_a_sel(w_alu_a_sel),
        .alu_b_sel(w_alu_b_sel),
        .imm(w_imm),
        .rf_r1_addr(w_rf_r1_addr),
        .rf_r2_addr(w_rf_r2_addr),
        .rf_w_addr(w_rf_w_addr),
        .rf_w_sel(w_rf_w_sel),
        .rf_we(w_rf_we),
        .fr_func(w_fr_func),
        .fr_de(w_fr_de),
        .pc_imr_sel(w_pc_imr_sel),
        .dmem_we(dmem_we)
    );

    // レジスタファイル
    // verilog_format: off
    assign w_w_data = (w_rf_w_sel == `RF_W_ALU) ? w_alu_y :  // 書き込み元選択
                      (w_rf_w_sel == `RF_W_DM) ? dmem_din : `DATA_UD;
    reg_file reg_file_inst (
        .r1_addr(w_rf_r1_addr),
        .r2_addr(w_rf_r2_addr),
        .w_addr(w_rf_w_addr),
        .w_data(w_w_data),
        .we(w_rf_we),
        .clock(clock),
        .n_rst(n_rst),
        .r1_data(w_r1_data),
        .r2_data(w_r2_data)
    );

    // ビット拡張器
    extender extender_inst (.in(w_imm), .out_z(w_imm_z), .out_s(w_imm_s));

    // ALU
    assign w_alu_a = (w_alu_a_sel == `ALU_A_RD) ? w_r1_data :  // aポート入力選択
                     (w_alu_a_sel == `ALU_A_ZE) ? w_imm_z   : `DATA_UD;
    assign w_alu_b = (w_alu_b_sel == `ALU_B_RS) ? w_r2_data :  // bポート入力選択
                     (w_alu_b_sel == `ALU_B_ZE) ? w_imm_z   :
                     (w_alu_b_sel == `ALU_B_SE) ? w_imm_s   : 
                     (w_alu_b_sel == `ALU_B_SV) ? `LDHI_SA  : `DATA_UD;
    alu alu_inst(.a(w_alu_a), .b(w_alu_b), .func(w_alu_func), .y(w_alu_y), .flags(w_fr_flags));

    // フラグレジスタ・デコーダ
    flag_reg_dec flag_reg_dec_inst(.flags(w_fr_flags), .func(w_fr_func), .de(w_fr_de), .clock(clock), .n_rst(n_rst), .bre(w_pc_bre));
    
    // プログラムカウンタモジュール
    pc pc_inst(.imm(w_imm_s), .rs(w_r2_data), .imr_sel(w_pc_imr_sel), .bre(w_pc_bre), .clock(clock), .n_rst(n_rst), .out(w_imem_addr));
    
    // CPU命令メモリ接続
    assign imem_addr = (en) ? w_imem_addr : `DATA_UD;
    // verilog_format: on

endmodule

`endif
