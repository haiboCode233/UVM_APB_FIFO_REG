# ==== Tools ====
VLOG = vlog
VSIM = vsim

# ==== Top-Level Testbench ====
TOP_SRC = ./tb/test_top.sv
DUT_SRC = ./dut/fifo.sv
TOP_MODULE = test_top

# ==== Compilation Options ====
VLOG_OPTS = -sv +acc +define+UVM_NO_DEPRECATED

# ==== Default test name ====
TESTNAME ?= apb_fifo_test
TESTID ?= REG_01

# ==== Simulation Options ====
VSIM_OPTS = -c -coverage work.$(TOP_MODULE) +UVM_TESTNAME=$(TESTNAME) +TEST_ID=$(TESTID) -do "run -all; coverage save cov.ucdb; quit -f"

# ============================================================
# Targets
# ============================================================

all: compile simulate

compile:
	@echo "Compiling UVM testbench..."
	$(VLOG) $(VLOG_OPTS) $(DUT_SRC) $(TOP_SRC)

simulate:
	@echo "Running UVM test: $(TESTNAME)"
	$(VSIM) $(VSIM_OPTS)

gui:
	@echo "Launching GUI simulation with test: $(TESTNAME), ID: $(TESTID)"
	$(VSIM) work.$(TOP_MODULE) +TEST_ID=$(TESTID)

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

