`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_fifo_vsqr extends uvm_sequencer;
    `uvm_component_utils(apb_fifo_vsqr)

    apb_fifo_sqr apb_sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

endclass //apb_fifo_vsqr