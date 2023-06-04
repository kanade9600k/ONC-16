// クロック分周器
`ifndef DIVIDER_V
`define DIVIDER_V
`default_nettype none

module divider (
    input  wire clock_in,
    input  wire n_rst,
    output reg  clock_out
);
    always @(posedge clock_in or negedge n_rst) begin
        if (!n_rst) begin
            clock_out <= 1'b0;
        end else begin
            clock_out <= !clock_out;
        end
    end
endmodule
`endif
