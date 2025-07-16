interface apb_if(input logic PCLK);
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

    clocking mon_cb @(posedge PCLK); // sample @ delta 1step of last Ts
        input PADDR;
        input PPROT;
        input PSEL;
        input PENABLE;
        input PWRITE;
        input PWDATA;
        input PSTRB;
        input PREADY;
        input PRDATA;
        input PSLVERR;
    endclocking

    modport DUT (
        input PCLK, PRESETn, PADDR, PPROT, PSEL, PENABLE, PWRITE, PWDATA, PSTRB,
        output PREADY, PRDATA, PSLVERR
    );

    modport DRIVE(
        output PADDR, PPROT, PSTRB, PSEL, PENABLE, PWRITE, PWDATA,
        input  PRDATA, PREADY, PSLVERR, PRESETn
    );

    modport MONITOR (
        clocking mon_cb,
        input PRESETn
    );

endinterface //apb_if