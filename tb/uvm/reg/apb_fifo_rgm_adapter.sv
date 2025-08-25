`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_fifo_rgm_adapter extends uvm_reg_adapter;
  `uvm_object_utils(apb_fifo_rgm_adapter)

  function new(string name = "apb_fifo_rgm_adapter");
    super.new(name);
    supports_byte_enable = 1; 
    provides_responses   = 1; 
  endfunction

  // reg -> bus (reg2bus)
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    apb_fifo_txn txn;
    txn = apb_fifo_txn::type_id::create("txn");
    txn.addr  = rw.addr[31:0];   
    txn.write = (rw.kind == UVM_WRITE);
    txn.wdata = rw.data[31:0];
    txn.strob = 4'b1111; // Necessary!
    return txn;
  endfunction

  // bus -> reg (bus2reg)
  virtual function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
    apb_fifo_txn txn;
    if (!$cast(txn, bus_item)) begin
      // `uvm_fatal("RGM", "bus_item is not apb_fifo_txn")
      `uvm_error("RGM", $sformatf("Invalid type in bus2reg: %s", bus_item.get_type_name()));
    end

    rw.addr   = txn.addr;
    rw.kind   = txn.write ? UVM_WRITE : UVM_READ;
    rw.data   = txn.write ? txn.wdata : txn.rdata; 
    rw.status = txn.error ? UVM_NOT_OK : UVM_IS_OK;
  endfunction

endclass
