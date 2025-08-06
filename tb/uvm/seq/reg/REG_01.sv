`include "uvm_macros.svh"
import uvm_pkg::*;

class seq_reg_01 extends uvm_sequence #(apb_fifo_txn);
    `uvm_object_utils(seq_reg_01)

    uvm_status_e status;
    uvm_reg_data_t read_val;
    
    apb_fifo_depth_reg rg;
    apb_fifo_reg_block rgm;

    function new(string name = "seq_reg_01");
        super.new(name);
    endfunction //new()
    
    task body();
        if (!uvm_config_db#(apb_fifo_reg_block)::get(null, "", "rgm", rgm)) begin
            `uvm_fatal("CONFIG", "Failed to get rgm from config_db")
        end
        rg = rgm.reg0;

        /*
            TestID: REG_01
            Description: Read the default value of reg0
        */
        rg.read(
            .status(status),
            .value(read_val),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );
        assert (read_val == 32'h0000_0001)
        else begin
            `uvm_fatal("REG_01 CHECK_FAILED", $sformatf("Expected %h, got %h", 32'h0000_0001, read_val));
        end

        /*
            TestID: REG_02
            Description: Write & read back of reg0
        */
        rg.write(
            .status(status),
            .value(6'b00_0100),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );

        rg.read(
            .status(status),
            .value(read_val),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );
        assert (read_val == 32'h0000_0004)
        else begin
            `uvm_fatal("REG_02 CHECK_FAILED", $sformatf("Expected %h, got %h", 32'h0000_0100, read_val));
        end

        /*
            TestID: REG_03
            Description: Write & read back of reg0 field only
        */
        rg.depth_sel_fld.write(
            .status(status),
            .value(32'h0000_0003),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );

        rg.depth_sel_fld.read(
            .status(status),
            .value(read_val),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );
        assert (read_val == 32'h0000_0003)
        else begin
            `uvm_fatal("REG_03 CHECK_FAILED", $sformatf("Expected %h, got %h", 32'h0000_0003, read_val));
        end

        /*
            TestID: REG_04
            Description: Write corner values then read
        */
        rg.write(
            .status(status),
            .value(6'b10_0000),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );

        rg.read(
            .status(status),
            .value(read_val),
            .parent(this),
            .path(UVM_FRONTDOOR)
        );
        assert (read_val == 32'h0000_0020)
        else begin
            `uvm_fatal("REG_04 CHECK_FAILED", $sformatf("Expected %h, got %d", 32'h0000_0020, read_val));
        end

    endtask
endclass //seq_reg_01 extends uvm_sequence #(apb_fifo_txn)