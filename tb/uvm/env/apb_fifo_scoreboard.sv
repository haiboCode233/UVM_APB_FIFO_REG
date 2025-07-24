`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(apb_fifo_scoreboard)

    uvm_analysis_imp #(apb_fifo_txn, apb_fifo_scoreboard) ap;
    // FIFO reference model
    bit [31:0] ref_fifo[$]; // dynamic queue

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction //new()

    virtual function void write(apb_fifo_txn txn);

    if (txn.error) begin
            `uvm_warning("SBR", "Transaction has PSLVERR set, skipping check.")
            return;
    end

    case (txn.op_type)      
        REG_CFG: begin
            `uvm_info("SBR", $sformatf("REG_CFG: %s", txn.convert2string()), UVM_LOW)
        end
        REG_READ: begin
            `uvm_info("SBR", $sformatf("REG_READ: %s", txn.convert2string()), UVM_LOW)
        end  
        FIFO_WRITE: begin
            ref_fifo.push_back(txn.wdata);
        end
        FIFO_READ: begin
            if (ref_fifo.size() == 0) begin
                `uvm_error("SBR", "Read from empty reference model!")
            end else begin
                bit [31:0] expected = ref_fifo.pop_front();
                if (txn.rdata !== expected) begin
                `uvm_error("SBR", $sformatf("Mismatch: expected=0x%08x, actual=0x%08x", expected, txn.rdata))
                end else begin
                `uvm_info("SBR", $sformatf("Match: expected=0x%08x, actual=0x%08x", expected, txn.rdata), UVM_LOW)
                end
            end
        end
    endcase
    endfunction

endclass //apb_fifo_scoreboard extends uvm_scoreboard
