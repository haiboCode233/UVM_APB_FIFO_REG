import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_fifo_coverage extends  uvm_component;
    `uvm_component_utils(apb_fifo_coverage)
    
    uvm_analysis_imp #(apb_fifo_txn, apb_fifo_coverage) ap_imp;
    
    apb_fifo_txn txn;
    int unsigned fifo_depth;

    covergroup cg_apb_txn;
        option.per_instance = 1;
        option.name = "cg_apb_txn";

        rdwr : coverpoint txn.write {
            bins write = {1};
            bins read = {0};
        }
        
        addr : coverpoint txn.addr {
            bins fifo = {32'h0000_0000};
            bins regs = {[32'h8000_0000 : 32'h8000_00FF]};
            bins illegal = default;
            }

        data : coverpoint txn.wdata {
            bins zero = {32'h0000_0000};
            bins ones = {32'hFFFF_FFFF};
            bins alt1 = {32'hAAAA_AAAA};
            bins alt2 = {32'h5555_5555};
            bins normal = default;
        }

        strb : coverpoint txn.strob {
            bins mask1 = {4'b0001};
            bins mask2 = {4'b0011};
            bins mask3 = {4'b0111};
            bins mask4 = {4'b1111};
            bins other = default;
        }

        gaps : coverpoint txn.gap_cycles {
            bins b2b = {0};
            bins one = {1};
            bins two = {2};
            bins normal = default;
        }

        slve : coverpoint txn.error {
            bins good = {0};
            bins bad = {1}; 
        }

        x_addr_slverr : cross addr, slve;
        x_rdwr_gap : cross rdwr, gaps;

    endgroup

    
    bit status_empty, status_full;
    int status_occupancy;

    covergroup cg_fifo_behavior;
        option.per_instance = 1;
        option.name = "cg_apb_txn";

        empty: coverpoint status_empty {
            bins not_empty = {0};
            bins is_empty = {1};
        }

        full: coverpoint status_full {
            bins not_full = {0};
            bins is_full = {1};
        }

        occupancy: coverpoint status_occupancy {
            bins low = {[0:2]};
            bins high = {[fifo_depth-2: fifo_depth]};
        }

        cross status_empty, status_full;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap_imp = new("ap_imp", this);
        cg_apb_txn = new();
        cg_fifo_behavior = new();
    endfunction //new()

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db#(int unsigned)::get(this, "", "FIFO_DEPTH", fifo_depth))
            `uvm_fatal("COV", "fifo_depth not set in config_db!");
        // `uvm_info("COV", $sformatf("fifo depth is configured to: %d", fifo_depth), UVM_LOW);
    endfunction

    function void write(apb_fifo_txn t);
        txn = t;
        cg_apb_txn.sample();
    endfunction

    task sample_status(bit empty, bit full, int occupancy);
        status_empty = empty;
        status_full = full;
        status_occupancy = occupancy;
        cg_fifo_behavior.sample();
    endtask

endclass //apb_fifo_coverage extends uvm_component