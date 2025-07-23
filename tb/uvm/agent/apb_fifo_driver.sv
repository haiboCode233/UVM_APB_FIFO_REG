import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_fifo_driver extends uvm_driver #(apb_fifo_txn); // parameterized class
  apb_fifo_bfm bfm;

  `uvm_component_utils(apb_fifo_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(apb_fifo_bfm)::get(this, "", "bfm", bfm))
      `uvm_fatal("NOVIF", "No BFM handle set")
  endfunction

  task run_phase(uvm_phase phase);
    apb_fifo_txn txn, rsp;
    forever begin
      seq_item_port.get_next_item(txn); // TLM pull
      bfm.drive_txn(txn);

      // clone response
      void'($cast(rsp, txn.clone()));  
      rsp.set_id_info(txn);
      rsp.rdata = txn.rdata;
      seq_item_port.put_response(rsp);

      seq_item_port.item_done(); // TLM handshake
    end
  endtask
endclass
