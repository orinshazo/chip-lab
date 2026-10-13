"""cocotb tests for counter.

Structure used across this repo:
  * CounterModel  - pure-Python reference model of the spec (no simulator code)
  * Coverage      - simple named bins; the test fails if a bin is never hit
  * tests         - drive stimulus, compare DUT vs model every cycle

Reproduce any failure with the seed printed at the top of the log:
    make cocotb SEED=<seed>
"""

import random
from dataclasses import dataclass, field

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge

WIDTH = 8
MAX = (1 << WIDTH) - 1


@dataclass
class CounterModel:
    """Cycle-accurate model of the counter spec."""

    count: int = 0
    wrap: int = 0

    def step(self, rst_n: int, en: int, load: int, load_val: int) -> None:
        if not rst_n:
            self.count, self.wrap = 0, 0
            return
        self.wrap = 0
        if load:
            self.count = load_val
        elif en:
            self.wrap = int(self.count == MAX)
            self.count = (self.count + 1) & MAX


@dataclass
class Coverage:
    bins: dict = field(default_factory=lambda: {
        "wrap": 0, "load_while_en": 0, "hold": 0, "load_max": 0, "reset_mid_run": 0,
    })

    def sample(self, rst_n: int, en: int, load: int, load_val: int, wrap: int) -> None:
        if not rst_n:
            self.bins["reset_mid_run"] += 1
            return
        self.bins["wrap"] += wrap
        self.bins["load_while_en"] += int(load and en)
        self.bins["hold"] += int(not load and not en)
        self.bins["load_max"] += int(load and load_val == MAX)

    def assert_closed(self, log) -> None:
        log.info("coverage: %s", self.bins)
        holes = [name for name, hits in self.bins.items() if hits == 0]
        assert not holes, f"coverage holes: {holes}"


async def reset(dut, cycles: int = 2) -> None:
    dut.rst_n.value = 0
    dut.en.value = 0
    dut.load.value = 0
    dut.load_val.value = 0
    await ClockCycles(dut.clk, cycles)
    dut.rst_n.value = 1


async def drive_and_check(dut, model: CounterModel, cov: Coverage,
                          rst_n: int, en: int, load: int, load_val: int) -> None:
    """Apply one cycle of stimulus, then check DUT against the model."""
    dut.rst_n.value, dut.en.value = rst_n, en
    dut.load.value, dut.load_val.value = load, load_val
    await RisingEdge(dut.clk)
    model.step(rst_n, en, load, load_val)
    await FallingEdge(dut.clk)
    got_count, got_wrap = int(dut.count.value), int(dut.wrap.value)
    assert (got_count, got_wrap) == (model.count, model.wrap), (
        f"count={got_count} wrap={got_wrap}, expected count={model.count} wrap={model.wrap}"
    )
    cov.sample(rst_n, en, load, load_val, got_wrap)


@cocotb.test()
async def test_reset_value(dut):
    """After reset the counter is 0 and wrap is low."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset(dut)
    await FallingEdge(dut.clk)
    assert int(dut.count.value) == 0
    assert int(dut.wrap.value) == 0


@cocotb.test()
async def test_random(dut):
    """Constrained-random traffic checked against the model, with coverage closure."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset(dut)
    model, cov = CounterModel(), Coverage()

    for _ in range(5000):
        rst_n = int(random.random() > 0.002)          # rare mid-run reset
        load = int(random.random() < 0.05)            # loads are uncommon
        en = int(random.random() < 0.9)
        # Bias load values towards the corners to reach the wrap quickly.
        load_val = random.choice([0, MAX, MAX - 1, random.randrange(MAX + 1)])
        await drive_and_check(dut, model, cov, rst_n, en, load, load_val)

    cov.assert_closed(dut._log)
