# Pipelined_RISC-V---32-bit-Processor

 🌍 Welcome World!

Welcome to my **fifth GitHub repository** 🎉
This project presents a **RISC-V 32-bit pipeline-based processor** implemented using **Verilog HDL** and verified through **functional simulation using Vivado**.

This repository is created to **learn, implement, and understand pipelined processor architecture** at the RTL level by designing and simulating a **RISC-V RV32 pipelined core**.


📌 What is a Pipelined RISC-V Processor?

A **pipelined processor** improves performance by **overlapping multiple instruction stages**, allowing different instructions to be processed simultaneously.

In a **RISC-V pipeline**, instruction execution is divided into stages such as:

* Instruction Fetch (IF)
* Instruction Decode (ID)
* Execute (EX)
* Write Back (WB)

This approach increases **instruction throughput** compared to a single-cycle design.


## Project Overview

In this repository, **I have implemented a 32-bit RISC-V pipelined processor using Verilog HDL**.

This project focuses on:
* Implementing **pipeline stages**
* Executing multiple instructions concurrently
* Observing **register updates across clock cycles**
* Verifying correct pipeline behavior through simulation waveforms

The processor is verified using a **testbench**, and correctness is confirmed by analyzing **PC, instruction, and register activity** in the waveform.


## Processor Architecture (High Level)

The pipelined RISC-V processor consists of:

* **Program Counter (PC)** – Generates instruction addresses
* **Instruction Fetch Logic** – Fetches instructions
* **Instruction Decode Logic** – Decodes opcode and operands
* **Register File** – Stores 32 general-purpose registers
* **Execution Logic** – Performs arithmetic operations
* **Pipeline Registers** – Hold intermediate values between stages


## Pipeline Stage Diagram

The RISC-V 32-bit pipelined processor is divided into multiple stages so that **different instructions are processed in parallel** during each clock cycle.

## 🔄 Pipeline Stages


        ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌──────────┐
PC ───▶ │   IF    │──▶│   ID    │──▶│   EX    │──▶│   WB     │
        │Fetch    │   │Decode   │   │Execute │   │WriteBack │
        └─────────┘   └─────────┘   └─────────┘   └──────────┘

## 📘 Stage Description

**1. IF – Instruction Fetch**

* Program Counter (PC) provides instruction address
* Instruction is fetched from instruction memory

**2. ID – Instruction Decode**

* Opcode and operands are decoded
* Source registers are read from register file

**3. EX – Execute**

* Arithmetic or logical operation is performed
* ALU computes the result

**4. WB – Write Back**

* Result is written back to destination register
* Register values update after pipeline latency


## Pipeline Behavior (From Waveform)

* Each stage works on a **different instruction simultaneously**
* Register updates are delayed due to pipeline stages
* Program Counter increments every cycle
* This confirms **instruction-level parallelism**


## RISC-V Registers

RISC-V defines **32 general-purpose registers**, each **32 bits wide**:

* `x0` → Hardwired to zero
* `x1 – x31` → Used for computation and data storage

In this simulation, the following registers are observed:

* `x1`
* `x2`
* `x3`
* `x4`

These registers update progressively as instructions pass through the pipeline stages.


##  Processor Signals (From Waveform)

The key signals observed from the simulation waveform are:

* `clk` – System clock
* `reset` – Initializes the processor
* `pc[31:0]` – Program Counter
* `instr[31:0]` – Current instruction in the pipeline
* `x1[31:0]` – Register x1
* `x2[31:0]` – Register x2
* `x3[31:0]` – Register x3
* `x4[31:0]` – Register x4

These signals demonstrate instruction flow through the pipeline.


##  Working of the Pipelined Processor

The processor functions as follows:

1. **Clock starts toggling**
2. **Reset is deasserted**, enabling pipeline operation
3. Program Counter (`pc`) continuously updates
4. Instructions are fetched and enter the pipeline
5. Multiple instructions execute simultaneously in different stages
6. Register values update after passing through pipeline stages
7. Pipeline continues execution every clock cycle

This confirms **overlapped instruction execution**, which is the key feature of pipelining.


 📊 Simulation Results (Waveform Analysis)

From the simulation waveform:

* `clk` toggles continuously
* `reset` is low → processor is active
* `pc = 0x00000078`
* `instr = 0x00000013`

## Instruction Decode

0x00000013 → ADDI x0, x0, 0


This is a **NOP instruction**, commonly used to validate pipeline flow without affecting register values.

## Register Observations

From the waveform:

* `x1 = 0x0000000A`
* `x2 = 0x00000014`
* `x3 = 0x0000001E`
* `x4 = 0x00000014`

✅ Registers update correctly
✅ Pipeline stages operate without stalling
✅ No invalid or unknown values

This confirms the **pipeline-based RISC-V processor is working correctly**.


## 🖼️ Output Waveform

The waveform clearly shows:

* Continuous clock operation
* Instruction flow through pipeline stages
* Correct Program Counter progression
* Register updates occurring after pipeline latency

![image alt](https://github.com/Ramyasilica/Pipelined_RISC-V---32-bit-Processor/blob/bdd1dabfdb4aacb143e96335cf7984efe9d96116/Pipelined_RISC%20V-32%20bit%20Processor.jpg)

🧾 Conclusion

This repository demonstrates a **working RISC-V 32-bit pipelined processor** implemented in Verilog HDL.
The simulation waveform verifies correct pipeline execution, register updates, and instruction flow, making this project a strong foundation for adding features such as hazard handling, forwarding, and memory stages.


## Thank you for visiting!
This is my **fifth GitHub repository**, and more advanced RTL and processor-based projects will be added soon 🚀
Feel free to explore, learn, and suggest improvements.

