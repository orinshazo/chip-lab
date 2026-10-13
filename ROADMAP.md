# Roadmap — from fundamentals to computer architect

**North star:** computer / SoC architect — the person who decides how a processor or system is
built, models it before it exists, and can defend every trade-off with data.

**How this roadmap works**

- **Levels, not dates.** Each level has an *exit test*. Pass it and move on, whether that took
  one week or eight. There is no last level: the list keeps growing as you do.
- **Depth over coverage.** A level is passed when you can rebuild the result from scratch and
  explain every decision out loud, not when the code runs.
- **Every level leaves an artifact** in this repo: code, tests, a short write-up with data.
- **Career is a checkpoint, not the finish line.** Student applications open ~April 2027
  with whatever level you have reached by then (target: Level 4+).

**Target roles, in order:** Architecture / Performance-modeling student → Design Verification
student → Validation / Emulation student. All three lead to architecture; the first is the most direct.

---

## Level 0 — Foundations

Setup, Git, and the two classic RTL blocks.

- [ ] Setup: `scripts/setup_wsl.sh`, `make doctor`, `make test` green; repo on GitHub with green CI
- [ ] Git fluency: branch, commit, push, pull request, merge, rebase, resolve a conflict
- [ ] Read `projects/p00_counter` end to end; open its waveform
- [ ] HDLBits sprint: Verilog Language, Combinational, Sequential (FSMs included)
- [ ] **p01_sync_fifo** — spec given; test plan → RTL → SV tb + cocotb test → bug injection → sign-off
- [ ] **p02_uart** — TX + RX, parameterized baud, loopback test, write the spec yourself

**Exit test:** from a blank file, write a FIFO and a UART receiver in SystemVerilog, explain
full/empty detection and oversampling, and debug an injected bug from a waveform.

## Level 1 — C++ and performance modeling

The architect's main tool is a simulator. Build two.

- [ ] Modern C++ ramp: classes, RAII, STL containers/algorithms, templates basics, CMake, GoogleTest
- [ ] **p03_cache_sim** — trace-driven cache simulator: size, block size, associativity, LRU/FIFO/random,
      write-back/write-allocate, multi-level; reports hit rate and AMAT
- [ ] **p04_branch_pred** — bimodal, gshare, tournament; misprediction rate on real traces
- [ ] Python analysis: pandas + matplotlib sweeps, one plot per design question
- [ ] Write-up: "What cache configuration minimizes AMAT for this workload, and why?"

**Exit test:** given a new replacement policy or predictor, implement it, run a sweep and
present the result with a plot and a one-paragraph explanation.

## Level 2 — Verification methodology

How industry proves a design works. Applied to the blocks you already built.

- [ ] cocotb: constrained random, reference models, scoreboards, functional coverage closure
- [ ] Regression engineering: extend `scripts/regress.py` (parallel jobs, report, seeds)
- [ ] SVA: protocol checkers on FIFO and UART; `|->`, `|=>`, sequences, `$past`
- [ ] SV OOP + randomization + covergroups; one small UVM environment on EDA Playground
- [ ] Formal: prove FIFO safety properties with SymbiYosys

**Exit test:** verify a block you did not design (e.g. an arbiter from an open-source repo)
to coverage closure and find at least one corner case its tests missed.

## Level 3 — Build a processor

- [ ] **p05_rv32i** — single-cycle RV32I (no CSRs), then a 5-stage pipeline with forwarding and hazard detection
- [ ] **ISS in C++** — instruction-set simulator for the same subset (golden model)
- [ ] Verilator harness: RTL and ISS in lockstep, compare every retired instruction
- [ ] Official `riscv-tests` (rv32ui) + Python random instruction generator
- [ ] Performance counters in RTL: cycles, instructions, stalls by cause → IPC
- [ ] Write-up: IPC with/without forwarding, with static vs dynamic branch prediction (reuse p04)

**Exit test:** add a new instruction or a branch predictor to the core, verify it in lockstep,
and quantify its effect on IPC.

## Level 4 — Architecture research

Work the way architecture researchers and performance teams do.

- [ ] ChampSim: build, run SPEC-like traces, read the cache and prefetcher interfaces
- [ ] Implement a prefetcher (stride → stream → a published one) or a replacement policy (SRRIP/SHiP-style)
- [ ] Reproduce one figure from a published paper, then propose and test one improvement
- [ ] gem5 orientation: run a full-system or SE-mode simulation, read the stats

**Exit test:** a 2-page report — hypothesis, method, results, limits — that you would be
comfortable presenting to an architecture team.

## Level 5 — Advanced microarchitecture

- [ ] Out-of-order core model in C++: register renaming, ROB, issue queue, load/store queue (Tomasulo-style)
- [ ] Superscalar width and memory-level parallelism studies on the model
- [ ] Cache coherence: MESI simulator for a small multicore; false-sharing experiments
- [ ] Memory consistency models: TSO vs relaxed, litmus tests

**Exit test:** explain, with your own model's data, why a wider core stops helping on a given workload.

## Level 6 — Systems and SoC

Where your Linux and boot experience becomes an advantage.

- [ ] On-chip interconnect: AXI4-Lite/AXI4, a crossbar, a DMA engine (RTL + verification)
- [ ] Integrate a RISC-V SoC (your core or an open one) with memory, UART, timer, interrupts
- [ ] Boot firmware, then Linux, on a RISC-V SoC in simulation (Verilator) or on an FPGA
- [ ] HW/SW co-design: a driver for your own peripheral; measure end-to-end latency

**Exit test:** boot to a Linux shell on a system you integrated and explain every step from reset vector to init.

## Level 7 — Frontier (open-ended)

Pick by interest; each can be months deep.

- [ ] Domain-specific accelerators: systolic array for matrix multiply, roofline analysis
- [ ] Power and energy modeling; performance-per-watt trade-offs
- [ ] Contributions to open-source hardware/simulators (Verilator, ChampSim, CVA6, cocotb)
- [ ] Research toward an M.Sc. thesis in computer architecture

---

## Running alongside every level

| Track | What |
|------|------|
| Interview prep | `docs/interview-prep.md` — 2 topics a week from Level 1 on |
| Learning log | `LOG.md` — 3 lines per session |
| Courses | Prefer advanced computer architecture, VLSI, OS and compilers electives |
| Career | From ~Jan 2027: resume from this repo, referrals, applications in April |
