// CPUのトップモジュール
`ifndef ONC_16_PL_V
`define ONC_16_PL_V
`include "def.v"
`include "alu.v"
`include "decoder.v"
`include "extender.v"
`include "flag_reg_dec.v"
`include "pc.v"
`include "reg_file.v"
`default_nettype none

module onc_16_pl (
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
    wire [`INST_W-1:0] w_imem_din;  // 命令メモリ入力
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
    
    // パイプライン用レジスタ
    // FD
    reg [`DATA_W-1:0] r_fd_imem_din;
    reg r_fd_en;
    // DE
    reg r_de_dmem_we;
    reg r_de_fr_de;
    reg [`PC_IMR_SEL_W-1:0]r_de_pc_imr_sel;
    reg [`FR_FUNC_W-1:0] r_de_fr_func;
    reg [`ALU_A_SEL_W-1:0] r_de_alu_a_sel;
    reg [`ALU_B_SEL_W-1:0] r_de_alu_b_sel;
    reg [`ALU_FUNC_W-1:0] r_de_alu_func;
    reg [`DATA_W-1:0] r_de_r1_data, r_de_r2_data;
    reg [`DATA_W-1:0] r_de_imm_z, r_de_imm_s;
    reg [`RF_ADDR_W-1:0] r_de_rf_w_addr;
    reg [`RF_W_SEL_W-1:0] r_de_rf_w_sel;
    reg r_de_rf_we;
    reg r_de_en;


    // 機能記述（接続）
    // 命令フェッチ(F)
    assign w_imem_din = imem_din;

    // パイプライン: 命令フェッチ(F)->命令デコード(D)
    always @(posedge clock or negedge n_rst) begin
        if (!n_rst) begin
            r_fd_imem_din <= `DATA_UD;
        end else if (en) begin
            r_fd_imem_din <= w_imem_din;
        end
        r_fd_en <= en;
    end

    // 命令デコード(D)
    decoder decoder_inst (
        .in(r_fd_imem_din),
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
        .dmem_we(w_dmem_we)
    );

    // verilog_format: off
    assign w_w_data = (r_de_rf_w_sel == `RF_W_ALU) ? w_alu_y :  // 書き込み元選択
                      (r_de_rf_w_sel == `RF_W_DM) ? dmem_din : `DATA_UD;
    reg_file reg_file_inst (
        .r1_addr(w_rf_r1_addr),
        .r2_addr(w_rf_r2_addr),
        .w_addr(r_de_rf_w_addr),  // 書き込みはパイプラインで遅らせる
        .w_data(w_w_data),        // 書き込みはパイプラインで遅らせる
        .we(r_de_rf_we),          // 書き込みはパイプラインで遅らせる
        .clock(clock),
        .n_rst(n_rst),
        .r1_data(w_r1_data),
        .r2_data(w_r2_data)
    );

    extender extender_inst (.in(w_imm), .out_z(w_imm_z), .out_s(w_imm_s));

    // パイプライン: 命令デコード(D)->演算(E)
    always @(posedge clock or negedge n_rst) begin
        if (!n_rst) begin
            r_de_dmem_we <= 1'bx;
            r_de_fr_de <= 1'bx;
            r_de_fr_func <= `FR_UD;
            r_de_pc_imr_sel <= `PC_UD;
            r_de_alu_a_sel <= `ALU_A_UD;
            r_de_alu_b_sel <= `ALU_B_UD;
            r_de_alu_func <= `ALU_UD;
            r_de_r1_data <= `DATA_UD;
            r_de_r2_data <= `DATA_UD;
            r_de_imm_z <= `DATA_UD;
            r_de_imm_s <= `DATA_UD;
            r_de_rf_w_addr <= `RF_ADDR_UD;
            r_de_rf_w_sel <= `RF_W_UD;
            r_de_rf_we <= 1'bx;
        end else if (r_fd_en) begin
            r_de_dmem_we <= w_dmem_we;
            r_de_fr_de <= w_fr_de;
            r_de_fr_func <= w_fr_func;
            r_de_pc_imr_sel <= w_pc_imr_sel;
            r_de_alu_a_sel <= w_alu_a_sel;
            r_de_alu_b_sel <= w_alu_b_sel;
            r_de_alu_func <= w_alu_func;
            r_de_r1_data <= w_r1_data;
            r_de_r2_data <= w_r2_data;
            r_de_imm_z <= w_imm_z;
            r_de_imm_s <= w_imm_s;
            r_de_rf_w_addr <= w_rf_w_addr;
            r_de_rf_w_sel <= w_rf_w_sel;
            r_de_rf_we <= w_rf_we;
        end
        r_de_en <= r_fd_en;
    end

    // 演算(E)
    assign w_alu_a = (r_de_alu_a_sel == `ALU_A_RD) ? r_de_r1_data :  // aポート入力選択
                     (r_de_alu_a_sel == `ALU_A_ZE) ? r_de_imm_z   : `DATA_UD;
    assign w_alu_b = (r_de_alu_b_sel == `ALU_B_RS) ? r_de_r2_data :  // bポート入力選択
                     (r_de_alu_b_sel == `ALU_B_ZE) ? r_de_imm_z   :
                     (r_de_alu_b_sel == `ALU_B_SE) ? r_de_imm_s   : 
                     (r_de_alu_b_sel == `ALU_B_SV) ? `LDHI_SA  : `DATA_UD;
    alu alu_inst(.a(w_alu_a), .b(w_alu_b), .func(r_de_alu_func), .y(w_alu_y), .flags(w_fr_flags));

    // メモリアクセス(演算と同じタイミング)
    assign dmem_dout = r_de_r1_data;
    assign dmem_addr = r_de_r2_data;
    assign dmem_we = r_de_dmem_we;


    // ライトバック(W)
    flag_reg_dec flag_reg_dec_inst(.flags(w_fr_flags), .func(r_de_fr_func), .de(r_de_fr_de), .clock(clock), .n_rst(n_rst), .bre(w_pc_bre));
    
    // プログラムカウンタモジュール
    pc pc_inst(.imm(r_de_imm_s), .rs(r_de_r2_data), .imr_sel(r_de_pc_imr_sel), .bre(w_pc_bre), .clock(clock), .n_rst(n_rst), .out(imem_addr));
    // verilog_format: on
    // 命令フェッチへ

endmodule

`endif
