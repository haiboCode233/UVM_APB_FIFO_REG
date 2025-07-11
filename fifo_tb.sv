`timescale 1ns/1ps

module tb_Sync_FIFO;

  // parameters
  parameter WIDTH = 8;
  parameter MAX_DEPTH = 256;

  // AMBA 4.0 APB Interface
  logic        PCLK;
  logic        PRESETn;
  logic [31:0] PADDR;
  logic [2:0]  PPROT;
  logic        PSEL;
  logic        PENABLE;
  logic        PWRITE;
  logic [31:0] PWDATA;
  logic [3:0]  PSTRB;
  logic        PREADY;
  logic [31:0] PRDATA;
  logic        PSLVERR;

  // FIFO output signals
  logic full;
  logic empty;

  // instantiate DUT
  Sync_FIFO #(
    .WIDTH(WIDTH),
    .MAX_DEPTH(MAX_DEPTH)
  ) dut (    
    // AMBA 4.0 APB Interface
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PADDR(PADDR),
    .PPROT(PPROT),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PWDATA(PWDATA),
    .PSTRB(PSTRB),
    .PREADY(PREADY),
    .PRDATA(PRDATA),
    .PSLVERR(PSLVERR),

    // FIFO output signals
    .full(full),
    .empty(empty)
  );

  // clock generation
  initial PCLK = 0;
  always #5 PCLK = ~PCLK; // 100MHz clock

  // task: reset
  task reset;
    begin
      PRESETn = 0;
      // APB output signals
      @(posedge PCLK);
      @(posedge PCLK);
      PRESETn = 1;
      @(posedge PCLK);
    end
  endtask

  task reg_config;
    begin
    // T0 cycle
    PADDR = 32'h0000_0000;
    PPROT = 3'b010; // normal access; nonsecure access; data access 
    PSEL = 1'b0;
    PENABLE = 1'b0;
    PWRITE = 1'b0;
    PWDATA = 32'h00_00_00_00;
    PSTRB = 4'b0000;
    @(posedge PCLK);
    
    // T1 cycle
    PADDR = 32'h0000_0000; // reg IO
    // PPROT = 3'b010; // fixed setting 
    PSEL = 1'b1;
    PENABLE = 1'b0;
    PWRITE = 1'b1;
    PWDATA = 32'h00_00_00_01; // depth = 8 << (PWDATA - 1)
    PSTRB = 4'b0001; // mask of PWDATA
    @(posedge PCLK);
    
    // T2 cycle
    PENABLE = 1'b1;
    @(posedge PCLK);

    // T3 cycle
    // PADDR and PWDATA remain same to save power
    PSEL = 1'b0;
    PENABLE = 1'b0;
    @(posedge PCLK);
    end
  endtask

  task reg_read;
    begin
    // T1 cycle
    PADDR = 32'h0000_0000; // reg IO
    // PPROT = 3'b010; // fixed
    PSEL = 1'b1;
    PENABLE = 1'b0;
    PWRITE = 1'b0; // read txn
    // PWDATA = $random % 256; // do not need to drive when reading
    PSTRB = 4'b0000; // must remain all 0s when reading
    @(posedge PCLK);
    
    // T2 cycle
    PENABLE = 1'b1;
    @(posedge PCLK);

    // T3 cycle
    // PADDR and PWDATA remain same to save power
    PSEL = 1'b0;
    PENABLE = 1'b0;
    @(posedge PCLK);
    end
  endtask

  task write_single_data;
    begin
    // T1 cycle
    PADDR = 32'h8000_0000; // FIFO IO
    // PPROT = 3'b010; // fixed
    PSEL = 1'b1;
    PENABLE = 1'b0;
    PWRITE = 1'b1; // write txn
    PWDATA = $random % 256; // Max: 255
    PSTRB = 4'b0001; // mask of PWDATA
    @(posedge PCLK);
    
    // T2 cycle
    PENABLE = 1'b1;
    @(posedge PCLK);

    // T3 cycle
    // PADDR and PWDATA remain same to save power
    PSEL = 1'b0;
    PENABLE = 1'b0;
    @(posedge PCLK);
    end
  endtask

  task read_single_data;
    begin
    // T1 cycle
    PADDR = 32'h8000_0000; // FIFO IO
    // PPROT = 3'b010; // fixed
    PSEL = 1'b1;
    PENABLE = 1'b0;
    PWRITE = 1'b0; // read txn
    // PWDATA = $random % 256; // do not need to drive when reading
    PSTRB = 4'b0000; // must remain all 0s when reading
    @(posedge PCLK);
    
    // T2 cycle
    PENABLE = 1'b1;
    @(posedge PCLK);

    // T3 cycle
    // PADDR and PWDATA remain same to save power
    PSEL = 1'b0;
    PENABLE = 1'b0;
    @(posedge PCLK);
    end
  endtask

  // test sequence
  initial begin
    $display("=== Start APB FIFO Simple Test ===");
    // reset
    reset;

    // configure register
    reg_config;

    // front door register reading
    reg_read;
    
    // write data till full
    repeat (8) begin
      write_single_data;
    end

    // try extra write (should not write if full)
    write_single_data;
    $display("=== FIFO Extra Write Test Done ===");

    // read data back
    repeat (8) begin
      read_single_data;
    end

    // try extra read (should not read if empty)
    read_single_data;
    $display("=== FIFO Extra Read Test Done ===");

    @(posedge PCLK);
    @(posedge PCLK);
    @(posedge PCLK);
    // finish simulation
    $display("=== FIFO Simple Test Done ===");
    $finish;
  end

endmodule
