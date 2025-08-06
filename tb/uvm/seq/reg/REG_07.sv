`include "uvm_macros.svh"
import uvm_pkg::*;

class seq_reg_07 extends uvm_sequence #(apb_fifo_txn);
    `uvm_object_utils(seq_reg_07)

    uvm_status_e status;
    uvm_reg_data_t read_val;
    
    apb_fifo_depth_reg rg;
    apb_fifo_reg_block rgm;
    
    function new(string name = "seq_reg_07");
        super.new(name);
    endfunction //new()
    
    task body();
        if (!uvm_config_db#(apb_fifo_reg_block)::get(null, "", "rgm", rgm)) begin
            `uvm_fatal("CONFIG", "Failed to get rgm from config_db")
        end
        rg = rgm.reg0;

        /*
            TestID: REG_07
            Description: Back door write, frontdoor read
        */
        rg.write(
            .status(status),
            .value(6'b10_0000),
            .parent(this),
            .path(UVM_BACKDOOR)
        );

//        uvm_hdl_deposit("test_top.DUT.reg_block[0]", 32'hDEADBEEF);
        $display("reg_block[0] = 0x%08x", test_top.DUT.reg_block[0]);
        #1ns;  

        rg.read(
            .status(status),
            .value(read_val),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );
        assert (read_val == 32'h0000_0001)
        else begin
            `uvm_fatal("REG_07 CHECK_FAILED", $sformatf("Expected %h, got %h", 32'h0000_0001, read_val));
        end

    endtask
endclass //seq_reg_01 extends uvm_sequence #(apb_fifo_txn)