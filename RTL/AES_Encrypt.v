`timescale 1ns / 1ps

module AES_Encrypt(
    input  [127:0] plaintext,
    input  [127:0] key,
    output [127:0] ciphertext
);

    wire [1407:0] round_keys;

    // Generate all round keys
    KeyExpansion ke (
        .key_in(key),
        .round_keys(round_keys)
    );

    // Initial AddRoundKey
    wire [127:0] state0;
    AddRoundKey ark0 (
        .state_in(plaintext),
        .round_key(round_keys[0 +: 128]),
        .state_out(state0)
    );

    // Intermediate rounds
    wire [127:0] state [0:9];

    assign state[0] = state0;

    genvar i;
    generate
        for (i = 1; i < 10; i = i + 1) begin : rounds
            AES_Round r (
                .state_in(state[i-1]),
                .round_key(round_keys[i*128 +: 128]),
                .state_out(state[i])
            );
        end
    endgenerate

    // Final round (no MixColumns)
    AES_FinalRound final_r (
        .state_in(state[9]),
        .round_key(round_keys[10*128 +: 128]),
        .state_out(ciphertext)
    );

endmodule