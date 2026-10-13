# p01_sync_fifo — Test plan

Write this **before** the RTL. Every row must map to a check or a coverage bin in the testbench.

## Features to verify

| ID | Feature (from spec §) | How it is checked | Coverage bin(s) | Test | Status |
|----|-----------------------|-------------------|-----------------|------|--------|
| F1 | Reset values (§4) | model compare after reset | — | `test_reset` | ☐ |
| F2 | | | | | ☐ |

## Stimulus strategy

Directed tests for: …
Constrained random for: … (list the knobs and their distributions)

## Checkers

- Reference model: …
- Assertions / protocol checks: …

## Coverage goals

| Bin | Definition | Goal |
|-----|------------|------|
|     |            | ≥ 1 hit |

## Out of scope

What is intentionally not verified and why.
