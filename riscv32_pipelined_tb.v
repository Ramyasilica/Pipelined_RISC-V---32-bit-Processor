`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2025 02:27:14 PM
// Design Name: 
// Module Name: riscv32_pipelined_tb
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


module riscv32_pipelined_tb();
    reg clk;
    reg reset;

    wire [31:0] pc;
    wire [31:0] instr;
    wire [31:0] x1, x2, x3, x4;

    riscv32_pipelined dut (
        .clk(clk),
        .reset(reset),
        .pc_dbg(pc),
        .instr_dbg(instr),
        .x1_dbg(x1),
        .x2_dbg(x2),
        .x3_dbg(x3),
        .x4_dbg(x4)
    );

    // 10 ns clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;

        #20 reset = 0;   // release reset
        #300 $finish;
    end

endmodule

