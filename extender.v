// ビット拡張器
`ifndef EXTENDER_V
`define EXTENDER_V
`include "def.v"
`default_nettype none

module extender (
    input  wire [ `IMM_W-1:0] in,
    output wire [`DATA_W-1:0] out_z,
    output wire [`DATA_W-1:0] out_s
);
    // 機能記述
    // 組み合わせ回路
    assign out_z = {{(`DATA_W - `IMM_W) {1'b0}}, in};  //ゼロ拡張
    assign out_s = {{(`DATA_W - `IMM_W) {in[`IMM_W-1]}}, in};  // 符号拡張
endmodule

`endif
