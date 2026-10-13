# Roadmap — Student to Verification-Ready (Oct 2026 → Jul 2027)

**Goal:** apply for student positions in Design Verification (primary), CAD / Design
Automation and Pre/Post-Silicon Validation (secondary) with a portfolio that proves it.

**Budget:** 4–6 hours/week, ~36 weeks ≈ 180 hours. Applications open from ~April 2027.

**Exit criteria** (what "ready" means on the day you apply):

- [ ] Can design and explain a FIFO, UART, FSM-based controller and pipelined datapath in SystemVerilog
- [ ] Can build a self-checking, constrained-random testbench with a reference model, scoreboard and functional coverage
- [ ] Can read and write SystemVerilog classes, constraints, covergroups and SVA; knows the UVM component structure
- [ ] Owns a capstone (RV32I core) verified against a C++ reference model, with nightly-style regression in CI
- [ ] Comfortable in Python for tooling: argparse, subprocess, regex, file/log parsing, pytest
- [ ] Has answered every item in [`docs/interview-prep.md`](docs/interview-prep.md) out loud at least once

---

## Weekly rhythm (≈5 h)

| Slot | Time | What |
|------|------|------|
| Theory | 1.5 h | Read / watch the week's topic, take notes in `LOG.md` |
| Build ×2 | 3 h | Two focused sessions on the current project (spec → RTL → TB → regress) |
| Review | 0.5 h | Commit, update `LOG.md`, tick the checklist below, plan next week |

During Technion exam periods (≈ late Jan–Feb, ≈ July) switch to **maintenance mode**:
1 h/week of interview questions only. The schedule below already has buffer weeks for this.

---

## Phase 0 — Setup (Week 1)

- [ ] Run `scripts/setup_wsl.sh`, then `make doctor` and `make test` — all green
- [ ] Create a GitHub repo `chip-lab`, push, confirm the CI badge is green
- [ ] Open a waveform of `p00_counter` in GTKWave (`make -C projects/p00_counter waves`)
- [ ] Read `docs/workflow.md` and `docs/conventions.md` end to end
- [ ] Read every file in `projects/p00_counter` — it is the reference for how every project should look

**Deliverable:** green CI on GitHub.

## Phase 1 — RTL & SystemVerilog foundations (Weeks 2–7)

Theory: synthesizable SV (`always_ff`/`always_comb`, `logic`, enums, packages), FSM coding styles,
blocking vs non-blocking, reset strategies, setup/hold, CDC basics. HDLBits: finish "Verilog Language"
and "Circuits → Sequential Logic".

- [ ] **p01_sync_fifo** — parameterized synchronous FIFO (starter is in the repo)
  - [ ] Spec + test plan reviewed before any RTL
  - [ ] Directed SV testbench (`tb/*_tb.sv`) + cocotb test, both self-checking
  - [ ] Lint-clean with `verilator -Wall`
- [ ] **p02_uart** — UART TX + RX (8N1, parameterized baud divisor), loopback test
- [ ] Python track: functions, classes, `dataclasses`, list/dict comprehensions, `pathlib`

**Deliverable:** two projects, each with spec, test plan, passing regression.

## Phase 2 — Verification with Python / cocotb (Weeks 8–13, incl. exam buffer)

Theory: verification planning, stimulus/checker/coverage separation, reference models,
scoreboards, constrained random, seeds and reproducibility, functional vs code coverage.

- [ ] **p03_alu** — 32-bit ALU; Python golden model; constrained-random stimulus; coverage of every opcode × corner operand
- [ ] Upgrade p01/p02 tests: random traffic + scoreboard + coverage closure report
- [ ] Extend `scripts/regress.py`: parallel runs (`--jobs`), per-test timing, HTML or Markdown report
- [ ] Python track: `argparse`, `subprocess`, `re`, `logging`, `pytest` for the regression script itself

**Deliverable:** coverage-driven verification on three blocks; a regression tool you wrote and can talk about.

## Phase 3 — Industry methodology: SV-OOP, SVA, UVM, Formal (Weeks 14–20)

Theory: SV classes, `rand`/`constraint`, mailboxes, virtual interfaces, covergroups, SVA
(immediate/concurrent, implication, sequences), UVM (agent/driver/monitor/sequencer/scoreboard/env/test,
factory, phases, TLM). Book: Spear & Tumbush, *SystemVerilog for Verification*.

- [ ] **p04_apb_regs** — APB slave register block
  - [ ] SVA protocol checker bound to the interface
  - [ ] Full UVM environment on EDA Playground (commercial simulator, free account); link the playground in the README
  - [ ] Same block checked with cocotb locally
- [ ] Formal: prove FIFO properties (never overflow, data order) with SymbiYosys (`sby`)

**Deliverable:** one block verified three ways (UVM, cocotb, formal) — strong interview material.

## Phase 4 — Capstone: RV32I core + C++ reference model (Weeks 21–32, incl. exam buffer)

- [ ] **p05_rv32i** — single-cycle RV32I (no CSRs), then refactor to a 5-stage pipeline with forwarding and hazard detection
- [ ] **ISS in C++** — instruction-set simulator for the same subset (your golden model)
- [ ] Verilator C++ harness that runs RTL and ISS in lockstep and compares retired PC/register writes every instruction
- [ ] Run the official `riscv-tests` (rv32ui) and a Python random-instruction generator
- [ ] Coverage: every opcode, every hazard type, branch taken/not-taken
- [ ] CI runs the full suite on every push; README with block diagram and results

**Deliverable:** the project that headlines your resume.

## Phase 5 — Career (Weeks 28–36, overlaps Phase 4)

- [ ] Update `resume_verification.tex`: Projects section from this repo, coursework list, skills
- [ ] Polish GitHub: pinned repo, README with diagrams, clean commit history
- [ ] Interview prep: go through `docs/interview-prep.md`, 2 topics/week, answer out loud
- [ ] 2 mock interviews (friends in the industry / Technion career center)
- [ ] Referral list: 10 people in target companies; ask for referrals once the capstone is public
- [ ] Apply: DV students first, then CAD / Validation / Emulation

---

## Checkpoints

| When | Check | If behind |
|------|-------|-----------|
| End of Week 7 | p01 + p02 done | Drop p02 RX, keep TX |
| End of Week 13 | p03 + coverage-driven upgrades | Skip regress.py extensions |
| End of Week 20 | p04 with UVM + SVA | Skip formal |
| End of Week 32 | RV32I pipeline passes rv32ui | Ship single-cycle + lockstep; pipeline as "in progress" |
