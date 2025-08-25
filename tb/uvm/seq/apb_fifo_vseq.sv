`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_fifo_vseq extends uvm_sequence #(apb_fifo_txn);
    `uvm_object_utils(apb_fifo_vseq);
    
    string test_id;
    uvm_sequence_base sub_seq;

    apb_fifo_vsqr vsqr;

    function new(string name = "apb_fifo_vseq");
        super.new(name);
    endfunction

    task body();
        string arg_value;

        if ($value$plusargs("TEST_ID=%s", arg_value)) begin
            test_id = arg_value;
            `uvm_info("VSEQ", $sformatf("Received test_id = %s from plusarg", test_id), UVM_LOW)
        end else begin
            test_id = "REG_01";
            `uvm_warning("VSEQ", "No +TEST_ID=... passed, using REG_01")
        end

        if (!$cast(vsqr, m_sequencer)) begin
            `uvm_fatal("VSEQ", "Cannot cast m_sequencer to apb_fifo_vsqr")
        end

        if(test_id == "REG_01") begin
            sub_seq = seq_reg_01::type_id::create("sub_seq");
        end else if (test_id == "REG_02") begin
            sub_seq = seq_reg_01::type_id::create("sub_seq");
        end else if (test_id == "REG_03") begin
            sub_seq = seq_reg_01::type_id::create("sub_seq");
        end else if (test_id == "REG_04") begin
            sub_seq = seq_reg_01::type_id::create("sub_seq");
        end else if (test_id == "REG_05") begin
            sub_seq = seq_reg_05::type_id::create("sub_seq");
        end else if (test_id == "REG_06") begin
            sub_seq = seq_reg_06::type_id::create("sub_seq");
        end else if (test_id == "REG_07") begin
            sub_seq = seq_reg_07::type_id::create("sub_seq");
        end else if (test_id == "REG_08") begin
            sub_seq = seq_reg_08::type_id::create("sub_seq");
        end else if (test_id == "REG_09") begin
            sub_seq = seq_reg_09::type_id::create("sub_seq");
        end else if (test_id == "REG_10") begin
            sub_seq = seq_reg_10::type_id::create("sub_seq");
        end else if (test_id == "REG_11") begin
            sub_seq = seq_reg_11::type_id::create("sub_seq");
        end else if (test_id == "REG_12") begin
            sub_seq = seq_reg_12::type_id::create("sub_seq");
        end else if (test_id == "FIFO_01") begin
            sub_seq = seq_fifo_01::type_id::create("sub_seq");
        end else if (test_id == "FIFO_02") begin
            sub_seq = seq_fifo_02::type_id::create("sub_seq");
        end else if (test_id == "FIFO_03") begin
            sub_seq = seq_fifo_03::type_id::create("sub_seq");
        end else if (test_id == "FIFO_04") begin
            sub_seq = seq_fifo_04::type_id::create("sub_seq");
        end else if (test_id == "FIFO_05") begin
            sub_seq = seq_fifo_05::type_id::create("sub_seq");
        end else if (test_id == "FIFO_06") begin
            sub_seq = seq_fifo_06::type_id::create("sub_seq");
        end else if (test_id == "FIFO_07") begin
            sub_seq = seq_fifo_07::type_id::create("sub_seq");
        end else if (test_id == "FIFO_08") begin
            sub_seq = seq_fifo_08::type_id::create("sub_seq");
        end else if (test_id == "FIFO_09") begin
            sub_seq = seq_fifo_09::type_id::create("sub_seq");
        end 

        if(test_id.substr(0,2) == "REG") begin
            string sub = test_id.substr(test_id.len()-2, test_id.len()-1);  
            int val;
            $sscanf(sub, "%d", val);
            if(val <= 10) begin
                sub_seq.start(vsqr.rgm.default_map.get_sequencer());
            end else begin
                sub_seq.start(vsqr);
            end    
        end else begin
            sub_seq.start(vsqr);
        end

    endtask

endclass