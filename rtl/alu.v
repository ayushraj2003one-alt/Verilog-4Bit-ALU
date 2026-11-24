// ==============================================================================
// Module: 4-Bit Arithmetic Logic Unit (ALU)
// Description: Fully synthesizable 4-bit ALU featuring 16 distinct arithmetic,
//              logical, shifting, rotating, and comparison operations with status flags.
// Author: Ayush Raj
// Standard: IEEE 1364-2001 Verilog HDL
// ==============================================================================

module alu (
    input  wire [3:0] A,             // 4-bit primary operand A
    input  wire [3:0] B,             // 4-bit secondary operand B
    input  wire [3:0] ALU_Sel,       // 4-bit operation select code (16 operations)
    output reg  [7:0] ALU_Result,    // 8-bit result (supports full 4x4 multiplication without overflow)
    output wire       Carry_Out,     // Arithmetic Carry / Borrow Flag
    output wire       Zero_Flag,     // Zero Detection Flag (asserts when ALU_Result == 0)
    output wire       Negative_Flag, // Negative Sign Flag (asserts on negative result / borrow)
    output wire       Overflow_Flag  // Signed Arithmetic Overflow Flag
);

  // --------------------------------------------------------------------------
  // Core Combinational Logic for 16 Operations
  // --------------------------------------------------------------------------
  always @(*) begin
    case (ALU_Sel)
      // Arithmetic Operations
      4'b0000: ALU_Result = {4'b0000, A} + {4'b0000, B};                    // 0: Addition
      4'b0001: ALU_Result = (A >= B) ? ({4'b0000, A} - {4'b0000, B})        // 1: Subtraction (magnitude)
                                     : ({4'b0000, B} - {4'b0000, A});       
      4'b0010: ALU_Result = A * B;                                          // 2: Full 4x4 Multiplication (Max: 15x15=225)
      4'b0011: ALU_Result = (B != 4'd0) ? ({4'b0000, (A / B)}) : 8'd0;     // 3: Division (protected against divide-by-zero)

      // Shift & Rotate Operations
      4'b0100: ALU_Result = {3'b000, A, 1'b0};                              // 4: Logical Shift Left (A << 1)
      4'b0101: ALU_Result = {5'b00000, A[3:1]};                             // 5: Logical Shift Right (A >> 1)
      4'b0110: ALU_Result = {4'b0000, A[2:0], A[3]};                        // 6: Rotate Left Circular (ROL)
      4'b0111: ALU_Result = {4'b0000, A[0], A[3:1]};                        // 7: Rotate Right Circular (ROR)

      // Bitwise Logic Operations
      4'b1000: ALU_Result = {4'b0000, (A & B)};                             // 8: Bitwise AND
      4'b1001: ALU_Result = {4'b0000, (A | B)};                             // 9: Bitwise OR
      4'b1010: ALU_Result = {4'b0000, (A ^ B)};                             // 10: Bitwise XOR
      4'b1011: ALU_Result = {4'b0000, ~(A | B)};                            // 11: Bitwise NOR
      4'b1100: ALU_Result = {4'b0000, ~(A & B)};                            // 12: Bitwise NAND
      4'b1101: ALU_Result = {4'b0000, ~(A ^ B)};                            // 13: Bitwise XNOR

      // Relational / Comparison Operations
      4'b1110: ALU_Result = (A > B)  ? 8'd1 : 8'd0;                         // 14: Greater Than (A > B)
      4'b1111: ALU_Result = (A == B) ? 8'd1 : 8'd0;                         // 15: Equal To (A == B)

      default: ALU_Result = 8'd0;
    endcase
  end

  // --------------------------------------------------------------------------
  // Status Flags Generation Logic
  // --------------------------------------------------------------------------
  // Zero Flag (Z): Asserts high when all 8 output bits are zero
  assign Zero_Flag = (ALU_Result == 8'd0);

  // Carry Out (C): 
  // - On Addition: Asserts if sum exceeds 4 bits (bit 4 is high)
  // - On Subtraction: Acts as Borrow flag when A < B
  assign Carry_Out = (ALU_Sel == 4'b0000) ? (A + B > 4'd15) :
                     (ALU_Sel == 4'b0001) ? (A < B) : 1'b0;

  // Negative Flag (N): Asserts if subtraction produced a negative number
  assign Negative_Flag = (ALU_Sel == 4'b0001) ? (A < B) : 1'b0;

  // Overflow Flag (V): Signed 4-bit overflow indicator
  // - On Addition: Overflow occurs when adding two like signs produces an opposite sign
  // - On Subtraction: Overflow occurs when subtracting opposite signs produces incorrect sign
  assign Overflow_Flag = (ALU_Sel == 4'b0000) ? (~(A[3] ^ B[3]) & (A[3] ^ ALU_Result[3])) :
                         (ALU_Sel == 4'b0001) ? ((A[3] ^ B[3])  & (A[3] ^ ALU_Result[3])) : 1'b0;

endmodule
