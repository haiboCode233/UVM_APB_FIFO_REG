`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_fifo_monitor extends uvm_monitor;
    `uvm_component_utils(apb_fifo_monitor)

    // vif
    virtual apb_if.MONITOR vif;
    //bfm
    apb_fifo_bfm bfm;

    // ap
    uvm_analysis_port #(apb_fifo_txn) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        if(!uvm_config_db#(virtual apb_if)::get(this,"","vif",vif))
            `uvm_fatal("MON", "Failed to get interface handle")

        if(!uvm_config_db#(apb_fifo_bfm)::get(this,"","bfm",bfm))
            `uvm_fatal("MON", "Failed to get BFM handle")
    endfunction

    task run_phase(uvm_phase phase);
        apb_fifo_txn txn;
        forever begin
            txn = apb_fifo_txn::type_id::create("txn", this);
            bfm.sample_txn(txn);
            if(txn != null) begin
                // uvm info
                `uvm_info("MON", txn.convert2string(), UVM_LOW)
                
                // ap broadcast
                ap.write(txn);
            end
        end
    endtask
endclass //apb_fifo_monitor extends uvm_monitor