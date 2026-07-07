`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2026 15:04:50
// Design Name: 
// Module Name: AES_Round
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AES_Round(
    input  [127:0] state_in,
    input  [127:0] round_key,
    output [127:0] state_out
);
    wire [127:0] sb, sr, mc;

    Sub_bytes  u1 (.state_in(state_in), .state_out(sb));
    Shift_rows u2 (.state_in(sb),       .state_out(sr));
    Mix_columns u3 (.state_in(sr),      .state_out(mc));
    AddRoundKey u4 (.state_in(mc),      .round_key(round_key), .state_out(state_out));

endmodule
