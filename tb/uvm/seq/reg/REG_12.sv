`include "uvm_macros.svh"
import uvm_pkg::*;

class seq_reg_12 extends uvm_sequence #(apb_fifo_txn);
    `uvm_object_utils(seq_reg_12)

    apb_fifo_vsqr vsqr;
    apb_fifo_seq wr_seq;
    apb_fifo_seq rd_seq;

    uvm_status_e status;
    uvm_reg_data_t read_val;
    
    
    function new(string name = "seq_reg_12");
        super.new(name);
    endfunction //new()
    
    task body();
        if (!$cast(vsqr, m_sequencer)) begin
            `uvm_fatal("REG_12", "Cannot cast m_sequencer to apb_fifo_vsqr")
        end

        /*
            TestID: REG_12
            Description: Write till full read one then read reg9
        */

        // configure depth to 8 
        vsqr.rgm.reg0.write(
            .status(status),
            .value(6'b00_0001),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );

        // write till full
        for(int i=0;i<8;i++) begin
            wr_seq = apb_fifo_seq::type_id::create($sformatf("wr_0%d",i));
            wr_seq.op_type = FIFO_WRITE;
            wr_seq.gap_cycles = 0;
            wr_seq.start(vsqr.apb_sqr);
        end

        rd_seq = apb_fifo_seq::type_id::create("rd_01");
        rd_seq.op_type = FIFO_READ;
        rd_seq.start(vsqr.apb_sqr);
        
        vsqr.rgm.reg8.read(
            .status(status),
            .value(read_val),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );
        
        assert (read_val[0] == 1'b0)
        else begin
            `uvm_fatal("REG_12 CHECK_FAILED", $sformatf("Empty Field Expected %b, got %b", 1'b0, read_val[0]));
        end

        assert (read_val[1] == 1'b0)
        else begin
            `uvm_fatal("REG_12 CHECK_FAILED", $sformatf("Full Field Expected %b, got %b", 1'b0, read_val[0]));
        end

        assert (read_val[7:2] == 6'b000_111)
        else begin
            `uvm_fatal("REG_12 CHECK_FAILED", $sformatf("Count Field Expected %b, got %b", 6'b000_111, read_val[7:2]));
        end
    endtask
endclass //seq_reg_01 extends uvm_sequence #(apb_fifo_txn)