`include "uvm_macros.svh"
import uvm_pkg::*;

class seq_fifo_01 extends uvm_sequence #(apb_fifo_txn);
    `uvm_object_utils(seq_fifo_01)
    
    apb_fifo_vsqr vsqr;
    apb_fifo_seq wr_seq;
    apb_fifo_seq rd_seq;
    uvm_status_e status;
    uvm_reg_data_t read_val;

    function new(string name = "seq_fifo_01");
        super.new(name);
    endfunction

    /*
        TestID: FIFO_01
        Description: Write and Read Once
    */
    task body();
        if (!$cast(vsqr, m_sequencer)) begin
            `uvm_fatal("FIFO_01", "Cannot cast m_sequencer to apb_fifo_vsqr")
        end

        // configure depth to 8
        vsqr.rgm.reg0.write(
            .status(status),
            .value(6'b00_0001),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );
    
        wr_seq = apb_fifo_seq::type_id::create($sformatf("wr_01"));
        wr_seq.op_type = FIFO_WRITE;
        wr_seq.start(vsqr.apb_sqr);

        rd_seq = apb_fifo_seq::type_id::create($sformatf("rd_01"));
        rd_seq.op_type = FIFO_READ;
        rd_seq.start(vsqr.apb_sqr);
    endtask
endclass