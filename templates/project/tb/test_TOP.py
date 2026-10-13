"""cocotb tests for __TOP__. See ../TESTPLAN.md for what each test covers."""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


async def reset(dut, cycles: int = 2) -> None:
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, cycles)
    dut.rst_n.value = 1


@cocotb.test()
async def test_reset(dut):
    """F1: reset values."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset(dut)
    # TODO: check reset values against the spec
