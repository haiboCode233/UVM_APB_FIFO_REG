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

    modport DUT (
        input PCLK, PRESETn, PADDR, PPROT, PSEL, PENABLE, PWRITE, PWDATA, PSTRB,
        output PREADY, PRDATA, PSLVERR
    );

    modport DRIVE(
        output PADDR, PPROT, PSTRB, PSEL, PENABLE, PWRITE, PWDATA,
        input  PRDATA, PREADY, PSLVERR, PRESETn
    );

endinterface //apb_if