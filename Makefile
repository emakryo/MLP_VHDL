all: mlp_tb.ghw

mlp_tb.ghw: mlp.vhd mlp_tb.vhd l1.vhd arith/*.vhd
	ghdl -i --workdir=ghdl */*.vhd *.vhd
	ghdl -m --workdir=ghdl mlp_tb
	ghdl -r --workdir=ghdl mlp_tb --stop-time=1ps --wave=mlp_tb.ghw

l1_tb.ghw: l1_tb.vhd l1.vhd arith/*.vhd
	ghdl -i --workdir=ghdl */*.vhd *.vhd
	ghdl -m --workdir=ghdl l1_tb
	ghdl -r --workdir=ghdl l1_tb --stop-time=1ps --wave=l1_tb.ghw

clean:
	ghdl --clean --workdir=ghdl
	rm -rf *.o

.PHONY: all clean
