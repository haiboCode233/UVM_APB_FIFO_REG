import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_fifo_bfm;
    virtual apb_if vif;
    
    function new(virtual apb_if vif);
        this.vif = vif;
    endfunction
    
    task clear_bus(); // In APB DUT hold signals in T3 for power saving. In UVM clear signals to avoid potential problems.
        vif.PADDR   = 32'h0000_0000;
        vif.PWDATA  = 32'h0000_0000;
        vif.PWRITE  = 1'b0;
        vif.PSTRB   = 4'b0000;
        vif.PPROT   = 3'b010;
    endtask

    task drive_txn(apb_fifo_txn txn);
        // T0 cycle
        if(txn.need_t0) begin
            vif.PADDR = 32'h0000_0000; 
            vif.PPROT = 3'b010; // normal access; nonsecure access; data access 
            vif.PSEL = 1'b0;
            vif.PENABLE = 1'b0;
            vif.PWRITE = 1'b0;
            vif.PWDATA = 32'h00_00_00_00;
            vif.PSTRB = 4'b0000;
            @(posedge vif.PCLK);    
        end
        
        // T1 cycle
        vif.PADDR = txn.addr; // reg IO
        // PPROT = 3'b010; // fixed setting 
        vif.PSEL = 1'b1;
        vif.PENABLE = 1'b0;
        vif.PWRITE = txn.write;
        vif.PWDATA = txn.wdata; // depth = 8 << (PWDATA - 1)
        vif.PSTRB = txn.strob; // mask of PWDATA
        @(posedge vif.PCLK);
        
        // T2 cycle
        vif.PENABLE = 1'b1;
        wait (vif.PREADY === 1); // PREADY is always 1 in this design
        @(posedge vif.PCLK);
        if (!txn.write)
            txn.rdata = vif.PRDATA;
        

        // T3 cycle
        // PADDR and PWDATA remain same to save power
        vif.PSEL = 1'b0;
        vif.PENABLE = 1'b0;
        @(posedge vif.PCLK);

        clear_bus();
    endtask

    task sample_txn(ref apb_fifo_txn txn); // should use ref instead of output
        @(posedge vif.mon_cb) begin
        if (vif.mon_cb.PSEL && vif.mon_cb.PENABLE && vif.mon_cb.PREADY) begin
            txn.op_type = vif.mon_cb.PWRITE ? (vif.mon_cb.PADDR[31] ? FIFO_WRITE : REG_CFG) : (vif.mon_cb.PADDR[31] ? FIFO_READ : REG_READ); 
            txn.addr   = vif.mon_cb.PADDR;
            txn.strob  = vif.mon_cb.PSTRB;
            txn.write  = vif.mon_cb.PWRITE;
            txn.wdata  = vif.mon_cb.PWDATA;
            txn.rdata  = vif.mon_cb.PRDATA;
            txn.error  = vif.mon_cb.PSLVERR;
        end else begin
            txn = null;
        end end
    endtask

endclass    
