`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_fifo_reg_block extends uvm_reg_block;
    `uvm_object_utils(apb_fifo_reg_block)

    // regs definition 
    rand apb_fifo_depth_reg reg0;
    apb_fifo_dummy_reg dummy_regs[7];
    apb_fifo_status_reg reg8;

    // reg map
    uvm_reg_map fifo_reg_map;

    // params
    localparam int unsigned BASE_ADDR  = 32'h0000_0000;
    localparam int unsigned ADDR_STRIDE = 4;

    function new(string name = "apb_fifo_reg_block");
        super.new(name, UVM_NO_COVERAGE);
    endfunction //new()

    virtual function void build();
        this.set_hdl_path_root("test_top.DUT");
        fifo_reg_map = create_map("fifo_reg_map", BASE_ADDR, ADDR_STRIDE, UVM_LITTLE_ENDIAN);

        default_map = fifo_reg_map; // set default map

        reg0 = apb_fifo_depth_reg::type_id::create("reg0");
        reg0.build();
        reg0.configure(this);                 // reg0 belogs to this block
        fifo_reg_map.add_reg(reg0, 'h00, "RW");    // offset = 0x00

        reg0.add_hdl_path('{ '{ "reg_block[0]", 0, 32 } });

        for (int i = 1; i < 8; i++) begin
          dummy_regs[i-1] = apb_fifo_dummy_reg::type_id::create($sformatf("dummy_reg%0d", i));
          dummy_regs[i-1].configure(this);
          dummy_regs[i-1].build();
          fifo_reg_map.add_reg(dummy_regs[i-1], i*ADDR_STRIDE, "RW");
        end

        reg8 = apb_fifo_status_reg::type_id::create("reg8");
        reg8.build();
        reg8.configure(this);
        fifo_reg_map.add_reg(reg8, 'h20, "RO");
        reg8.add_hdl_path('{ '{ "status_reg", 0, 32 } });

        // this.set_coverage(UVM_CVR_ALL);
        // reg0.set_coverage(UVM_CVR_ALL);

    lock_model();
  endfunction

endclass //apb_fifo_reg_block extends uvm_reg_block