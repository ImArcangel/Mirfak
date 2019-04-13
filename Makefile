# ------------------------------------------------------------------------------
# Copyright (c) 2019 Angel Terrones <angelterrones@gmail.com>
# ------------------------------------------------------------------------------
include tests/verilator/pprint.mk
SHELL=bash

# ------------------------------------------------------------------------------
SUBMAKE			= $(MAKE) --no-print-directory
ROOT			= $(shell pwd)
BFOLDER			= $(ROOT)/build
VCOREMK			= $(ROOT)/tests/verilator

TBEXE			= $(BFOLDER)/core.exe --timeout 50000000 --file
UCGEN			= $(ROOT)/rtl/ucontrolgen.py
PYTHON			= python3
UCONTROL		= $(BFOLDER)/ucontrol.mem

# Compliance tests
RVCOMPLIANCE = $(ROOT)/tests/riscv-compliance
# xint test
RVXTRASF       = $(ROOT)/tests/extra-tests

# export variables
export RISCV_PREFIX ?= riscv-none-embed-
export ROOT
export UFILE = $(UCONTROL)

# ------------------------------------------------------------------------------
# targets
# ------------------------------------------------------------------------------
help:
	@echo -e "--------------------------------------------------------------------------------"
	@echo -e "Please, choose one target:"
	@echo -e "- install-compliance:         Clone the riscv-compliance test."
	@echo -e "- build-model:                Build C++ core model."
	@echo -e "- core-sim-compliance:        Execute the compliance tests."
	@echo -e "- core-sim-compliance-rv32i:  Execute the RV32I compliance tests."
	@echo -e "- core-sim-compliance-rv32im: Execute the RV32IM compliance tests."
	@echo -e "- core-sim-compliance-rv32mi: Execute machine mode compliance tests."
	@echo -e "- core-sim-compliance-rv32ui: Execute the RV32I compliance tests (redundant)."
	@echo -e "--------------------------------------------------------------------------------"

# ------------------------------------------------------------------------------
# Install repo
# ------------------------------------------------------------------------------
install-compliance:
	@./scripts/install_compliance
# ------------------------------------------------------------------------------
# compliance tests
# ------------------------------------------------------------------------------
core-sim-compliance: core-sim-compliance-rv32i core-sim-compliance-rv32ui core-sim-compliance-rv32im core-sim-compliance-rv32mi

core-sim-compliance-rv32i: build-core
	@$(SUBMAKE) -C $(RVCOMPLIANCE) variant RISCV_TARGET=mirfak RISCV_DEVICE=rv32i RISCV_ISA=rv32i

core-sim-compliance-rv32im: build-core
	@$(SUBMAKE) -C $(RVCOMPLIANCE) variant RISCV_TARGET=mirfak RISCV_DEVICE=rv32im RISCV_ISA=rv32im

core-sim-compliance-rv32mi: build-core
	@$(SUBMAKE) -C $(RVCOMPLIANCE) variant RISCV_TARGET=mirfak RISCV_DEVICE=rv32mi RISCV_ISA=rv32mi

core-sim-compliance-rv32ui: build-core
	@$(SUBMAKE) -C $(RVCOMPLIANCE) variant RISCV_TARGET=mirfak RISCV_DEVICE=rv32ui RISCV_ISA=rv32ui
# ------------------------------------------------------------------------------
# verilate and build
# ------------------------------------------------------------------------------
build-core: $(UCONTROL)
	+@$(SUBMAKE) -C $(VCOREMK)

# ------------------------------------------------------------------------------
# verilate and build
$(UCONTROL): $(UCGEN)
	@mkdir -p $(BFOLDER)
	@$(PYTHON) $(UCGEN) $(UCONTROL)

# ------------------------------------------------------------------------------
# clean
# ------------------------------------------------------------------------------
clean:
	@$(SUBMAKE) -C $(VCOREMK) clean

distclean: clean
	@$(SUBMAKE) -C $(RVCOMPLIANCE) clean
	@rm -rf $(BFOLDER)
