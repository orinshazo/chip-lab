"""cocotb tests for sync_fifo. See ../TESTPLAN.md.

Suggested structure (same as p00_counter/tb/test_counter.py):
  1. FifoModel  - Python model of spec §4 (a collections.deque is a good start)
  2. Coverage   - named bins from your TESTPLAN; fail on holes
  3. tests      - test_reset, directed corner cases, test_random with a scoreboard
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge


async def reset(dut, cycles: int = 2) -> None:
    dut.rst_n.value = 0
    dut.wr_en.value = 0
    dut.rd_en.value = 0
    dut.wr_data.value = 0
    await ClockCycles(dut.clk, cycles)
    dut.rst_n.value = 1


@cocotb.test()
async def test_reset(dut):
    """F1: reset values (spec §4.1)."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset(dut)
    await FallingEdge(dut.clk)
    assert int(dut.empty.value) == 1
    assert int(dut.full.value) == 0
    assert int(dut.count.value) == 0
    assert int(dut.overflow.value) == 0
    assert int(dut.underflow.value) == 0


# TODO: FifoModel, Coverage, directed tests, test_random
