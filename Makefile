all:
	iverilog -o bin/main src/*

tests:
	iverilog -o bin/register_tb test/register_tb.v
	bin/register_tb

clean:
	rm -rf bin/*