# Interview prep — question bank

Answer each one **out loud**, then write a 3-line answer in `LOG.md`. Tick when you can answer
without notes. Target: everything ticked by Week 34.

## Digital design

- [ ] Setup and hold time — definitions, what violates each, how to fix each
- [ ] Max clock frequency of a path; effect of clock skew (positive/negative)
- [ ] Mealy vs Moore; design a sequence detector (e.g. 1011) both ways
- [ ] Blocking vs non-blocking assignments — show a race
- [ ] Latch vs flip-flop; how latches get inferred by mistake
- [ ] Synchronous vs asynchronous reset — pros/cons, reset synchronizer
- [ ] Metastability, 2-flop synchronizer, MTBF intuition
- [ ] CDC: single-bit vs multi-bit; why Gray code for async FIFO pointers
- [ ] FIFO: full/empty detection; minimum depth for a given burst/rate (classic calculation)
- [ ] Clock divider by 2, by 3 (50 % duty)
- [ ] Edge detector, debouncer, round-robin arbiter
- [ ] One-hot vs binary FSM encoding trade-offs
- [ ] Pipelining: throughput vs latency; data/control/structural hazards; forwarding
- [ ] Caches: direct-mapped vs set-associative, write-back vs write-through, AMAT

## Verification

- [ ] What is a test plan; how does it map to coverage
- [ ] Code coverage vs functional coverage; why 100 % code coverage is not enough
- [ ] Directed vs constrained random — when each wins
- [ ] Scoreboard and reference model — how to handle out-of-order or latency
- [ ] How to debug a failing random seed (your actual process)
- [ ] SV: `rand` vs `randc`, constraints, `solve…before`, `pre_randomize`
- [ ] SV: covergroup, coverpoint, cross, bins, illegal/ignore bins
- [ ] SVA: `|->` vs `|=>`, `##[1:3]`, `$rose/$fell/$stable/$past`, write "req is followed by ack within 4 cycles"
- [ ] UVM: components of an agent; `uvm_component` vs `uvm_object`; phases; factory override; config_db; sequences vs sequencer
- [ ] Virtual interface — why it exists
- [ ] Formal vs simulation — what each can prove
- [ ] How you would verify a FIFO / an arbiter / an ALU (whiteboard a testbench)

## Programming & tools

- [ ] Python: parse a log, extract all failing test names + seeds with regex
- [ ] Python: write a small CLI with argparse that runs N subprocesses and summarizes results
- [ ] Python: classes vs dataclasses; generators; dict/set comprehensions
- [ ] C/C++: pointers, `const`, references, virtual functions, memory layout (stack/heap)
- [ ] Bit tricks: count set bits, check power of two, reverse bits
- [ ] Linux: grep/sed/awk one-liners, find + xargs, processes, file permissions, ssh
- [ ] Git: rebase vs merge, resolving conflicts, bisect

## About you (prepare stories)

- [ ] 60-second introduction (army role → Technion → why verification)
- [ ] Your capstone: architecture, how you verified it, the hardest bug
- [ ] A time you debugged something hard in the army (Linux boot / GRUB story)
- [ ] Questions to ask the interviewer
