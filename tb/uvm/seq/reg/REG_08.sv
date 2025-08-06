`include "uvm_macros.svh"
import uvm_pkg::*;

class seq_reg_08 extends uvm_sequence #(apb_fifo_txn);
    `uvm_object_utils(seq_reg_08)

    uvm_status_e status;
    uvm_reg_data_t read_val;
    
    apb_fifo_reg_block rgm;
    
    function new(string name = "seq_reg_08");
        super.new(name);
    endfunction //new()
    
    task body();
        if (!uvm_config_db#(apb_fifo_reg_block)::get(null, "", "rgm", rgm)) begin
            `uvm_fatal("CONFIG", "Failed to get rgm from config_db")
        end

        /*
            TestID: REG_08
            Description: Read all dummy_regs
        */
        
        rgm.dummy_regs[0].read(
            .status(status),
            .value(read_val),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );
        assert (read_val == 32'h0000_0000)
        else begin
            `uvm_fatal("REG_08 CHECK_FAILED", $sformatf("Expected %h, got %h", 32'h0000_0000, read_val));
        end

        rgm.dummy_regs[1].read(
            .status(status),
            .value(read_val),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );
        assert (read_val == 32'h0000_0000)
        else begin
            `uvm_fatal("REG_08 CHECK_FAILED", $sformatf("Expected %h, got %h", 32'h0000_0000, read_val));
        end

        rgm.dummy_regs[2].read(
            .status(status),
            .value(read_val),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );
        assert (read_val == 32'h0000_0000)
        else begin
            `uvm_fatal("REG_08 CHECK_FAILED", $sformatf("Expected %h, got %h", 32'h0000_0000, read_val));
        end

        rgm.dummy_regs[3].read(
            .status(status),
            .value(read_val),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );
        assert (read_val == 32'h0000_0000)
        else begin
            `uvm_fatal("REG_08 CHECK_FAILED", $sformatf("Expected %h, got %h", 32'h0000_0000, read_val));
        end

        rgm.dummy_regs[4].read(
            .status(status),
            .value(read_val),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );
        assert (read_val == 32'h0000_0000)
        else begin
            `uvm_fatal("REG_08 CHECK_FAILED", $sformatf("Expected %h, got %h", 32'h0000_0000, read_val));
        end

        rgm.dummy_regs[5].read(
            .status(status),
            .value(read_val),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );
        assert (read_val == 32'h0000_0000)
        else begin
            `uvm_fatal("REG_08 CHECK_FAILED", $sformatf("Expected %h, got %h", 32'h0000_0000, read_val));
        end

        rgm.dummy_regs[6].read(
            .status(status),
            .value(read_val),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );
        assert (read_val == 32'h0000_0000)
        else begin
            `uvm_fatal("REG_08 CHECK_FAILED", $sformatf("Expected %h, got %h", 32'h0000_0000, read_val));
        end

    endtask
endclass //seq_reg_01 extends uvm_sequence #(apb_fifo_txn)