// 命令デコーダ
`ifndef DECODER_V
`define DECODER_V
`default_nettype none
`include "def.v"

module decoder (
    input wire [`INST_W-1:0] in,
    output wire [`ALU_FUNC_W-1:0] alu_func,
    output wire [`ALU_A_SEL_W-1:0] alu_a_sel,
    output wire [`ALU_B_SEL_W-1:0] alu_b_sel,
    output wire [`IMM_W-1:0] imm,
    output wire [`RF_ADDR_W-1:0] rf_r1_addr,
    output wire [`RF_ADDR_W-1:0] rf_r2_addr,
    output wire [`RF_ADDR_W-1:0] rf_w_addr,
    output wire [`RF_W_SEL_W-1:0] rf_w_sel,
    output wire rf_we,
    output wire [`FR_FUNC_W-1:0] fr_func,
    output wire fr_de,
    output wire [`PC_IMR_SEL_W-1:0] pc_imr_sel,
    output wire dmem_we
);

    // 内部信号（reg型だが，always @(*) なので組み合わせ回路）
    reg [`ALU_FUNC_W-1:0] tmp_alu_func;
    reg [`ALU_B_SEL_W-1:0] tmp_alu_b_sel;
    reg tmp_rf_we;

    // 機能記述
    // 組み合わせ回路

    // ALU機能デコード
    // verilog_format: off
    always @(*) begin
        // R型命令のときは，functフィールドで判断
        if (in[`INST_W-1:`INST_W-`OPCODE_W] == `OP_R) begin
            case (in[`INST_W-`OPCODE_W-1:`INST_W-`OPCODE_W-`R_FUNC_W])
                `R_FUNC_ADD: begin tmp_alu_func <= `ALU_ADD; tmp_rf_we <= 1'b1; end
                `R_FUNC_SUB: begin tmp_alu_func <= `ALU_SUB; tmp_rf_we <= 1'b1; end
                `R_FUNC_MOV: begin tmp_alu_func <= `ALU_TH;  tmp_rf_we <= 1'b1; end
                `R_FUNC_LD:  begin tmp_alu_func <= `ALU_UD;  tmp_rf_we <= 1'b1; end // LDはALUを使わないので未定義
                `R_FUNC_ST:  begin tmp_alu_func <= `ALU_UD;  tmp_rf_we <= 1'b0; end // STはALUを使わないので未定義
                `R_FUNC_NOT: begin tmp_alu_func <= `ALU_NOT; tmp_rf_we <= 1'b1; end
                `R_FUNC_AND: begin tmp_alu_func <= `ALU_AND; tmp_rf_we <= 1'b1; end
                `R_FUNC_OR:  begin tmp_alu_func <= `ALU_OR;  tmp_rf_we <= 1'b1; end
                `R_FUNC_XOR: begin tmp_alu_func <= `ALU_XOR; tmp_rf_we <= 1'b1; end
                `R_FUNC_SRA: begin tmp_alu_func <= `ALU_SRA; tmp_rf_we <= 1'b1; end
                `R_FUNC_SRL: begin tmp_alu_func <= `ALU_SRL; tmp_rf_we <= 1'b1; end
                `R_FUNC_SLL: begin tmp_alu_func <= `ALU_SLL; tmp_rf_we <= 1'b1; end
                `R_FUNC_CMP: begin tmp_alu_func <= `ALU_SUB; tmp_rf_we <= 1'b0; end
                default:     begin tmp_alu_func <= `ALU_UD;  tmp_rf_we <= 1'b0; end
            endcase
        end else begin  // その他の命令はオペコードで判断
            case (in[`INST_W-1:`INST_W-`OPCODE_W])
                `OP_ADDIU: begin tmp_alu_func <= `ALU_ADD; tmp_rf_we <= 1'b1; end
                `OP_SUBIU: begin tmp_alu_func <= `ALU_SUB; tmp_rf_we <= 1'b1; end
                `OP_LDIU:  begin tmp_alu_func <= `ALU_TH;  tmp_rf_we <= 1'b1; end
                `OP_LDI:   begin tmp_alu_func <= `ALU_TH;  tmp_rf_we <= 1'b1; end
                `OP_LDHI:  begin tmp_alu_func <= `ALU_SLL; tmp_rf_we <= 1'b1; end
                `OP_ANDI:  begin tmp_alu_func <= `ALU_AND; tmp_rf_we <= 1'b1; end
                `OP_ORI:   begin tmp_alu_func <= `ALU_OR;  tmp_rf_we <= 1'b1; end
                `OP_XORI:  begin tmp_alu_func <= `ALU_XOR; tmp_rf_we <= 1'b1; end
                `OP_SRAI:  begin tmp_alu_func <= `ALU_SRA; tmp_rf_we <= 1'b1; end
                `OP_SRLI:  begin tmp_alu_func <= `ALU_SRL; tmp_rf_we <= 1'b1; end
                `OP_SLLI:  begin tmp_alu_func <= `ALU_SLL; tmp_rf_we <= 1'b1; end
                `OP_CMPI:  begin tmp_alu_func <= `ALU_SUB; tmp_rf_we <= 1'b0; end
                `OP_B:     begin tmp_alu_func <= `ALU_UD;  tmp_rf_we <= 1'b0; end // B型命令はALUを使わないので未定義   
                default:   begin tmp_alu_func <= `ALU_UD;  tmp_rf_we <= 1'b0; end
            endcase
        end
    end
    // verilog_format: on
    assign alu_func = tmp_alu_func;

    // レジスタファイル書き込み有効信号
    assign rf_we = tmp_rf_we;

    // ALU Aポート入力選択デコード
    assign alu_a_sel = (in[`INST_W-1:`INST_W-`OPCODE_W] == `OP_LDHI) ? `ALU_A_SV : `ALU_A_RD;

    // ALU Bポート入力選択デコード
    always @(*) begin
        case (in[`INST_W-1:`INST_W-`OPCODE_W])
            `OP_R:     tmp_alu_b_sel <= `ALU_B_RS;
            `OP_ADDIU: tmp_alu_b_sel <= `ALU_B_ZE;
            `OP_SUBIU: tmp_alu_b_sel <= `ALU_B_ZE;
            `OP_LDIU:  tmp_alu_b_sel <= `ALU_B_ZE;
            `OP_LDI:   tmp_alu_b_sel <= `ALU_B_SE;
            `OP_LDHI:  tmp_alu_b_sel <= `ALU_B_ZE;
            `OP_ANDI:  tmp_alu_b_sel <= `ALU_B_ZE;
            `OP_ORI:   tmp_alu_b_sel <= `ALU_B_ZE;
            `OP_XORI:  tmp_alu_b_sel <= `ALU_B_ZE;
            `OP_SRAI:  tmp_alu_b_sel <= `ALU_B_ZE;
            `OP_SRLI:  tmp_alu_b_sel <= `ALU_B_ZE;
            `OP_SLLI:  tmp_alu_b_sel <= `ALU_B_ZE;
            `OP_CMPI:  tmp_alu_b_sel <= `ALU_B_SE;
            default:   tmp_alu_b_sel <= `ALU_B_UD;
        endcase
    end
    assign alu_b_sel = tmp_alu_b_sel;

    // イミディエイトデータ抽出
    assign imm = (in[`INST_W-1:`INST_W-`OPCODE_W] == `OP_B) ? in[`IMM_W-1:0] : in[`INST_W-`OPCODE_W-1:`INST_W-`OPCODE_W-`IMM_W];

    // レジスタファイルの各アドレス抽出
    assign rf_r1_addr = in[`RF_ADDR_W-1:0];
    assign rf_r2_addr = in[2*`RF_ADDR_W-1:`RF_ADDR_W];
    assign rf_w_addr = in[`RF_ADDR_W-1:0];

    // レジスタファイル書き込み元選択信号
    assign rf_w_sel = (in[`INST_W-1:`INST_W-`OPCODE_W-`R_FUNC_W] == {`OP_R, `R_FUNC_LD}) ? `RF_W_DM : `RF_W_ALU;

    // フラグレジスタ分岐条件信号抽出
    assign fr_func = in[`INST_W-`OPCODE_W-2:`INST_W-`OPCODE_W-`FR_FUNC_W-1];

    // フラグレジスタデコード有効信号
    assign fr_de = (in[`INST_W-1:`INST_W-`OPCODE_W] == `OP_B);

    // プログラムカウンタ分岐時利用値制御信号抽出
    assign pc_imr_sel = in[`INST_W-`OPCODE_W-1];

    // データメモリ書き込み有効
    assign dmem_we = (in[`INST_W-1:`INST_W-`OPCODE_W-`R_FUNC_W] == {`OP_R, `R_FUNC_ST});

endmodule

`endif
