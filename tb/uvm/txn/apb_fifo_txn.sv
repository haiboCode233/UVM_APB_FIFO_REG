import uvm_pkg::*;
`include "uvm_macros.svh"

typedef enum {REG_CFG, REG_READ, FIFO_WRITE, FIFO_READ} apb_op_code;

class apb_fifo_txn extends uvm_sequence_item;
    `uvm_object_utils(apb_fifo_txn)
    
    apb_op_code     op_type;
    rand bit        write;
    rand bit [31:0] addr;
    rand bit [31:0] wdata;
        bit [31:0]  rdata;
        bit  [3:0]  strob;
        bit         need_t0;
        bit         error;
    rand int        gap_cycles;
    
    function new(string name = "apb_fifo_txn");
        super.new(name);
        op_type  = REG_CFG;
        write    = 0;
        addr     = 32'h0;
        wdata    = 32'h0;
        rdata    = 32'h0;
        strob    = 4'b0;
        need_t0  = 0;
        error    = 0;
        gap_cycles = 0;
    endfunction //new()

    function string convert2string();
        return $sformatf("APB TXN:write=%0b addr=0x%08x wdata=0x%08x rdata=0x%08x",
                    write, addr, wdata, rdata);
    endfunction

endclass //apb_fifo_txn extends uvm_sequence_item