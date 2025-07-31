`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_fifo_dummy_reg extends uvm_reg;
  `uvm_object_utils(apb_fifo_dummy_reg)

  uvm_reg_field dummy_field;

  function new(string name = "apb_fifo_dummy_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    dummy_field = uvm_reg_field::type_id::create("field");
    dummy_field.configure(
      this,       // parent
      32,         // bits
      0,          // lsb_pos
      "RW",       // access
      0,          // volatile
      0,          // reset
      1,          // has_reset
      0,          // is_rand
      1           // bit accessible
    );
  endfunction
endclass
