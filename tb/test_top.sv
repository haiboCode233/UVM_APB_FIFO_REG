`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*; 

// === Include everything needed ===
`include "./uvm/txn/apb_fifo_txn.sv"
`include "./uvm/interface/apb_if.sv"

`include "./uvm/agent/apb_fifo_bfm.sv"
`include "./uvm/agent/apb_fifo_driver.sv"
`include "./uvm/agent/apb_fifo_monitor.sv"
`include "./uvm/agent/apb_fifo_sqr.sv"
`include "./uvm/agent/apb_fifo_agent.sv"

`include "./uvm/env/apb_fifo_vsqr.sv"

`include "./uvm/reg/apb_fifo_depth_reg.sv"
`include "./uvm/reg/apb_fifo_dummy_reg.sv"
`include "./uvm/reg/apb_fifo_reg_block.sv"
`include "./uvm/reg/apb_fifo_rgm_adapter.sv"

`include "./uvm/seq/apb_fifo_seq.sv"
`include "./uvm/seq/apb_fifo_vseq.sv"

`include "./uvm/env/apb_fifo_scoreboard.sv"
`include "./uvm/env/apb_fifo_env.sv"
`include "./uvm/test/apb_fifo_test.sv"


module test_top();
    logic PCLK, PRESETn;
    logic full, empty;
    
    apb_if apb_if_inst(.PCLK(PCLK), .PRESETn(PRESETn));
    apb_fifo_bfm apb_bfm_inst;

    Sync_FIFO DUT(
        .PCLK(apb_if_inst.PCLK),
        .PRESETn(apb_if_inst.PRESETn),
        .PADDR(apb_if_inst.PADDR),
        .PPROT(apb_if_inst.PPROT),
        .PSEL(apb_if_inst.PSEL),
        .PENABLE(apb_if_inst.PENABLE),
        .PWRITE(apb_if_inst.PWRITE),
        .PWDATA(apb_if_inst.PWDATA),
        .PSTRB(apb_if_inst.PSTRB),
        .PREADY(apb_if_inst.PREADY),
        .PRDATA(apb_if_inst.PRDATA),
        .PSLVERR(apb_if_inst.PSLVERR),

        .full(full),
        .empty(empty)
    );

    // clock
    initial begin
        PCLK = 0;
        forever begin
             #5 PCLK = ~PCLK;
        end
    end

    // reset
    initial begin
        PRESETn = 0;
        #20
        PRESETn = 1;
    end

    initial begin
        apb_bfm_inst = new(apb_if_inst);

        uvm_config_db #(virtual apb_if)::set(null, "*", "vif", apb_if_inst);
        uvm_config_db #(apb_fifo_bfm)::set(null, "*", "bfm", apb_bfm_inst);

        run_test("apb_fifo_test");
    end
endmodule