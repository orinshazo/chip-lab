# chip-lab top-level Makefile. Per-project targets live in projects/*/Makefile.
SHELL := /bin/bash
VENV  := .venv/bin
PY    := $(if $(wildcard $(VENV)/python),$(VENV)/python,python3)
export PATH := $(CURDIR)/$(VENV):$(PATH)

.DEFAULT_GOAL := help
.PHONY: help doctor test regress lint list new clean

help: ## Show this help
	@grep -hE '^[a-z]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-8s %s\n", $$1, $$2}'

doctor: ## Check that every tool is installed and print versions
	@ok=1; for t in git make python3 iverilog vvp verilator gtkwave yosys; do \
	  if command -v $$t >/dev/null; then printf "  %-10s ok\n" $$t; else printf "  %-10s MISSING\n" $$t; ok=0; fi; \
	done; \
	printf "  %-10s " cocotb; $(PY) -c "import cocotb; print(cocotb.__version__)" 2>/dev/null || { echo MISSING; ok=0; }; \
	printf "  %-10s " verilator; verilator --version 2>/dev/null | awk '{print $$2}'; \
	[ $$ok = 1 ] && echo "All tools present." || { echo "Run scripts/setup_wsl.sh"; exit 1; }

test: ## Run the full regression once (all non-wip projects)
	@$(PY) scripts/regress.py

regress: ## Run the regression over 5 random seeds
	@$(PY) scripts/regress.py --seeds 5

lint: ## Lint every project's RTL
	@set -e; for p in projects/*/; do [ -f $$p/.wip ] || $(MAKE) --no-print-directory -C $$p lint; done

list: ## List projects and their status
	@for p in projects/*/; do n=$$(basename $$p); \
	  if [ -f $$p/.wip ]; then echo "  $$n  (wip)"; else echo "  $$n"; fi; done

new: ## Create a project: make new NAME=p02_uart TOP=uart_top
	@scripts/new_project.sh "$(NAME)" "$(TOP)"

clean: ## Remove all build outputs
	@rm -rf build projects/*/build
