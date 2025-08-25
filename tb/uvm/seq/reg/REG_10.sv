`include "uvm_macros.svh"
import uvm_pkg::*;

class seq_reg_10 extends uvm_sequence #(apb_fifo_txn);
    `uvm_object_utils(seq_reg_10)

    uvm_status_e status;
    uvm_reg_data_t read_val;
    
    apb_fifo_status_reg rg;
    apb_fifo_reg_block rgm;
    
    function new(string name = "seq_reg_10");
        super.new(name);
    endfunction //new()
    
    task body();
        if (!uvm_config_db#(apb_fifo_reg_block)::get(null, "", "rgm", rgm)) begin
            `uvm_fatal("CONFIG", "Failed to get rgm from config_db")
        end
        rg = rgm.reg8;

        /*
            TestID: REG_10
            Description: read default value of status reg
        */
        rg.read(
            .status(status),
            .value(read_val),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );
        
        assert (read_val[0] == 1'b1)
        else begin
            `uvm_fatal("REG_10 CHECK_FAILED", $sformatf("Empty Field Expected %b, got %b", 1'b1, read_val[0]));
        end

        assert (read_val[1] == 1'b0)
        else begin
            `uvm_fatal("REG_10 CHECK_FAILED", $sformatf("Full Field Expected %b, got %b", 1'b0, read_val[0]));
        end

        assert (read_val[7:2] == 6'b000_000)
        else begin
            `uvm_fatal("REG_10 CHECK_FAILED", $sformatf("Count Field Expected %b, got %b", 6'b000_000, read_val[7:2]));
        end
    endtask
endclass //seq_reg_01 extends uvm_sequence #(apb_fifo_txn)