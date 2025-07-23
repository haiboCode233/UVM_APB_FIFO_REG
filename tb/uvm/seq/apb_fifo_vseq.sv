`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_fifo_vseq extends uvm_sequence #(apb_fifo_txn);
    `uvm_object_utils(apb_fifo_vseq);
    
    apb_fifo_vsqr vsqr;
    
    apb_fifo_seq cfg_seq;
    apb_fifo_seq wr_seq;
    apb_fifo_seq rd_seq;
    
    int i;

    function new(string name = "apb_fifo_vseq");
        super.new(name);
    endfunction

    task body();
        if (!$cast(vsqr, m_sequencer)) begin
            `uvm_fatal("VSEQ", "Cannot cast m_sequencer to apb_fifo_vsqr")
        end

        cfg_seq = apb_fifo_seq::type_id::create("cfg_seq");
        cfg_seq.op_type = REG_CFG;
        cfg_seq.start(vsqr.apb_sqr);

        for(i = 0; i < 8; i++) begin
            wr_seq = apb_fifo_seq::type_id::create($sformatf("wr_%0d", i));
            wr_seq.op_type = FIFO_WRITE;
            wr_seq.start(vsqr.apb_sqr);
        end

        for(i = 0; i < 8; i++) begin
            rd_seq = apb_fifo_seq::type_id::create($sformatf("rd_%0d", i));
            rd_seq.op_type = FIFO_READ;
            rd_seq.start(vsqr.apb_sqr);
        end
    endtask

endclass