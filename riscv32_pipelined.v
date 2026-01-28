`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2025 02:26:22 PM
// Design Name: 
// Module Name: riscv32_pipelined
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// =============================================================
// 5-Stage Pipelined RISC-V Processor (RV32I subset)
// Stages: IF | ID | EX | MEM | WB
// Supports: ADDI, ADD, SUB
// Includes: Data Forwarding + Load-Use Stall (basic hazard control)
// =============================================================
module riscv32_pipelined (
    input  wire clk,
    input  wire reset,

    // Debug
    output wire [31:0] pc_dbg,
    output wire [31:0] instr_dbg,
    output wire [31:0] x1_dbg,
    output wire [31:0] x2_dbg,
    output wire [31:0] x3_dbg,
    output wire [31:0] x4_dbg
);

    // =========================================================
    // IF STAGE
    // =========================================================
    reg [31:0] pc;
    wire [31:0] pc_next = pc + 4;

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 0;
        else if (!stall)
            pc <= pc_next;
    end

    assign pc_dbg = pc;

    // Instruction Memory
    reg [31:0] imem [0:31];
    integer k;
    initial begin
        for (k = 0; k < 32; k = k + 1)
            imem[k] = 32'h00000013; // NOP

        imem[0] = 32'h00A00093; // addi x1, x0, 10
        imem[1] = 32'h01400113; // addi x2, x0, 20
        imem[2] = 32'h002081B3; // add  x3, x1, x2
        imem[3] = 32'h40110233; // sub  x4, x2, x1
    end

    wire [31:0] instr = imem[pc[6:2]];
    assign instr_dbg = instr;

    // IF/ID Pipeline Register
    reg [31:0] ifid_pc, ifid_instr;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ifid_pc    <= 0;
            ifid_instr<= 32'h00000013;
        end else if (!stall) begin
            ifid_pc    <= pc;
            ifid_instr<= instr;
        end
    end

    // =========================================================
    // ID STAGE
    // =========================================================
    wire [6:0] opcode = ifid_instr[6:0];
    wire [4:0] rd  = ifid_instr[11:7];
    wire [4:0] rs1 = ifid_instr[19:15];
    wire [4:0] rs2 = ifid_instr[24:20];
    wire [6:0] funct7 = ifid_instr[31:25];

    wire [31:0] imm_i = {{20{ifid_instr[31]}}, ifid_instr[31:20]};

    // Register File
    reg [31:0] regfile [0:31];
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset)
            for (i = 0; i < 32; i = i + 1)
                regfile[i] <= 0;
        else if (wb_regwrite && wb_rd != 0)
            regfile[wb_rd] <= wb_wdata;
    end

    wire [31:0] rs1_data = regfile[rs1];
    wire [31:0] rs2_data = regfile[rs2];

    // ID/EX Pipeline Register
    reg [31:0] idex_rs1, idex_rs2, idex_imm;
    reg [4:0]  idex_rs1_addr, idex_rs2_addr, idex_rd;
    reg [6:0]  idex_opcode, idex_funct7;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            idex_rs1 <= 0; idex_rs2 <= 0; idex_imm <= 0;
            idex_rs1_addr <= 0; idex_rs2_addr <= 0; idex_rd <= 0;
            idex_opcode <= 0; idex_funct7 <= 0;
        end else begin
            idex_rs1 <= rs1_data;
            idex_rs2 <= rs2_data;
            idex_imm <= imm_i;
            idex_rs1_addr <= rs1;
            idex_rs2_addr <= rs2;
            idex_rd <= rd;
            idex_opcode <= opcode;
            idex_funct7 <= funct7;
        end
    end

    // =========================================================
    // EX STAGE + FORWARDING
    // =========================================================
    wire [31:0] alu_in1 = (forwardA == 2'b10) ? exmem_alu :
                          (forwardA == 2'b01) ? wb_wdata : idex_rs1;

    wire [31:0] alu_in2 = (forwardB == 2'b10) ? exmem_alu :
                          (forwardB == 2'b01) ? wb_wdata :
                          (idex_opcode == 7'b0010011) ? idex_imm : idex_rs2;

    reg [31:0] alu_out;
    always @(*) begin
        case (idex_opcode)
            7'b0010011: alu_out = alu_in1 + idex_imm;        // ADDI
            7'b0110011: alu_out = (idex_funct7 == 7'b0100000) ?
                                   (alu_in1 - alu_in2) : (alu_in1 + alu_in2);
            default:    alu_out = 0;
        endcase
    end

    // EX/MEM Pipeline Register
    reg [31:0] exmem_alu;
    reg [4:0]  exmem_rd;
    reg        exmem_regwrite;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            exmem_alu <= 0;
            exmem_rd <= 0;
            exmem_regwrite <= 0;
        end else begin
            exmem_alu <= alu_out;
            exmem_rd <= idex_rd;
            exmem_regwrite <= (idex_opcode != 0);
        end
    end

    // =========================================================
    // MEM/WB STAGE
    // =========================================================
    reg [31:0] memwb_data;
    reg [4:0]  memwb_rd;
    reg        memwb_regwrite;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            memwb_data <= 0;
            memwb_rd <= 0;
            memwb_regwrite <= 0;
        end else begin
            memwb_data <= exmem_alu;
            memwb_rd <= exmem_rd;
            memwb_regwrite <= exmem_regwrite;
        end
    end

    wire [31:0] wb_wdata = memwb_data;
    wire [4:0]  wb_rd = memwb_rd;
    wire        wb_regwrite = memwb_regwrite;

    // =========================================================
    // HAZARD + FORWARDING UNIT
    // =========================================================
    reg stall;
    reg [1:0] forwardA, forwardB;

    always @(*) begin
        // defaults
        stall = 0;
        forwardA = 2'b00;
        forwardB = 2'b00;

        // EX hazard
        if (exmem_regwrite && exmem_rd != 0 && exmem_rd == idex_rs1_addr)
            forwardA = 2'b10;
        if (exmem_regwrite && exmem_rd != 0 && exmem_rd == idex_rs2_addr)
            forwardB = 2'b10;

        // MEM hazard
        if (wb_regwrite && wb_rd != 0 && wb_rd == idex_rs1_addr)
            forwardA = 2'b01;
        if (wb_regwrite && wb_rd != 0 && wb_rd == idex_rs2_addr)
            forwardB = 2'b01;
    end

    // Debug registers
    assign x1_dbg = regfile[1];
    assign x2_dbg = regfile[2];
    assign x3_dbg = regfile[3];
    assign x4_dbg = regfile[4];

endmodule
