`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_fifo_agent extends uvm_agent;
    `uvm_component_utils(apb_fifo_agent)
    
    apb_fifo_sqr sqr;
    apb_fifo_driver drv;
    apb_fifo_monitor mon;
    uvm_analysis_port #(apb_fifo_txn) mon_ap; // ap for monitor's ap

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            sqr = apb_fifo_sqr::type_id::create("sqr", this);
            drv = apb_fifo_driver::type_id::create("drv", this);
        end

        mon = apb_fifo_monitor::type_id::create("mon", this);
        mon_ap = new("mon_ap", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(sqr.seq_item_export);
        end
        mon.ap.connect(mon_ap);
    endfunction

endclass //apb_fifo_agent extends uvm_agent