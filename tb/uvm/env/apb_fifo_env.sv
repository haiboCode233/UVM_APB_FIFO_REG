class apb_fifo_env extends uvm_env;
  `uvm_component_utils(apb_fifo_env)

  apb_fifo_agent       agent;
  apb_fifo_scoreboard  sb;
  apb_fifo_vsqr        vsqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = apb_fifo_agent::type_id::create("agent", this);
    sb    = apb_fifo_scoreboard::type_id::create("sb", this);
    vsqr  = apb_fifo_vsqr::type_id::create("vsqr", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.ap.connect(sb.ap);
    vsqr.apb_sqr = agent.sqr;
  endfunction
endclass
