CC=/opt/riscv/bin/riscv32-unknown-linux-gnu-gcc
AS=/opt/riscv/bin/riscv32-unknown-linux-gnu-as
COPTS= -Wall -pedantic 

all : test
	./gen_mem.sh test
	rm setup.o test.o

test : test.o setup.o
	echo "---------------------------------------------------------" >> /dev/null
	echo "-- Do not call anything main() - it will end up linked at" >> /dev/null
	echo "-- the start of the program, rather than the setup code"   >> /dev/null
	echo "---------------------------------------------------------" >> /dev/null
	/opt/riscv/bin/riscv32-unknown-linux-gnu-ld -Ttext 0xF0000000 -Tdata 0x10000000 -T linker_script setup.o test.o -o test

setup.o : setup.s
	$(AS) -o setup.o --march=rv32i setup.s 

test.o : test.c
	$(CC) -c test.c $(COPTS)

