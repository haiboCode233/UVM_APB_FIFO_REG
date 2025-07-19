`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_fifo_seq extends uvm_sequence #(apb_fifo_txn);
    `uvm_object_utils(apb_fifo_seq)

    apb_op_code op_type;

    function new(string name = "apb_fifo_seq");
        super.new(name);
    endfunction

    task body();
        req = apb_fifo_txn::type_id::create("req");

        req.op_type = op_type;

        case(op_type)
            REG_CFG: begin
                req.write = 1'b1;
                req.addr = 32'h0000_0000;
                req.wdata = 32'h0000_0001; // depth = 8 << (1-1)
                req.strob = 4'b0001;
                req.need_t0 = 1'b1;
            end
            REG_READ: begin
                req.write = 1'b0;
                req.addr = 32'h0000_0000;
                req.strob = 4'b0000;
                req.need_t0 = 1'b0;
            end
            FIFO_WRITE: begin
                req.write = 1'b1;
                req.addr = 32'h8000_0000;
                req.wdata = $random % 256; // temporary setting
                req.strob = 4'b0001;
                req.need_t0 = 1'b0;
            end
            FIFO_READ: begin
                req.write = 1'b0;
                req.addr = 32'h8000_0000;
                req.strob = 4'b0000;
                req.need_t0 = 1'b0;
            end
        endcase

        start_item(req);
        finish_item(req);

        if (req.op_type inside {REG_READ, FIFO_READ}) begin
            `uvm_info("SEQ", req.convert2string(), UVM_LOW);
        end
    endtask

endclass