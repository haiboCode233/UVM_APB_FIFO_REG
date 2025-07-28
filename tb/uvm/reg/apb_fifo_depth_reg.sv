`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_fifo_depth_reg extends uvm_reg;
    `uvm_object_utils(apb_fifo_depth_reg)

    rand uvm_reg_field depth_sel_fld;

    function new(string name = "apb_fifo_depth_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction //new()

    virtual function void build();
        depth_sel_fld = uvm_reg_field::type_id::create("depth_sel_fld");
        depth_sel_fld.configure(
        this,                // parent reg
        6,                   // field size: 6 bits
        0,                   // LSB position: [5:0]
        "RW",                // access type
        0,                   // volatile? (0=not volatile)
        6'b000001,           // reset value, depth = 8
        1,                   // has_reset
        0,                   // is_rand
        1                    // individually accessible
        );
    endfunction
endclass //apb_fifo_depth_reg extends uvm_reg
