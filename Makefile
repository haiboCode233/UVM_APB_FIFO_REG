# ==== Tools ====
VLOG = vlog
VSIM = vsim

# ==== Top-Level Testbench ====
TOP_SRC = ./tb/test_top.sv
TOP_MODULE = test_top

# ==== Compilation Options ====
VLOG_OPTS = -sv +acc +define+UVM_NO_DEPRECATED

# ==== Default test name ====
TESTNAME ?= apb_fifo_test

# ==== Simulation Options ====
VSIM_OPTS = -c work.$(TOP_MODULE) +UVM_TESTNAME=$(TESTNAME) -do "run -all; quit"

# ============================================================
# Targets
# ============================================================

all: compile simulate

compile:
	@echo "Compiling UVM testbench..."
	$(VLOG) $(VLOG_OPTS) $(TOP_SRC)

simulate:
	@echo "Running UVM test: $(TESTNAME)"
	$(VSIM) $(VSIM_OPTS)

gui:
	@echo "Launching GUI simulation..."
	$(VSIM) work.$(TOP_MODULE)

clean:
	@echo "Cleaning work directory and temporary files..."
	rm -rf work transcript *.wlf vsim.dbg .vsim* simv* *.log *.vstf

help:
	@echo "  Makefile Usage:"
	@echo "  make               -> compile + simulate with default test ($(TESTNAME))"
	@echo "  make compile       -> compile only"
	@echo "  make simulate      -> simulate default test ($(TESTNAME))"
	@echo "  make simulate TESTNAME=your_test -> run a specific test"
	@echo "  make gui           -> launch GUI"
	@echo "  make clean         -> remove all temporary files"

