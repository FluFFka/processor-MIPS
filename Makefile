all: main

main:
	iverilog -o bin/main src/CPU.v

test:
	iverilog -o bin/Register_tb tests/Register_tb.v
	bin/Register_tb
	iverilog -o bin/RegisterZero_tb tests/RegisterZero_tb.v
	bin/RegisterZero_tb
	iverilog -o bin/CPU_tb tests/CPU_tb.v
	bin/CPU_tb

clean:
	rm -rf bin/* vcd/*