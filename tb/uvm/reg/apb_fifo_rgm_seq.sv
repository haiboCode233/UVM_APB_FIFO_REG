`include "uvm_macros.svh"
import uvm_pkg::*;

typedef enum bit [5:0] {
  DEPTH_8    = 6'b000001,
  DEPTH_16   = 6'b000010,
  DEPTH_32   = 6'b000100,
  DEPTH_64   = 6'b001000,
  DEPTH_128  = 6'b010000,
  DEPTH_256  = 6'b100000
} fifo_reg_depth;

class apb_fifo_rgm_seq extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(apb_fifo_reg_seq)
  `uvm_declare_p_sequencer(apb_fifo_vsqr)

  rand fifo_reg_depth depth_sel = DEPTH_8;

  function new(string name = "apb_fifo_rgm_seq");
    super.new(name);
  endfunction

  task body();
    uvm_status_e   status;
    uvm_reg_data_t rdata;

    if (p_sequencer == null) begin
      `uvm_fatal(get_type_name(), "p_sequencer is null. Ensure this seq runs on apb_fifo_vsqr")
    end
    if (p_sequencer.reg_block == null) begin
      `uvm_fatal(get_type_name(), "reg_block handle in vsqr is null. Make sure you connected it in env/test.")
    end

    // write field of depth reg
    `uvm_info(get_type_name(), $sformatf("Write depth = %0s (%0b)",
              depth_sel.name(), depth_sel), UVM_MEDIUM)

    p_sequencer.reg_block.reg0.write(status, depth_sel, .parent(this));
    if (status != UVM_IS_OK) begin
      `uvm_error(get_type_name(), "Write depth failed!")
    end

    // read field of depth reg
    p_sequencer.reg_block.reg0.read(status, rdata, .parent(this));
    if (status != UVM_IS_OK) begin
      `uvm_error(get_type_name(), "Read back depth failed!")
    end else begin
      bit [5:0] depth_read = rdata[5:0];
      if (depth_read !== depth_sel) begin
        `uvm_error(get_type_name(),
          $sformatf("Depth mismatch! Written=%0b, Read=%0b", depth_sel, depth_read))
      end else begin
        `uvm_info(get_type_name(),
          $sformatf("Depth readback PASS: %0b", depth_read), UVM_LOW)
      end
    end

    // 3) 也可以直接操作 field（可选示例）
    // p_sequencer.reg_block.reg0.depth_sel_fld.write(status, depth_sel, .parent(this));
    // p_sequencer.reg_block.reg0.depth_sel_fld.read (status, rdata, .parent(this));

  endtask

endclass
