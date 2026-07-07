# AES-128 Encryption Core

A hardware implementation of the AES-128 encryption algorithm (FIPS-197), covering the full round structure — SubBytes, ShiftRows, MixColumns, AddRoundKey — plus on-the-fly key expansion.

## Encryption Flow

1. **Initial AddRoundKey**
2. **9 Main Rounds**, each consisting of:
   - SubBytes
   - ShiftRows
   - MixColumns
   - AddRoundKey
3. **Final Round** (round 10, no MixColumns):
   - SubBytes
   - ShiftRows
   - AddRoundKey

## Key Expansion

- Generates 11 round keys (176 bytes total) from the initial 128-bit key
- Built from:
  - **RotWord** — one-byte left circular rotation of a 32-bit word
  - **SubWord** — S-Box substitution applied to each byte of a word
  - **Rcon** — round constants XORed in at each key-schedule step

## Repository Structure

```
aes-128/
├── README.md
├── rtl/
│   ├── sbox.v                        # Forward S-Box (and inverse, if decryption is included)
│   ├── sub_bytes.v
│   ├── shift_rows.v
│   ├── mix_columns.v
│   ├── add_round_key.v
│   ├── key_expansion.v               # RotWord, SubWord, Rcon, round-key generation
│   └── aes128_top.v                  # Top-level: 10-round datapath + control FSM
│
├── sim/
│   ├── tb_sbox.v
│   ├── tb_key_expansion.v            # Check all 11 round keys against known-answer test
│   ├── tb_aes128_top.v               # Full encryption using FIPS-197 test vectors
│   ├── waveforms/                    # Screenshots per test
│   └── logs/                         # Console pass/fail transcripts, incl. expected vs actual ciphertext
│
├── synth/
│   ├── constraints/
│   │   └── aes128.xdc
│   └── reports/
│       └── utilization_synth.rpt
│
├── impl/
│   ├── reports/
│   │   ├── utilization_impl.rpt
│   │   └── timing_summary_impl.rpt
│   └── screenshots/
│       └── routed_device_view.png
│
└── docs/
    └── round_structure.md            # Optional: diagram of the flow above
```

### Notes on ordering
Same `rtl/ → sim/ → synth/ → impl/` convention as the other two. One thing worth calling out explicitly in this README once you have it: whether you verified against the **official FIPS-197 Appendix B test vector** (key = `2b7e151628aed2a6abf7158809cf4f3c`, plaintext = `3243f6a8885a308d313198a2e0370734`) — reviewers of crypto cores specifically look for known-answer tests, so if you have that, feature it prominently near the top of the testbench section instead of burying it in `sim/`.

---

## ⚠️ One thing to double check before you publish

You mentioned this file "contains all the stuff like sub bytes, mix columns, etc." — if this repo is **encryption only** (no `inv_sub_bytes`, `inv_mix_columns`, `add_round_key` inverse, or decryption FSM), say so explicitly in the README under a "Scope" heading, the same way you did for the RISC-V core's unsupported instructions. It's a small thing but it's exactly the kind of clarity that makes a hardware repo look deliberate rather than incomplete.
