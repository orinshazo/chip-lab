# Project workflow

Every block goes through the same six steps. This is a scaled-down version of how a DV team works.

```
 spec ──► test plan ──► RTL ──► testbench ──► regression ──► sign-off
  │           │          │          │              │             │
README §1-5  TESTPLAN  rtl/*.sv   tb/*         make test    README §6 + LOG.md
```

| Step | Output | Done when |
|------|--------|-----------|
| 1. Spec | `README.md` §1–5 | A reference model could be written from §4 alone |
| 2. Test plan | `TESTPLAN.md` | Every spec rule maps to a check or coverage bin |
| 3. RTL | `rtl/*.sv` | `make lint` is clean |
| 4. Testbench | `tb/*_tb.sv` (directed) and `tb/test_*.py` (model + random + coverage) | Tests fail on an injected bug |
| 5. Regression | `make -C projects/<p> test`, then `scripts/regress.py --seeds 20 <p>` | 20 seeds green, no coverage holes |
| 6. Sign-off | README §6 filled, `.wip` deleted, PR merged | CI green on `main` |

## Bug injection (step 4)

A testbench that never fails proves nothing. Before sign-off, break the RTL on purpose
(off-by-one, wrong priority, missing reset) and confirm a test catches each one.
Record what you tried in `TESTPLAN.md` → *Bug injection*.

## Git flow

```bash
git switch -c p01-fifo            # one branch per project or feature
git commit -m "p01: add FIFO test plan"
git push -u origin p01-fifo       # open a PR, CI must be green, review, squash-merge
```

Debugging loop for a failing seed:

1. Copy the seed from the log → `make -C projects/<p> cocotb SEED=<n>`
2. Find the first mismatch time in the log
3. `make -C projects/<p> waves SEED=<n>` → look at that time
4. Decide: RTL bug, model bug, or spec ambiguity (→ fix the spec first)
