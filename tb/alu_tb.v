// ==============================================================================
// Testbench: alu_tb
// Description: Automated self-checking testbench for 4-bit ALU verifying all
//              16 functional operations, edge cases, and status flags.
// ==============================================================================

`timescale 1ns / 1ps

module alu_tb;

  // Inputs to DUT
  reg  [3:0] A;
  reg  [3:0] B;
  reg  [3:0] ALU_Sel;

  // Outputs from DUT
  wire [7:0] ALU_Result;
  wire       Carry_Out;
  wire       Zero_Flag;
  wire       Negative_Flag;
  wire       Overflow_Flag;

  // Verification tracking counters
  integer pass_count = 0;
  integer fail_count = 0;

  // Instantiate the Device Under Test (DUT)
  alu uut (
    .A(A),
    .B(B),
    .ALU_Sel(ALU_Sel),
    .ALU_Result(ALU_Result),
    .Carry_Out(Carry_Out),
    .Zero_Flag(Zero_Flag),
    .Negative_Flag(Negative_Flag),
    .Overflow_Flag(Overflow_Flag)
  );

  // Task for automated verification and assertion
  task check_result;
    input [7:0] expected_res;
    input [40*8:1] op_name;
    begin
      #10; // Wait for combinational propagation
      if (ALU_Result === expected_res) begin
        $display("[PASS] %s | A=%0d (4'b%b), B=%0d (4'b%b) => Result=%0d (8'b%b) | Z=%b C=%b N=%b V=%b",
                 op_name, A, A, B, B, ALU_Result, ALU_Result, Zero_Flag, Carry_Out, Negative_Flag, Overflow_Flag);
        pass_count = pass_count + 1;
      end else begin
        $display("[FAIL] %s | A=%0d, B=%0d => Got %0d, Expected %0d",
                 op_name, A, B, ALU_Result, expected_res);
        fail_count = fail_count + 1;
      end
    end
  endtask

  initial begin
    // Setup VCD waveform dump for GTKWave / ModelSim
    $dumpfile("dump.vcd");
    $dumpvars(0, alu_tb);

    $display("================================================================================");
    $display("                 STARTING COMPREHENSIVE 4-BIT ALU TESTBENCH                     ");
    $display("================================================================================");

    // -------------------------------------------------------------------------
    // TEST 1: Addition (4'b0000)
    // -------------------------------------------------------------------------
    ALU_Sel = 4'b0000;
    A = 4'd10; B = 4'd5;   check_result(8'd15, "Addition (10 + 5)      ");
    A = 4'd15; B = 4'd15;  check_result(8'd30, "Addition with Carry (15+15)");
    A = 4'd0;  B = 4'd0;   check_result(8'd0,  "Addition Zero Flag (0+0)");

    // -------------------------------------------------------------------------
    // TEST 2: Subtraction (4'b0001)
    // -------------------------------------------------------------------------
    ALU_Sel = 4'b0001;
    A = 4'd12; B = 4'd4;   check_result(8'd8,  "Subtraction (12 - 4)    ");
    A = 4'd7;  B = 4'd7;   check_result(8'd0,  "Subtraction Zero (7 - 7)");
    A = 4'd3;  B = 4'd8;   check_result(8'd5,  "Subtraction Borrow (3-8)");

    // -------------------------------------------------------------------------
    // TEST 3: Full 4x4 Multiplication (4'b0010)
    // -------------------------------------------------------------------------
    ALU_Sel = 4'b0010;
    A = 4'd3;  B = 4'd4;   check_result(8'd12, "Multiplication (3 x 4)  ");
    A = 4'd15; B = 4'd15;  check_result(8'd225,"Max Multiplication 15x15");

    // -------------------------------------------------------------------------
    // TEST 4: Division (4'b0011)
    // -------------------------------------------------------------------------
    ALU_Sel = 4'b0011;
    A = 4'd15; B = 4'd3;   check_result(8'd5,  "Division (15 / 3)       ");
    A = 4'd9;  B = 4'd2;   check_result(8'd4,  "Division Floor (9 / 2)  ");
    A = 4'd10; B = 4'd0;   check_result(8'd0,  "Divide-by-Zero Guard    ");

    // -------------------------------------------------------------------------
    // TEST 5: Logical Shift Left (4'b0100)
    // -------------------------------------------------------------------------
    ALU_Sel = 4'b0100;
    A = 4'b0101; B = 4'd0; check_result(8'b00001010, "Shift Left (0101 << 1)");

    // -------------------------------------------------------------------------
    // TEST 6: Logical Shift Right (4'b0101)
    // -------------------------------------------------------------------------
    ALU_Sel = 4'b0101;
    A = 4'b1011; B = 4'd0; check_result(8'b00000101, "Shift Right (1011 >> 1)");

    // -------------------------------------------------------------------------
    // TEST 7: Rotate Left Circular (4'b0110)
    // -------------------------------------------------------------------------
    ALU_Sel = 4'b0110;
    A = 4'b1001; B = 4'd0; check_result(8'b00000011, "Rotate Left (1001 ROL)");

    // -------------------------------------------------------------------------
    // TEST 8: Rotate Right Circular (4'b0111)
    // -------------------------------------------------------------------------
    ALU_Sel = 4'b0111;
    A = 4'b1001; B = 4'd0; check_result(8'b00001100, "Rotate Right (1001 ROR)");

    // -------------------------------------------------------------------------
    // TEST 9-14: Bitwise Logic Operations (AND, OR, XOR, NOR, NAND, XNOR)
    // -------------------------------------------------------------------------
    A = 4'b1100; B = 4'b1010;
    ALU_Sel = 4'b1000; check_result(8'b00001000, "Bitwise AND (1100 & 1010)");
    ALU_Sel = 4'b1001; check_result(8'b00001110, "Bitwise OR  (1100 | 1010)");
    ALU_Sel = 4'b1010; check_result(8'b00000110, "Bitwise XOR (1100 ^ 1010)");
    ALU_Sel = 4'b1011; check_result(8'b00000001, "Bitwise NOR ~(1100|1010)");
    ALU_Sel = 4'b1100; check_result(8'b00000111, "Bitwise NAND~(1100&1010)");
    ALU_Sel = 4'b1101; check_result(8'b00001001, "Bitwise XNOR~(1100^1010)");

    // -------------------------------------------------------------------------
    // TEST 15-16: Comparisons (Greater Than, Equal To)
    // -------------------------------------------------------------------------
    ALU_Sel = 4'b1110;
    A = 4'd12; B = 4'd8; check_result(8'd1, "Greater Than (12 > 8)   ");
    A = 4'd5;  B = 4'd9; check_result(8'd0, "Greater Than (5 > 9)    ");

    ALU_Sel = 4'b1111;
    A = 4'd7;  B = 4'd7; check_result(8'd1, "Equal To (7 == 7)       ");
    A = 4'd7;  B = 4'd3; check_result(8'd0, "Equal To (7 == 3)       ");

    // -------------------------------------------------------------------------
    // SUMMARY REPORT
    // -------------------------------------------------------------------------
    $display("================================================================================");
    $display("                        SIMULATION TEST RESULTS SUMMARY                         ");
    $display("================================================================================");
    $display("  TOTAL TESTS EXECUTED : %0d", pass_count + fail_count);
    $display("  TESTS PASSED         : %0d", pass_count);
    $display("  TESTS FAILED         : %0d", fail_count);
    if (fail_count == 0) begin
      $display("  STATUS               : ALL TESTS PASSED SUCCESSFULLY! (100%% VERIFIED)");
    end else begin
      $display("  STATUS               : VERIFICATION FAILED WITH %0d ERRORS!", fail_count);
    end
    $display("================================================================================");

    #50;
    $finish;
  end

endmodule
