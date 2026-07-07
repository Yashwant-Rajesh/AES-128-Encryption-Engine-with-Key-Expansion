`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2026 15:05:37
// Design Name: 
// Module Name: AES_FinalRound
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


module AES_FinalRound(
    input  [127:0] state_in,
    input  [127:0] round_key,
    output [127:0] state_out
);
    wire [127:0] sb, sr;

    Sub_bytes  u1 (.state_in(state_in), .state_out(sb));
    Shift_rows u2 (.state_in(sb),       .state_out(sr));
    AddRoundKey u3 (.state_in(sr), .round_key(round_key), .state_out(state_out));

endmodule
