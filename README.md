# chip-lab

[![regression](https://github.com/orinshazo/chip-lab/actions/workflows/regression.yml/badge.svg)](https://github.com/orinshazo/chip-lab/actions/workflows/regression.yml)

Computer architecture, digital design and verification projects: RTL in SystemVerilog, performance
models in C++, and self-checking testbenches with Python/cocotb reference models, constrained-random
stimulus and functional coverage.
Every push runs the full regression in CI.

## Projects

| # | Block | Highlights | Status |
|---|-------|------------|--------|
| [p00](projects/p00_counter) | Parameterized counter | Reference project: SV directed tb + cocotb model, random, coverage | ✅ |
| [p01](projects/p01_sync_fifo) | Synchronous FIFO | Full/empty/overflow, scoreboard, coverage closure | 🚧 |

Planned: UART, cache and branch-predictor simulators in C++, an RV32I pipeline verified in lockstep
against a C++ ISS with performance counters, and architecture studies in ChampSim — see [ROADMAP.md](ROADMAP.md).

## Quick start (WSL2 Ubuntu 24.04)

```bash
git clone https://github.com/orinshazo/chip-lab ~/chip-lab && cd ~/chip-lab
./scripts/setup_wsl.sh      # apt tools + Python venv (idempotent)
make doctor                 # check tools
make test                   # full regression
make -C projects/p00_counter waves   # open a waveform
```

## Layout

```
projects/pNN_name/   one block each: README (spec) · TESTPLAN · rtl/ · tb/ · Makefile
common/mk/           shared make rules (lint, SV tb, cocotb, waves)
scripts/             setup, regression runner, project generator
templates/project/   skeleton used by `make new`
docs/                workflow, conventions, interview prep, resources
```

## Toolchain

Icarus Verilog 12 · Verilator 5 · cocotb 2 · Python 3.12 · GTKWave · Yosys · GitHub Actions
