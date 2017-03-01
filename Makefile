all: l1_tb.ghw

l1_tb.ghw: l1_tb.vhd l1.vhd arith/add.vhd arith/mul.vhd
	ghdl -i --workdir=ghdl */*.vhd *.vhd
	ghdl -m --workdir=ghdl l1_tb
	ghdl -r --workdir=ghdl l1_tb --stop-time=1ps --wave=l1_tb.ghw

clean:
	ghdl --clean --workdir=ghdl
	rm -rf *.o

.PHONY: all clean
