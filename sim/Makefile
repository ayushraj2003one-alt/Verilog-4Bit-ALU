# Makefile for Verilog 4-Bit ALU Simulation
SIM = iverilog
VVP = vvp
WAVE = gtkwave

RTL = ../rtl/alu.v
TB  = ../tb/alu_tb.v
OUT = alu_sim.vvp
VCD = dump.vcd

all: compile run

compile:
	$(SIM) -o $(OUT) $(RTL) $(TB)

run:
	$(VVP) $(OUT)

wave:
	$(WAVE) $(VCD) &

clean:
	rm -f $(OUT) $(VCD)

.PHONY: all compile run wave clean
