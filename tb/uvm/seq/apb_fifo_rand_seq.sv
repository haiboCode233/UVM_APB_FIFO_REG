`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_fifo_rand_seq extends apb_fifo_seq;
    `uvm_object_utils(apb_fifo_rand_seq)

    function new(string name = "apb_fifo_rand_seq");
        super.new(name);
    endfunction //new()

    task body();
        req = apb_fifo_txn::type_id::create("req");
        
        // TODO: set a variable in config db to control these two
        // assert(req.randomize());

        assert(req.randomize() with {
                !(addr inside {
                    32'h0000_0000,
                    [32'h8000_0000 : 32'h8000_00FF]
                });
            });

        start_item(req);
        finish_item(req);
        get_response(rsp);
    endtask
endclass //apb_fifo_rand_seq extends apb_fifo_seq