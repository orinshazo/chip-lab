# -----------------------------------------------------------------------------
# Shared build/test rules. Every project Makefile sets TOP and includes this file:
#
#   TOP := my_module
#   include ../../common/mk/project.mk
#
# Conventions (see docs/conventions.md):
#   rtl/*.sv          synthesizable RTL           -> linted, simulated
#   tb/*_tb.sv        SystemVerilog testbenches   -> `make svtb`  (top module = file name)
#   tb/test_*.py      cocotb test modules         -> `make cocotb`
# -----------------------------------------------------------------------------

PROJ_DIR  := $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
REPO_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
BUILD     := $(PROJ_DIR)/build

# Use the repo's virtualenv (created by scripts/setup_wsl.sh) without activating it.
ifneq ($(wildcard $(REPO_ROOT)/.venv/bin),)
export PATH := $(REPO_ROOT)/.venv/bin:$(PATH)
endif

ifndef TOP
$(error TOP is not set. Set `TOP := <rtl top module>` before including project.mk)
endif

RTL_SRCS     ?= $(sort $(wildcard $(PROJ_DIR)/rtl/*.sv))
SV_TBS       ?= $(sort $(wildcard $(PROJ_DIR)/tb/*_tb.sv))
TEST_MODULES ?= $(basename $(notdir $(sort $(wildcard $(PROJ_DIR)/tb/test_*.py))))
SIM          ?= icarus
SEED         ?=
WAVES        ?= 0

IVERILOG_FLAGS ?= -g2012 -Wall -Wno-timescale
LINT_FLAGS     ?= --lint-only -Wall

COCOTB_ENV := PYTHONPATH=$(PROJ_DIR)/tb$(if $(PYTHONPATH),:$(PYTHONPATH)) \
              $(if $(SEED),COCOTB_RANDOM_SEED=$(SEED))

.DEFAULT_GOAL := help
.PHONY: help test cocotb svtb lint waves clean

help: ## Show this help
	@echo "Project: $(notdir $(PROJ_DIR))   top: $(TOP)"
	@grep -hE '^[a-z]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-8s %s\n", $$1, $$2}'
	@echo "  Variables: SEED=<n>  WAVES=1  SIM=icarus|verilator"

test: lint svtb cocotb ## Lint + all SV testbenches + all cocotb tests

lint: ## Lint RTL with Verilator -Wall
	@echo "== lint: $(TOP)"
	@verilator $(LINT_FLAGS) --top-module $(TOP) $(RTL_SRCS)

svtb: ## Run every tb/*_tb.sv with Icarus (fails on error or a missing TEST PASSED)
	@mkdir -p $(BUILD)
	@set -e; for tb in $(SV_TBS); do \
	  name=$$(basename $$tb .sv); \
	  echo "== svtb: $$name"; \
	  iverilog $(IVERILOG_FLAGS) -s $$name -o $(BUILD)/$$name.vvp $(RTL_SRCS) $$tb; \
	  (cd $(BUILD) && vvp -n $$name.vvp $(if $(SEED),+seed=$(SEED))) | tee $(BUILD)/$$name.log; \
	  grep -q "TEST PASSED" $(BUILD)/$$name.log || { echo "FAIL: $$name did not report TEST PASSED"; exit 1; }; \
	done

cocotb: ## Run cocotb tests (SEED=<n> to reproduce a run)
	@if [ -z "$(TEST_MODULES)" ]; then echo "== cocotb: no tb/test_*.py, skipping"; exit 0; fi
	@mkdir -p $(BUILD)
	@echo "== cocotb: $(TEST_MODULES)"
	@cd $(BUILD) && $(COCOTB_ENV) $(MAKE) --no-print-directory -f $(REPO_ROOT)/common/mk/cocotb.mk \
	    SIM=$(SIM) TOP=$(TOP) RTL_SRCS="$(RTL_SRCS)" TEST_MODULES="$(TEST_MODULES)" WAVES=$(WAVES)
	@! grep -q "<failure" $(BUILD)/results.xml

waves: ## Re-run cocotb with waveform dump and open GTKWave
	@$(MAKE) --no-print-directory cocotb WAVES=1
	@f=$$(find $(BUILD) -name '*.fst' -o -name '*.vcd' | head -1); \
	 if [ -z "$$f" ]; then echo "no waveform found"; exit 1; fi; \
	 echo "opening $$f"; gtkwave $$f >/dev/null 2>&1 &

clean: ## Remove build outputs
	rm -rf $(BUILD)
