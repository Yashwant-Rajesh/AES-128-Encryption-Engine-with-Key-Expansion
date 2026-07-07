# AES-128 Encryption Engine with Key Expansion

A hardware implementation of the AES-128 encryption algorithm (FIPS-197) in Verilog, covering the full round structure — SubBytes, ShiftRows, MixColumns, AddRoundKey — plus on-the-fly key expansion.

## Scope

This repository implements **AES-128 encryption only**. It does not include:
- Inverse SubBytes / InvShiftRows / InvMixColumns
- Decryption datapath or control FSM
- AES-192 / AES-256 (only the 128-bit key size, 10-round schedule, is covered)

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
AES-128-Encryption-Engine-with-Key-Expansion/
├── README.md
│
├── RTL/                    # Design source: S-Box, SubBytes, ShiftRows, MixColumns,
│                            # AddRoundKey, key expansion (RotWord/SubWord/Rcon),
│                            # and the top-level 10-round datapath + control
│
└── Simulation/             # Testbench(es) verifying the encryption datapath and
                             # key expansion against known-answer test vectors



> I don't have the exact filenames inside `RTL/` or `Simulation/` yet — same as the other repos, share a screenshot of each folder's contents and I'll swap the generic descriptions above for exact file references.
