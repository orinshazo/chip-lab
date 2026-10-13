# Thin wrapper around cocotb's own makefiles. Invoked by project.mk from the
# project's build/ directory -- do not call directly.

TOPLEVEL_LANG       := verilog
VERILOG_SOURCES     := $(RTL_SRCS)
COCOTB_TOPLEVEL     := $(TOP)
COCOTB_TEST_MODULES := $(TEST_MODULES)

ifeq ($(SIM),verilator)
EXTRA_ARGS += --timing -Wno-fatal
ifeq ($(WAVES),1)
EXTRA_ARGS += --trace-fst --trace-structs
endif
endif

include $(shell cocotb-config --makefiles)/Makefile.sim
