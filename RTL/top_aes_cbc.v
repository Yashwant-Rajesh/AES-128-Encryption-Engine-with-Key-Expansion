`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////
// Top-level AES-128 (single block, no CBC) with a start/done handshake.
//
// Usage:
//   1. Drive plaintext & key, pulse start=1 for one clock cycle.
//   2. done goes low while the block loads.
//   3. One clock later, done=1 and ciphertext holds the result.
//
// The handshake exists so ciphertext/registers only update when you actually
// hand it a new block -- unlike a design that blindly re-computes every
// clock edge (which silently corrupts results if inputs are held steady
// for more than one cycle).
//////////////////////////////////////////////////////////////////////////////

module top_aes128(
    input              clk,
    input              rst,
    input              start,
    input      [127:0] plaintext,
    input      [127:0] key,
    output reg         done,
    output reg [127:0] ciphertext
);

    reg  [127:0] pt_reg, key_reg;
    reg          pending;          // a block was loaded last cycle, capture result now
    wire [127:0] aes_out;

    AES_Encrypt aes_core (
        .plaintext (pt_reg),
        .key       (key_reg),
        .ciphertext(aes_out)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pt_reg     <= 128'h0;
            key_reg    <= 128'h0;
            ciphertext <= 128'h0;
            done       <= 1'b0;
            pending    <= 1'b0;
        end else begin
            if (start) begin
                // Latch the new block; AES_Encrypt is combinational so its
                // output based on pt_reg/key_reg will be valid next cycle.
                pt_reg  <= plaintext;
                key_reg <= key;
                done    <= 1'b0;
                pending <= 1'b1;
            end else if (pending) begin
                ciphertext <= aes_out;
                done       <= 1'b1;
                pending    <= 1'b0;
            end
            // else: hold current outputs steady (no re-computation, no corruption)
        end
    end

endmodule