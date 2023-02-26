all: test main

main:
	iverilog -o bin/main src/*

test:
	iverilog -o bin/Register_tb tests/Register_tb.v
	bin/Register_tb
	iverilog -o bin/RegisterZero_tb tests/RegisterZero_tb.v
	bin/RegisterZero_tb

clean:
	rm -rf bin/* vcd/*