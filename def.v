// 定数管理ファイル
`define DATA_W 16
`define ALU_FUNC_W 4
`define FR_FLAG_W 4
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
