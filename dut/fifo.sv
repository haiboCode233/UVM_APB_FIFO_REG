module Sync_FIFO #(
    parameter WIDTH = 8,
    parameter MAX_DEPTH = 256
)(
    // AMBA 4.0 APB Interface
    input  logic        PCLK,
    input  logic        PRESETn,
    input  logic [31:0] PADDR,
    input  logic [2:0]  PPROT,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [31:0] PWDATA,
    input  logic [3:0]  PSTRB,
    output logic        PREADY,
    output logic [31:0] PRDATA,
    output logic        PSLVERR,

    // FIFO output signals
    output logic full,
    output logic empty
);

// register block
logic [31:0] reg_block [7:0]; // 8 registers, each 32-bit
/*
    bit 0: depth = 8
    bit 1: depth = 16
    bit 2: depth = 32
    bit 3: depth = 64
    bit 4: depth = 128
    bit 5: depth = 256
*/
logic [5:0] depth_sel_field;
// memory
logic [WIDTH - 1 : 0] mem [MAX_DEPTH - 1 : 0];
logic [$clog2(MAX_DEPTH):0] fifo_depth;
// pointer counter
logic [$clog2(MAX_DEPTH):0] count;
// pointer
logic [$clog2(MAX_DEPTH)-1:0] w_ptr, r_ptr;
// internal signals --- reg signals
logic reg_wr_en;
logic reg_rd_en;
logic [2:0] reg_addr;
// logic [31:0] reg_wr_data;
// internal signals --- fifo signals
logic w_ready;
logic w_valid;
logic r_ready;
logic r_valid;
// internal signals --- flags
logic addr_valid;

// mapping APB signals to internal reg signals
always_comb begin
    reg_wr_en = PSEL & PWRITE & PENABLE & ~PADDR[31] & addr_valid;
    reg_rd_en = PSEL & ~PWRITE & PENABLE & ~PADDR[31] & addr_valid;
    reg_addr = (PADDR >> 2) & 3'b111;
end

// mapping APB signals to internal fifo signals 
always_comb begin
    w_valid = PSEL & PWRITE & PENABLE & PADDR[31] & addr_valid;
    r_ready = PSEL & ~PWRITE & PENABLE & PADDR[31] & addr_valid;
end

// address valid flag driver
always_comb begin
  if (PADDR[30:0] <= 32'h0000_001C) // This saves most of resources, bit 31 can be either 1 or 0, might be useful in interviews lol
    addr_valid = 1'b1;
  else
    addr_valid = 1'b0;
end

// APB output signals driver
always_comb begin
    PREADY = 1; // in this design PREADY is always high
    PSLVERR = ~addr_valid;
end

// reg fields
always_comb begin
    case (reg_block[0])
        32'h1: depth_sel_field = 0;
        32'h2: depth_sel_field = 1;
        32'h4: depth_sel_field = 2;
        32'h8: depth_sel_field = 3;
        32'h10: depth_sel_field = 4;
        32'h20: depth_sel_field = 5;
        default: depth_sel_field = 0; // default to 8 if invalid config
    endcase
    fifo_depth = 8 << depth_sel_field;
end

// reg write
always_ff @(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        reg_block[0] <= {31'd0, 1'd1}; // depth reg, default depth = 8
        reg_block[1] <= {32'd0}; // reserved
        reg_block[2] <= {32'd0}; // reserved
        reg_block[3] <= {32'd0}; // reserved
        reg_block[4] <= {32'd0}; // reserved
        reg_block[5] <= {32'd0}; // reserved
        reg_block[6] <= {32'd0}; // reserved
        reg_block[7] <= {32'd0}; // reserved
    end else if(reg_wr_en && PREADY) begin
        case (reg_addr)
            0: if(count == 0) begin
                if(PSTRB[0]) reg_block[0][ 7: 0] <= PWDATA[ 7: 0];
                if(PSTRB[1]) reg_block[0][15: 8] <= PWDATA[15: 8];
                if(PSTRB[2]) reg_block[0][23:16] <= PWDATA[23:16];
                if(PSTRB[3]) reg_block[0][31:24] <= PWDATA[31:24];
            end
            default: begin
                if(PSTRB[0]) reg_block[reg_addr][ 7: 0] <= PWDATA[ 7: 0];
                if(PSTRB[1]) reg_block[reg_addr][15: 8] <= PWDATA[15: 8];
                if(PSTRB[2]) reg_block[reg_addr][23:16] <= PWDATA[23:16];
                if(PSTRB[3]) reg_block[reg_addr][31:24] <= PWDATA[31:24];
            end
        endcase
    end
    // else: when address is invalid, latch original data
end

// reg & fifo read
always_comb begin
    if(reg_rd_en)
        PRDATA = reg_block[reg_addr];
    else if(r_ready && r_valid)
        PRDATA = { {(32-WIDTH){1'b0}}, mem[r_ptr] };
    else
        PRDATA = 32'd0; // if invalid address
end

// fifo write
always_ff @(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        w_ptr <= 0;
    end else if(w_ready && w_valid) begin
        if(PSTRB[0]) mem[w_ptr] <= PWDATA;
        if(w_ptr == fifo_depth - 1)
            w_ptr <= 0;
        else
            w_ptr <= w_ptr + 1;
    end
    //else: when address is invalid, latch original data
end

// fifo read --- update r_ptr
always_ff @( posedge PCLK or negedge PRESETn ) begin
    if(!PRESETn) begin
        r_ptr <= 0;
    end else if(r_ready && r_valid) begin
        if(r_ptr == fifo_depth - 1)
            r_ptr <= 0;
        else
            r_ptr <= r_ptr + 1;
    end
end

// update var count
always_ff @(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        count <= 0;
    end else begin
        case ({w_ready && w_valid, r_ready && r_valid})
            2'b10: count <= count + 1; // write only
            2'b01: count <= count - 1; // read only
            2'b11: count <= count; // read write together, which will never happen in APB bus
            default: count <= count;   // no change or simultaneous read/write
        endcase
    end
end

// empty or full
always_comb begin    
    empty = (count == 0);
    full = (count == fifo_depth);
    w_ready = !full;
    r_valid = !empty;
end

// assertions
`ifdef ASSERT_ON
property p_no_write_when_full;
    @(posedge PCLK) disable iff (!PRESETn)
        w_valid |=> !full;
endproperty

assert property (p_no_write_when_full)
    else $error("[ASSERT FAIL]: Write when FIFO is full!");

property p_no_read_when_empty;
    @(posedge PCLK) disable iff (!PRESETn)
        !(r_ready && empty)
endproperty
assert property (p_no_read_when_empty) 
    else $error("[ASSERT FAIL]: Read when FIFO is empty!");

// assert property (@(posedge PCLK) disable iff (!PRESETn) w_ptr < DEPTH) 
//     else $fatal("[ASSERT_FAIL], w_ptr overflow!");

// assert property (@(posedge PCLK) disable iff (!PRESETn) r_ptr < DEPTH) 
//     else $fatal("[ASSERT_FAIL], r_ptr overflow!"); 
`endif
endmodule
