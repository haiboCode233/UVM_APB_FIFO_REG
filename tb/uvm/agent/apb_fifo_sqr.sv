class apb_fifo_sqr extends uvm_sequencer #(apb_fifo_txn);
    `uvm_component_utils(apb_fifo_sqr)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

endclass //apb_fifo_sqr extends uvm_sequencer #(apb_fifo_txn)
