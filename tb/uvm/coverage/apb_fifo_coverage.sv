import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_fifo_coverage extends  uvm_component;
    `uvm_component_utils(apb_fifo_coverage)
    
    uvm_analysis_imp #(apb_fifo_txn, apb_fifo_coverage) ap_imp;
    
    apb_fifo_txn txn;

    covergroup cg_apb_txn;
        option.per_instance = 1;
        option.name = "cg_apb_txn";

        rdwr : coverpoint txn.write {
            bins write = {1};
            bins read = {0};
        }
        
        addr : coverpoint txn.addr {
            bins fifo = {[32'h00 : 32'hFF]};
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

    covergroup cg_fifo_behavior;
        option.per_instance = 1;
        option.name = "cg_apb_txn";

        occupancy : coverpoint txn.write {
        }


    endgroup
    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap_imp = new("ap_imp", this);
        cg_apb_txn = new();
    endfunction //new()

    function void build_phase(uvm_phase phase);
        ;
    endfunction

    function void write(apb_fifo_txn t);
        txn = t;
        cg_apb_txn.sample();
    endfunction
endclass //apb_fifo_coverage extends uvm_component