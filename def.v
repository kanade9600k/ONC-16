// 定数管理ファイル
`ifndef DEF_V
`define DEF_V
// データサイズ関連
`define DATA_W 16       // データ幅
`define IMM_W 8         // イミディエイトデータのデータ幅
`define INST_W 16       // 命令長
`define OPCODE_W 4      // オペコード長
`define R_FUNC_W 4      // R型命令のfunct長
`define ALU_FUNC_W 4    // ALUの機能選択信号幅
`define ALU_A_SEL_W 1   // ALUのAポート選択信号幅
`define ALU_B_SEL_W 2   // ALUのBポート選択信号幅
`define FR_FUNC_W 3     // フラグレジスタの機能選択信号幅
`define FR_FLAG_W 4     // フラグレジスタのフラグ幅
`define N_FLAG 3        // Nフラグのインデックス
`define Z_FLAG 2        // Zフラグのインデックス
`define C_FLAG 1        // Cフラグのインデックス
`define V_FLAG 0        // Vフラグのインデックス
`define RF_ADDR_W 4     // レジスタファイルのアドレス幅
`define RF_REG 16       // レジスタファイルのレジスタ数
`define RF_ZERO 0       // レジスタファイルのゼロレジスタのインデックス
`define RF_W_SEL_W 1    // レジスタファイル書き込み元選択信号幅
`define PC_IMR_SEL_W 1  // PCのイミディエイト，レジスタ選択信号幅
// オペコード
`define OP_R `OPCODE_W'b0000        // R型命令のオペコード
`define OP_ADDIU `OPCODE_W'b0001
`define OP_SUBIU `OPCODE_W'b0010
`define OP_LDIU `OPCODE_W'b0100
`define OP_LDI `OPCODE_W'b0101
`define OP_LDHI `OPCODE_W'b0110
`define OP_ANDI `OPCODE_W'b1000
`define OP_ORI `OPCODE_W'b1001
`define OP_XORI `OPCODE_W'b1010
`define OP_SRAI `OPCODE_W'b1011
`define OP_SRLI `OPCODE_W'b1100
`define OP_SLLI `OPCODE_W'b1101
`define OP_CMPI `OPCODE_W'b1110
`define OP_B `OPCODE_W'b1111        // B型命令のオペコード
// R型命令のオペコード
`define R_FUNC_ADD `R_FUNC_W'b0001
`define R_FUNC_SUB `R_FUNC_W'b0010
`define R_FUNC_MOV `R_FUNC_W'b0011
`define R_FUNC_LD `R_FUNC_W'b0100
`define R_FUNC_ST `R_FUNC_W'b0101
`define R_FUNC_NOT `R_FUNC_W'b0111
`define R_FUNC_AND `R_FUNC_W'b1000
`define R_FUNC_OR `R_FUNC_W'b1001
`define R_FUNC_XOR `R_FUNC_W'b1010
`define R_FUNC_SRA `R_FUNC_W'b1011
`define R_FUNC_SRL `R_FUNC_W'b1100
`define R_FUNC_SLL `R_FUNC_W'b1101
`define R_FUNC_CMP `R_FUNC_W'b1110
// ALUの関数コード
`define ALU_ADD `ALU_FUNC_W'b0001
`define ALU_SUB `ALU_FUNC_W'b0010
`define ALU_TH `ALU_FUNC_W'b0011
`define ALU_NOT `ALU_FUNC_W'b0111
`define ALU_AND `ALU_FUNC_W'b1000
`define ALU_OR `ALU_FUNC_W'b1001
`define ALU_XOR `ALU_FUNC_W'b1010
`define ALU_SRA `ALU_FUNC_W'b1011
`define ALU_SRL `ALU_FUNC_W'b1100
`define ALU_SLL `ALU_FUNC_W'b1101
`define ALU_UD `ALU_FUNC_W'bx       // 未定義
// ALUのAポート入力選択コード
`define ALU_A_RD `ALU_A_SEL_W'b0    // デスティネーションレジスタの値
`define ALU_A_SV `ALU_A_SEL_W'b1    // LDHIのシフト値
`define ALU_A_UD `ALU_A_SEL_W'bx    // 未定義
// ALUのBポート入力選択コード
`define ALU_B_RS `ALU_B_SEL_W'b00   // ソースレジスタの値
`define ALU_B_ZE `ALU_B_SEL_W'b01   // immのゼロ拡張値
`define ALU_B_SE `ALU_B_SEL_W'b10   // immの符号拡張値
`define ALU_B_UD `ALU_B_SEL_W'bx    // 未定義
// レジスタファイルの書き込み元選択コード
`define RF_W_ALU `RF_W_SEL_W'b0     // ALU出力から書き込み
`define RF_W_DM `RF_W_SEL_W'b1      // データメモリから書き込み
`define RF_W_UD `RF_W_SEL_W'bx      // 未定義
// フラグレジスタの分岐コード
`define FR_BAL `FR_FUNC_W'b000
`define FR_BEQ `FR_FUNC_W'b001 
`define FR_BNE `FR_FUNC_W'b010
`define FR_BLT `FR_FUNC_W'b011
`define FR_BGE `FR_FUNC_W'b100
`define FR_BLTU_BC `FR_FUNC_W'b101
`define FR_BGEU_BNC `FR_FUNC_W'b110
`define FR_BVF `FR_FUNC_W'b111
// プログラムカウンタの分岐時利用値選択コード
`define PC_IMM `PC_IMR_SEL_W'b0     // イミディエイトデータを利用
`define PC_REG `PC_IMR_SEL_W'b1     // レジスタの値を利用
`define PC_UD `PC_IMR_SEL_W'bx      // 未定義
`endif
