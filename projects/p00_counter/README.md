# p00_counter — Parameterized up-counter (reference project)

> Status: **done** · Top module: `counter`
>
> This project is the worked example. Every later project follows the same layout:
> spec (this file) → [TESTPLAN.md](TESTPLAN.md) → `rtl/` → `tb/` → green regression.

## 1. Overview

A free-running up-counter with synchronous load and a one-cycle wrap pulse. Blocks like this
are used for timeouts, baud-rate generation and address generation.

## 2. Parameters

| Name | Default | Range | Description |
|------|---------|-------|-------------|
| `WIDTH` | 8 | 1–32 | Counter width in bits |

## 3. Interface

| Signal | Dir | Width | Description |
|--------|-----|-------|-------------|
| `clk` | in | 1 | Clock, rising edge |
| `rst_n` | in | 1 | Synchronous active-low reset |
| `en` | in | 1 | Count enable |
| `load` | in | 1 | Load `load_val` into the counter |
| `load_val` | in | WIDTH | Value to load |
| `count` | out | WIDTH | Current value (registered) |
| `wrap` | out | 1 | High for one cycle after the counter wraps from MAX to 0 |

## 4. Functional behavior

On each rising edge of `clk`:

1. If `rst_n == 0`: `count ← 0`, `wrap ← 0`.
2. Else if `load == 1`: `count ← load_val`, `wrap ← 0`. **Load has priority over `en`.**
3. Else if `en == 1`: `count ← (count + 1) mod 2^WIDTH`; `wrap ← 1` iff the old `count` was `2^WIDTH − 1`.
4. Else: `count` holds, `wrap ← 0`.

## 6. Verification summary

| Item | Result |
|------|--------|
| Lint (`verilator -Wall`) | clean |
| SV testbench (`counter_tb.sv`, WIDTH=4) | directed, self-checking — PASS |
| cocotb (`test_counter.py`, WIDTH=8) | 2 tests, 5,000 random cycles/seed — PASS |
| Coverage bins closed | 5/5 (wrap, load-while-enabled, hold, load MAX, reset mid-run) |
| Known limitations | `WIDTH` > 32 not verified |
