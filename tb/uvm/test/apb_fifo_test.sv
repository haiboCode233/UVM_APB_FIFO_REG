`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_fifo_test extends uvm_test;
    `uvm_component_utils(apb_fifo_test);

    apb_fifo_env env;
    apb_fifo_vseq vseq;
    apb_fifo_reg_block rgm;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        
        rgm = apb_fifo_reg_block::type_id::create("rgm", this);
        rgm.build();
        uvm_config_db #(apb_fifo_reg_block)::set(this, "env", "rgm", rgm);

        env = apb_fifo_env::type_id::create("env", this);
        uvm_config_db #(uvm_active_passive_enum)::set(this, "env.agent", "is_active", UVM_ACTIVE);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        rgm.default_map.set_sequencer(env.vsqr.apb_sqr, env.adapter);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        vseq = apb_fifo_vseq::type_id::create("vseq");
        vseq.start(env.vsqr);
        
        phase.drop_objection(this);
    endtask
endclass //apb_fifo_test extends uvm_test