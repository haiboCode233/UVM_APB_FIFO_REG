`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_fifo_monitor extends uvm_monitor;
    `uvm_component_utils(apb_fifo_monitor)

    // vif
    virtual apb_if.MONITOR vif;

    // ap
    uvm_analysis_port #(apb_fifo_txn) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        if(!uvm_config_db#(virtual apb_if)::get(this,"","vif",vif))
            `uvm_fatal("NOVIF", "Failed to get interface handle")
    endfunction

    task run_phase(uvm_phase phase);
        apb_fifo_txn txn;

        forever begin
        @(vif.mon_cb) begin
        if (vif.mon_cb.PSEL && vif.mon_cb.PENABLE && vif.mon_cb.PREADY) begin
            txn = apb_fifo_txn::type_id::create("txn", this);

            txn.addr   = vif.mon_cb.PADDR;
            txn.strob  = vif.mon_cb.PSTRB;
            txn.write  = vif.mon_cb.PWRITE;
            txn.wdata  = vif.mon_cb.PWDATA;
            txn.rdata  = vif.mon_cb.PRDATA;
            txn.error  = vif.mon_cb.PSLVERR;

            // uvm info
            `uvm_info("MON", txn.convert2string(), UVM_LOW)

            // ap broadcast
            ap.write(txn);
            end
        end
    end
    endtask
endclass //apb_fifo_monitor extends uvm_monitor