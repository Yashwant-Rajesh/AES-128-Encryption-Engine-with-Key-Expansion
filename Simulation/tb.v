`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////
// Multi-vector testbench for top_aes128.
// Runs several independent known-answer tests (FIPS-197 + NIST SP800-38A +
// two edge cases) through the start/done handshake and reports a pass/fail
// summary line for each, plus a final tally.
//////////////////////////////////////////////////////////////////////////////

module tb;

    reg          clk, rst, start;
    reg  [127:0] plaintext, key;
    wire         done;
    wire [127:0] ciphertext;

    top_aes128 uut (
        .clk(clk), .rst(rst), .start(start),
        .plaintext(plaintext), .key(key),
        .done(done), .ciphertext(ciphertext)
    );

    always #5 clk = ~clk;   // 10ns period

    // ---- Test vector storage ----
    integer NUM_VECTORS;
    reg [127:0] tv_key   [0:6];
    reg [127:0] tv_pt    [0:6];
    reg [127:0] tv_ct    [0:6];
    reg [8*32-1:0] tv_name [0:6];   // 32-char label per vector

    integer i, pass_count, fail_count;

    task run_vector(input integer idx);
        begin
            key       = tv_key[idx];
            plaintext = tv_pt[idx];

            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;

            wait (done == 1);
            #1;

            if (ciphertext === tv_ct[idx]) begin
                $display("[PASS] %0s : ct=%h", tv_name[idx], ciphertext);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %0s : got=%h expected=%h", tv_name[idx], ciphertext, tv_ct[idx]);
                fail_count = fail_count + 1;
            end

            // one idle cycle between vectors so 'done' settles before next start
            @(posedge clk);
        end
    endtask

    initial begin
        clk = 0; rst = 1; start = 0;
        pass_count = 0; fail_count = 0;
        NUM_VECTORS = 7;

        // FIPS-197 Appendix B
        tv_name[0] = "FIPS-197";
        tv_key[0]  = 128'h000102030405060708090a0b0c0d0e0f;
        tv_pt[0]   = 128'h00112233445566778899aabbccddeeff;
        tv_ct[0]   = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;

        // NIST SP800-38A ECB, common key, 4 different blocks
        tv_name[1] = "SP800-38A blk1";
        tv_key[1]  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        tv_pt[1]   = 128'h6bc1bee22e409f96e93d7e117393172a;
        tv_ct[1]   = 128'h3ad77bb40d7a3660a89ecaf32466ef97;

        tv_name[2] = "SP800-38A blk2";
        tv_key[2]  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        tv_pt[2]   = 128'hae2d8a571e03ac9c9eb76fac45af8e51;
        tv_ct[2]   = 128'hf5d3d58503b9699de785895a96fdbaaf;

        tv_name[3] = "SP800-38A blk3";
        tv_key[3]  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        tv_pt[3]   = 128'h30c81c46a35ce411e5fbc1191a0a52ef;
        tv_ct[3]   = 128'h43b1cd7f598ece23881b00e3ed030688;

        tv_name[4] = "SP800-38A blk4";
        tv_key[4]  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        tv_pt[4]   = 128'hf69f2445df4f9b17ad2b417be66c3710;
        tv_ct[4]   = 128'h7b0c785e27e8ad3f8223207104725dd4;

        // Edge cases
        tv_name[5] = "all-zero key+pt";
        tv_key[5]  = 128'h00000000000000000000000000000000;
        tv_pt[5]   = 128'h00000000000000000000000000000000;
        tv_ct[5]   = 128'h66e94bd4ef8a2c3b884cfa59ca342b2e;

        tv_name[6] = "all-one key+pt";
        tv_key[6]  = 128'hffffffffffffffffffffffffffffffff;
        tv_pt[6]   = 128'hffffffffffffffffffffffffffffffff;
        tv_ct[6]   = 128'hbcbf217cb280cf30b2517052193ab979;

        #12 rst = 0;

        for (i = 0; i < NUM_VECTORS; i = i + 1)
            run_vector(i);

        $display("--------------------------------------------------");
        $display("Total: %0d   Passed: %0d   Failed: %0d", NUM_VECTORS, pass_count, fail_count);
        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end

endmodule
