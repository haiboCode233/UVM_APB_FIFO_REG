`include "uvm_macros.svh"
import uvm_pkg::*;

class seq_reg_09 extends uvm_sequence #(apb_fifo_txn);
    `uvm_object_utils(seq_reg_09)

    uvm_status_e status;
    uvm_reg_data_t read_val;
    
    apb_fifo_depth_reg rg;
    apb_fifo_reg_block rgm;
    
    function new(string name = "seq_reg_09");
        super.new(name);
    endfunction //new()
    
    task body();
        if (!uvm_config_db#(apb_fifo_reg_block)::get(null, "", "rgm", rgm)) begin
            `uvm_fatal("CONFIG", "Failed to get rgm from config_db")
        end
        rg = rgm.reg0;

        /*
            TestID: REG_09
            Description: Mirror and compare
        */
        rg.set(32'h0000_0001);
        rg.mirror(status, UVM_CHECK);  


    endtask
endclass //seq_reg_01 extends uvm_sequence #(apb_fifo_txn)