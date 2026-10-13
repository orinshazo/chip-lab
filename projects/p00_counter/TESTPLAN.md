# p00_counter — Test plan

## Features to verify

| ID | Feature (spec §4) | How it is checked | Coverage bin | Test | Status |
|----|-------------------|-------------------|--------------|------|--------|
| F1 | Reset → count = 0, wrap = 0 | direct check | `reset_mid_run` | `test_reset_value`, `test_random`, `counter_tb` step 5 | ✅ |
| F2 | Increment when `en` | model compare every cycle | — | `test_random`, `counter_tb` step 1 | ✅ |
| F3 | Hold when `!en && !load` | model compare | `hold` | `test_random`, `counter_tb` step 2 | ✅ |
| F4 | Load, priority over `en` | model compare | `load_while_en` | `test_random`, `counter_tb` step 3 | ✅ |
| F5 | Wrap MAX → 0 with 1-cycle `wrap` pulse | model compare | `wrap`, `load_max` | `test_random`, `counter_tb` steps 1, 4 | ✅ |

## Stimulus strategy

- **Directed** (`counter_tb.sv`): one scenario per feature, small `WIDTH` so the wrap is reached quickly.
- **Constrained random** (`test_random`): per cycle `en` 90 %, `load` 5 %, reset 0.2 %;
  `load_val` biased to `{0, MAX, MAX−1, random}` so wraps happen often.

## Checkers

- Reference model: `CounterModel` (Python) and the `exp_*` model in `counter_tb.sv`, compared every cycle.

## Coverage goals

Each bin ≥ 1 hit per seed; the test fails on any hole.

## Out of scope

Formal proof of the wrap property (revisited in Phase 3).
