# __NAME__ — <one-line description>

> Status: **work in progress** · Top module: `__TOP__`

## 1. Overview

What the block does and where it would sit in a real chip (2–4 sentences).

## 2. Parameters

| Name | Default | Range | Description |
|------|---------|-------|-------------|
|      |         |       |             |

## 3. Interface

| Signal | Dir | Width | Description |
|--------|-----|-------|-------------|
| `clk`  | in  | 1     | Clock, all logic on the rising edge |
| `rst_n`| in  | 1     | Synchronous active-low reset |

## 4. Functional behavior

Cycle-level rules, written so that a reference model can be coded from this section alone.
Cover: reset values, normal operation, priority between inputs, illegal / corner cases
(what happens, not just "must not happen").

## 5. Timing diagram (optional)

A WaveDrom snippet or ASCII diagram of the main transaction.

## 6. Verification summary

Filled in at the end — see [TESTPLAN.md](TESTPLAN.md).

| Item | Result |
|------|--------|
| Lint (`verilator -Wall`) | |
| SV testbench | |
| cocotb tests / seeds | |
| Coverage bins closed | |
| Known limitations | |
