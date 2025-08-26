`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_fifo_env extends uvm_env;
  `uvm_component_utils(apb_fifo_env)

  apb_fifo_agent       agent;
  apb_fifo_scoreboard  sb;
  apb_fifo_vsqr        vsqr;
  apb_fifo_rgm_adapter adapter;
  apb_fifo_coverage    cov;
  uvm_reg_predictor #(apb_fifo_txn) predictor;
  apb_fifo_reg_block rgm;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agent = apb_fifo_agent::type_id::create("agent", this);
    sb    = apb_fifo_scoreboard::type_id::create("sb", this);
    vsqr  = apb_fifo_vsqr::type_id::create("vsqr", this);
    cov   = apb_fifo_coverage::type_id::create("cov", this);
    adapter = apb_fifo_rgm_adapter::type_id::create("adapter", this);
    predictor = uvm_reg_predictor #(apb_fifo_txn)::type_id::create("predictor", this);
    if (!uvm_config_db#(apb_fifo_reg_block)::get(this, "", "rgm", rgm))
      `uvm_fatal("ENV", "No regmodel found")
    if (rgm.default_map == null)
      `uvm_fatal("RGM_NULL", "Register model rgm is null in env!")
    
    uvm_config_db#(apb_fifo_coverage)::set(null, "", "cov", cov);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.mon_ap.connect(sb.ap);
    vsqr.apb_sqr = agent.sqr;
    predictor.map     = rgm.default_map;
    predictor.adapter = adapter;  
    agent.mon_ap.connect(predictor.bus_in);
    agent.mon_ap.connect(cov.ap_imp);
    if (vsqr.apb_sqr == null)
      `uvm_fatal("CONNECT", "vsqr.apb_sqr is null before setting regmap sequencer!")
    if (adapter == null)
      `uvm_fatal("CONNECT", "adapter is null before set_sequencer")
    rgm.default_map.set_sequencer(vsqr.apb_sqr, adapter);
    vsqr.rgm = rgm;
  endfunction
endclass
