import apb_fifo_types_pkg::*;

class apb_fifo_seq extends uvm_sequence #(apb_fifo_txn)
    `uvm_object_utils(apb_fifo_seq)

    apb_op_code op_type;

    function new(string name = "apb_fifo_seq")
        super.new(name);
    endfunction

    task body()
        apb_fifo_txn txn = apb_fifo_txn::type_id::create("txn");

        txn.op_type = op_type;

        case(op_type)
            REG_CFG: begin
                txn.write = 1'b1;
                txn.addr = 32'h0000_0000;
                txn.wdata = 32'h0000_0001; // depth = 8 << (1-1)
                txn.strob = 4'b0001;
                txn.need_t0 = 1'b1;
            end
            REG_READ: begin
                txn.write = 1'b0;
                txn.addr = 32'h0000_0000;
                txn.strob = 4'b0000;
                txn.need_t0 = 1'b0;
            end
            FIFO_WRITE: begin
                txn.write = 1'b1;
                txn.addr = 32'h8000_0000;
                txn.wdata = $random % 256; // temporary setting
                txn.strob = 4'b0001;
                txn.need_t0 = 1'b0;
            end
            FIFO_READ: begin
                txn.write = 1'b0;
                txn.addr = 32'h8000_0000;
                txn.strob = 4'b0000;
                txn.need_t0 = 1'b0;
            end
        endcase

        start_item(txn);
        finish_item(txn);

        if (txn.op_type inside {REG_READ, FIFO_READ}) begin
            `uvm_info("SEQ", txn.convert2string(), UVM_LOW);
        end
    endtask

endclass