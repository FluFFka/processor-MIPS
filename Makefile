all: main

main:
	iverilog -o bin/main src/*.v

test:
	iverilog -o bin/Register_tb tests/Register_tb.v src/*.v
	bin/Register_tb
	iverilog -o bin/RegisterZero_tb tests/RegisterZero_tb.v src/*.v
	bin/RegisterZero_tb
	iverilog -o bin/CPU_tb tests/CPU_tb.v src/*.v
	bin/CPU_tb

clean:
	rm -rf bin/* vcd/*