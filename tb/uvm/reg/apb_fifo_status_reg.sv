`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_fifo_status_reg extends uvm_reg;
    `uvm_object_utils(apb_fifo_status_reg)

    uvm_reg_field empty_fld;
    uvm_reg_field full_fld;
    uvm_reg_field occupancy_fld;

    function new(string name = "apb_fifo_status_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction //new()
    
    virtual function void build();
        empty_fld = uvm_reg_field::type_id::create("empty_fld");
        full_fld = uvm_reg_field::type_id::create("full_fld");
        occupancy_fld = uvm_reg_field::type_id::create("occupancy_fld");

        empty_fld.configure(
        this,                // parent reg
        1,                   // field size
        0,                   // LSB position
        "RO",                // access type
        0,                   // volatile? (0=not volatile)
        1'b1,                // reset value
        0,                   // has_reset
        0,                   // is_rand
        1                    // individually accessible
        );

        full_fld.configure(
        this,                // parent reg
        1,                   // field size
        1,                   // LSB position
        "RO",                // access type
        0,                   // volatile? (0=not volatile)
        1'b0,                // reset value
        0,                   // has_reset
        0,                   // is_rand
        1                    // individually accessible
        );

        occupancy_fld.configure(
        this,                // parent reg
        6,                   // field size
        2,                   // LSB position
        "RO",                // access type
        0,                   // volatile? (0=not volatile)
        6'b000_000,          // reset value
        0,                   // has_reset
        0,                   // is_rand
        1                    // individually accessible
        );
    endfunction
endclass //apb_fifo_status_reg extends uvm_reg
