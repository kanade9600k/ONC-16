// 命令デコーダのテストベンチ
`ifndef DECODER_TB_V
`define DECODER_TB_V
`default_nettype none
`include "def.v"
`include "decoder.v"
`timescale 1ns / 1ns

module decoder_tb;

    reg [`INST_W-1:0] in_tb;
    wire [`ALU_FUNC_W-1:0] alu_func_tb;
    wire [`ALU_A_SEL_W-1:0] alu_a_sel_tb;
    wire [`ALU_B_SEL_W-1:0] alu_b_sel_tb;
    wire [`IMM_W-1:0] imm_tb;
    wire [`RF_ADDR_W-1:0] rf_r1_addr_tb;
    wire [`RF_ADDR_W-1:0] rf_r2_addr_tb;
    wire [`RF_ADDR_W-1:0] rf_w_addr_tb;
    wire [`RF_W_SEL_W-1:0] rf_w_sel_tb;
    wire rf_we_tb;
    wire [`FR_FUNC_W-1:0] fr_func_tb;
    wire fr_de_tb;
    wire [`PC_IMR_SEL_W-1:0] pc_imr_sel_tb;
    wire dmem_we_tb;

    // モジュールの宣言
    decoder decoder_inst (
        .in(in_tb),
        .alu_func(alu_func_tb),
        .alu_a_sel(alu_a_sel_tb),
        .alu_b_sel(alu_b_sel_tb),
        .imm(imm_tb),
        .rf_r1_addr(rf_r1_addr_tb),
        .rf_r2_addr(rf_r2_addr_tb),
        .rf_w_addr(rf_w_addr_tb),
        .rf_w_sel(rf_w_sel_tb),
        .rf_we(rf_we_tb),
        .fr_func(fr_func_tb),
        .fr_de(fr_de_tb),
        .pc_imr_sel(pc_imr_sel_tb),
        .dmem_we(dmem_we_tb)
    );

    // テストパターン
    integer i;
    initial begin
        in_tb <= `INST_W'h0187;  // ADD
        #10;
        in_tb <= `INST_W'h0287;  // SUB
        #10;
        in_tb <= `INST_W'h0387;  // MOV
        #10;
        in_tb <= `INST_W'h0487;  // LD
        #10;
        in_tb <= `INST_W'h0587;  // ST
        #10;
        in_tb <= `INST_W'h0787;  // NOT
        #10;
        in_tb <= `INST_W'h0887;  // AND
        #10;
        in_tb <= `INST_W'h0987;  // OR
        #10;
        in_tb <= `INST_W'h0A87;  // XOR
        #10;
        in_tb <= `INST_W'h0B87;  // SRA
        #10;
        in_tb <= `INST_W'h0C87;  // SRL
        #10;
        in_tb <= `INST_W'h0D87;  // SLL
        #10;
        in_tb <= `INST_W'h0E87;  // CMP
        #10;
        in_tb <= `INST_W'h1F07;  // ADDIU
        #10;
        in_tb <= `INST_W'h2F07;  // SUBIU
        #10;
        in_tb <= `INST_W'h4F07;  // LDIU
        #10;
        in_tb <= `INST_W'h5F07;  // LDI
        #10;
        in_tb <= `INST_W'h6F07;  // LDHI
        #10;
        in_tb <= `INST_W'h8F07;  // ANDI
        #10;
        in_tb <= `INST_W'h9F07;  // ORI
        #10;
        in_tb <= `INST_W'hAF07;  // XORI
        #10;
        in_tb <= `INST_W'hBF07;  // SRAI
        #10;
        in_tb <= `INST_W'hCF07;  // SRLI
        #10;
        in_tb <= `INST_W'hDF07;  // SLLI
        #10;
        in_tb <= `INST_W'hEF07;  // CMPI
        #10;
        in_tb <= `INST_W'hF007;  // BALI
        #10;
        in_tb <= `INST_W'hF807;  // BAL
        #10;
        in_tb <= `INST_W'hF107;  // BEQI
        #10;
        in_tb <= `INST_W'hF907;  // BEQ
        #10;
        in_tb <= `INST_W'hF207;  // BNEI
        #10;
        in_tb <= `INST_W'hFA07;  // BNE
        #10;
        in_tb <= `INST_W'hF307;  // BLTI
        #10;
        in_tb <= `INST_W'hFB07;  // BLT
        #10;
        in_tb <= `INST_W'hF407;  // BGEI
        #10;
        in_tb <= `INST_W'hFC07;  // BGE
        #10;
        in_tb <= `INST_W'hF507;  // BLTIU
        #10;
        in_tb <= `INST_W'hFD07;  // BLTU
        #10;
        in_tb <= `INST_W'hF607;  // BGEIU
        #10;
        in_tb <= `INST_W'hFE07;  // BGEU
        #10;
        in_tb <= `INST_W'hF707;  // BVFI
        #10;
        in_tb <= `INST_W'hFF07;  // BVF
        #10;
    end

    initial begin
        $dumpfile("decoder.vcd");
        $dumpvars(0);
    end

endmodule

`endif
