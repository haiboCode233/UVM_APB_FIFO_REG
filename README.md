# <div align="center"> UVM Project of APB Sync FIFO with Depth Reg </div>  
<div align="center"> <b> Haibo Li @ Rice University </div>

## Contents 
- Introduction 
- DUT Structure  
- UVM Structure
- Verification Plan  
- Results

## Introduction 
This project implements a UVM-based functional verification environment for a programmable-depth synchronous FIFO with an AMBA 4.0 APB interface. The DUT supports dynamic configuration of FIFO depth through a memory-mapped register block.

In addition to the test plan and functional coverage, a detailed [development log](./doc/projlog.txt) is maintained with daily records of design decisions, debug sessions, and milestone tracking.

## DUT Structure
<p align="center">
  <img src="./doc/dut.png" width="800"/>
</p>

<div align="center">  
DUT Structure
</div>  

The DUT consists of an APB register interface, a configurable-depth synchronous FIFO, and a register block with 8 memory-mapped registers. The depth_reg field controls FIFO depth, which dynamically adjusts buffer size during operation. 

## UVM Structure
<p align="center">
  <img src="./doc/overall.png" width="800"/>
</p>

<div align="center">  
UVM Structure
</div> 

The UVM environment includes a configurable agent, sequencer, driver, monitor, bfm, scoreboard, coverage collector, and register model integration via adapter and predictor. A virtual sequence and a virtual sequencer coordinate multiple functional tests including register access, FIFO write/read, and reset scenarios. The register model is fully integrated using UVM_RGM and supports frontdoor/backdoor access with coverage hooks.

## Verification Plan
### Register Model Verification Plan
<div align="center">

| TestID | Description                                  | Method    | Stimulus                                             | Expected Result                     | Status | Make CMD |
|--------|----------------------------------------------|-----------|------------------------------------------------------|-------------------------------------|--------|----------|
| REG_01 | Read the default value of reg0               | Frontdoor | reg0.read()                                          | Return 0x0000_0001                  |   <span style="color:green;">PASS</span>|make          |
| REG_02 | Write & read back of reg0                    | Frontdoor | reg0.write() reg0.read()                             | Return write value                  |<span style="color:green;">PASS</span>      |make          |
| REG_03 | Write & read back of reg0 field only | Frontdoor | reg0.depth_sel_fld.write() <br>reg0.depth_sel_fld.read() | Same as REG_02 <br>since APB.PSTRB set  |<span style="color:green;">PASS</span>      |make          |
| REG_04 | Write corner values then read                | Frontdoor | reg0.write() reg0.read()                             | Return write values                 |<span style="color:green;">PASS</span>      |make          |
| REG_05 | Write illegal values to reg0                 | Frontdoor | reg0.write()                                         | Depth is set to 8                   |<span style="color:green;">PASS</span>      |make TESTID=REG_05          |
| REG_06 | Write illegal addresses of RGM               | Frontdoor | reg0.write()                                         | Error flagged                       |<span style="color:green;">PASS</span>      |make TESTID=REG_06          |
| REG_07 | Back door write, frontdoor read              | Mixed     | reg0.write(BACKDOOR) reg0.read()                     | Display write value                 |<span style="color:green;">PASS</span>      |make TESTID=REG_07          |
| REG_08 | Read all dummy_regs                          | Frontdoor | dummy_reg[i].read()                                  | Return 0x0000_0000                  |<span style="color:green;">PASS</span>      |make TESTID=REG_08          |
| REG_09 | Mirror and compare                           | Frontdoor | reg0.set() reg0.mirror()                             | Mirror matches DUT                  |<span style="color:green;">PASS</span>      |make TESTID=REG_09          |
| REG_10 | Coverage bins for depth_sel_fld              | Coverage  | Cover all legal field values                         | All bins hit                        |      |          |

</div>

### FIFO Verification Plan
<div align="center">

| TestID  | Description                    | Depth | Expected Result   | Status | Make CMD |
|---------|--------------------------------|-------|-------------------|--------|----------|
| FIFO_01 | Write and Read                 | 8     | Read Write Value  |        |          |
| FIFO_02 | Write to full w/ 1 GAP         | 8     | No ERR            |        |          |
| FIFO_03 | Write to full w/ 2 GAPs        | 8     | No ERR            |        |          |
| FIFO_04 | Write to full B2B              | 8     | No ERR            |        |          |
| FIFO_05 | Write when full                | 8     | ERR               |        |          |
| FIFO_06 | Write to full, Read till empty | 8     | Read Write Value  |        |          |
| FIFO_07 | Read When empty                | 8     | ERR               |        |          |
| FIFO_08 | 2x FIFO_04                     | 8     | Read Write Value  |        |          |
| FIFO_09 | PSTRB R/W Test                 | 8     | Read Masked Value |        |          |
| FIFO_10 | Coverage Bins                  | /     | /                 |        |          |

</div>

## Results

