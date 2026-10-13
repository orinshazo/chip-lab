# Conventions

## RTL (SystemVerilog)

- One module per file; file name = module name; `lower_snake_case`.
- `logic` everywhere; `always_ff` for flops (non-blocking `<=`), `always_comb` for logic (blocking `=`).
- Synchronous active-low reset named `rst_n`; every flop that matters has a reset value.
- Parameters `UPPER_SNAKE`; localparams `CamelCase`; signals `lower_snake`; active-low suffix `_n`.
- No latches: every `always_comb` assigns every output on every path (default assignment at the top).
- No `initial` blocks or `#delays` in RTL.
- Must pass `verilator --lint-only -Wall` with zero warnings (use targeted `/* verilator lint_off */` only with a comment saying why).

## Testbenches

- **SV directed tb**: `tb/<module>_tb.sv`, self-checking, prints `TEST PASSED`, calls `$fatal` on error.
- **cocotb**: `tb/test_<module>.py`, structured as *model → coverage → tests* (see `p00_counter`).
- Drive inputs after the rising edge, sample outputs on the falling edge (or `ReadOnly`) — no races.
- Every random test logs its seed and closes its coverage bins; a hole is a failure.
- Never compare against values computed from DUT outputs — only against the model.

## Python

- Python ≥ 3.12, type hints on public functions, `dataclasses` for models, f-strings.
- Scripts use `argparse`, return an exit code from `main()`, and never hard-code absolute paths.

## Git

- Branch per project/feature: `p02-uart`, `infra-regress-jobs`.
- Commit messages: `<scope>: <imperative summary>` — e.g. `p01: fix full flag on simultaneous rd/wr`.
- Do not commit `build/`, `.venv/`, waveforms or simulator outputs (`.gitignore` handles it).
