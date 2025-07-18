class apb_fifo_vseq extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(apb_fifo_vseq);
    
    apb_fifo_vsqr vsqr;
    apb_op_code user_op;

    function new(string name = "apb_fifo_vseq");
        super.new(name);
    endfunction

    task body;
        if (!$cast(vsqr, m_sequencer)) begin
            `uvm_fatal("VSEQ", "Cannot cast m_sequencer to apb_fifo_vsqr")
        end

        apb_fifo_seq seq = apb_fifo_seq::type_id::create("seq");
        seq.on_type = user_op;
        seq.start(vsqr.apb_sqr);
    endtask

endclass