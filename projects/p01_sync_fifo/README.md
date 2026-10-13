# p01_sync_fifo — Parameterized synchronous FIFO

> Status: **work in progress** (`.wip`) · Top module: `sync_fifo`
>
> The spec below is given (as it would be by an architect). Your job: TESTPLAN.md → RTL → testbenches.
> Delete `.wip` when `make test` passes so the block joins the regression.

## 1. Overview

A single-clock first-in-first-out buffer. FIFOs decouple a producer from a consumer that run at
different rates and appear in almost every chip (and in almost every interview).

## 2. Parameters

| Name | Default | Range | Description |
|------|---------|-------|-------------|
| `DATA_W` | 8 | 1–64 | Data width |
| `DEPTH` | 16 | power of 2, 2–1024 | Number of entries |

## 3. Interface

| Signal | Dir | Width | Description |
|--------|-----|-------|-------------|
| `clk` | in | 1 | Clock, rising edge |
| `rst_n` | in | 1 | Synchronous active-low reset |
| `wr_en` | in | 1 | Write request |
| `wr_data` | in | DATA_W | Data to write |
| `rd_en` | in | 1 | Read request |
| `rd_data` | out | DATA_W | Read data — valid in the cycle **after** an accepted read |
| `full` | out | 1 | No free entries |
| `empty` | out | 1 | No valid entries |
| `count` | out | $clog2(DEPTH)+1 | Number of valid entries |
| `overflow` | out | 1 | Sticky: set when a write is requested while `full` |
| `underflow` | out | 1 | Sticky: set when a read is requested while `empty` |

## 4. Functional behavior

1. Reset: FIFO empty, `count = 0`, `full = 0`, `empty = 1`, `overflow = underflow = 0`. `rd_data` value is don't-care.
2. A write is **accepted** when `wr_en && !full`. The accepted data is stored at the tail.
3. A read is **accepted** when `rd_en && !empty`. The head entry is removed and appears on `rd_data` on the next cycle; `rd_data` holds its value until the next accepted read.
4. Simultaneous accepted read and write in the same cycle: both happen, `count` is unchanged.
   A write to a full FIFO is **not** accepted even if a read happens in the same cycle.
5. Rejected write (`wr_en && full`): data is dropped, `overflow` is set and stays set until reset.
   Rejected read (`rd_en && empty`): no state change, `underflow` is set and stays set until reset.
6. `full`, `empty` and `count` are registered outputs that reflect the state after the edge.
7. Data leaves in exactly the order it was accepted.

## 6. Verification summary

| Item | Result |
|------|--------|
| Lint (`verilator -Wall`) | |
| SV testbench | |
| cocotb tests / seeds | |
| Coverage bins closed | |
| Known limitations | |

## Hints (read only when stuck)

<details><summary>Pointer width</summary>

With `DEPTH` a power of two, using pointers one bit wider than `$clog2(DEPTH)` lets you tell
full from empty without a separate counter. Either approach is acceptable — be ready to explain
the trade-off in an interview.
</details>

<details><summary>What to cover</summary>

Think about: fill to full, drain to empty, read+write while full, read+write while empty,
back-to-back pointer wrap-around, overflow, underflow, reset with data inside.
</details>
