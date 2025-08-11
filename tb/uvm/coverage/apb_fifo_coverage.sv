import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_fifo_coverage extends  uvm_component;
    `uvm_component_utils(apb_fifo_coverage)
    
    uvm_analysis_imp #(apb_fifo_txn, apb_fifo_coverage) ap_imp;
    
    apb_fifo_txn txn;

    covergroup cg_test;
        coverpoint txn.addr {bins legal = {[32'h0:32'hFF]};}
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap_imp = new("ap_imp", this);
        cg_test = new();
    endfunction //new()

    function void build_phase(uvm_phase phase);
        ;
    endfunction

    function void write(apb_fifo_txn t);
        txn = t;
        cg_test.sample();
    endfunction
endclass //apb_fifo_coverage extends uvm_component