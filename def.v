// 定数管理ファイル
`define DATA_W 16       // データ幅
`define IMM_W 8         // イミディエイトデータのデータ幅
`define INST_W 16       // 命令長
`define PC_IMR_SEL_W 1  // PCのイミディエイト，レジスタ選択信号幅
`define PC_BR_SEL_W 1   // PCの分岐選択信号幅
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
`define FR_BAL `FR_FUNC_W'b000
`define FR_BEQ `FR_FUNC_W'b001 
`define FR_BNE `FR_FUNC_W'b010
`define FR_BLT `FR_FUNC_W'b011
`define FR_BGE `FR_FUNC_W'b100
`define FR_BLTU_BC `FR_FUNC_W'b101
`define FR_BGEU_BNC `FR_FUNC_W'b110
`define FR_BVF `FR_FUNC_W'b111
