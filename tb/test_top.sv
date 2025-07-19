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

`include "./uvm/seq/apb_fifo_seq.sv"
`include "./uvm/seq/apb_fifo_vseq.sv"

`include "./uvm/env/apb_fifo_scoreboard.sv"
`include "./uvm/env/apb_fifo_env.sv"
`include "./uvm/test/apb_fifo_test.sv"

module test_top();
    logic PCLK, PRESETn;
    logic full, empty;
    
    apb_if apb_if_inst(.PCLK(PCLK));

    Sync_FIFO DUT(
        .PCLK(apb_if_inst.DUT.PCLK),
        .PRESETn(apb_if_inst.DUT.PRESETn),
        .PADDR(apb_if_inst.DUT.PADDR),
        .PPROT(apb_if_inst.DUT.PPROT),
        .PSEL(apb_if_inst.DUT.PSEL),
        .PENABLE(apb_if_inst.DUT.PENABLE),
        .PWRITE(apb_if_inst.DUT.PWRITE),
        .PWDATA(apb_if_inst.DUT.PWDATA),
        .PSTRB(apb_if_inst.DUT.PSTRB),
        .PREADY(apb_if_inst.DUT.PREADY),
        .PRDATA(apb_if_inst.DUT.PRDATA),
        .PSLVERR(apb_if_inst.DUT.PSLVERR),

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
        uvm_config_db #(virtual apb_if)::set(null, "*", "vif", apb_if_inst);
        run_test("apb_fifo_test");
    end
endmodule