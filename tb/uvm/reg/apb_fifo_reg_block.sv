`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_fifo_reg_block extends uvm_reg_block;
    `uvm_object_utils(apb_fifo_reg_block)

    // regs definition 
    rand apb_fifo_depth_reg reg0;
    uvm_reg dummy_regs[7];

    // reg map
    uvm_reg_map fifo_reg_map;

    // params
    localparam int unsigned BASE_ADDR  = 32'h0000_0000;
    localparam int unsigned ADDR_STRIDE = 4;

    function new(string name = "apb_fifo_reg_block");
        super.new(name, UVM_NO_COVERAGE);
    endfunction //new()

    virtual function void build();
        fifo_reg_map = create_map("fifo_reg_map", BASE_ADDR, ADDR_STRIDE, UVM_LITTLE_ENDIAN);

        reg0 = apb_fifo_depth_reg::type_id::create("reg0");
        reg0.build();
        reg0.configure(this);                 // 归属于本 block
        apb_map.add_reg(reg0, 'h00, "RW");    // offset = 0x00

        for (int i = 1; i < 8; i++) begin
          dummy_regs[i-1] = uvm_reg::type_id::create($sformatf("dummy_reg%0d", i));
          dummy_regs[i-1].configure(this, 32, UVM_NO_COVERAGE);
          dummy_regs[i-1].build();
          apb_map.add_reg(dummy_regs[i-1], i*ADDR_STRIDE, "RW"); // 或 "WO"/"RW"/RES0
        end

        // 如果你想启用寄存器/字段覆盖率，可以在这里打开：
        // this.set_coverage(UVM_CVR_ALL);
        // reg0.set_coverage(UVM_CVR_ALL);

    lock_model(); // 建完后锁定模型（防止运行时误改结构）
  endfunction


endclass //apb_fifo_reg_block extends uvm_reg_block