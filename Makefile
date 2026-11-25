# Makefile for myOS
# just run `make` to build os-image.bin, `make clean` to delete build files

CC = i686-elf-gcc
LD = i686-elf-ld
CFLAGS = -ffreestanding -Wall -Wextra -O0

# grab every .c file in kernel/, drivers/ and cpu/, each one becomes a .o
C_SOURCES = $(wildcard kernel/*.c drivers/*.c cpu/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h cpu/*.h)
OBJ = $(C_SOURCES:.c=.o) cpu/interrupt.o

all: os-image.bin

# final disk image = boot sector + kernel, padded to a 1.44MB floppy size
os-image.bin: boot/boot.bin kernel/kernel.bin
	dd if=/dev/zero of=$@ bs=512 count=2880
	cat $^ | dd of=$@ conv=notrunc

boot/boot.bin: boot/*.asm
	nasm -f bin -I boot/ boot/boot.asm -o $@

# kernel_entry.o has to come first so it's at the start of kernel.bin
kernel/kernel.bin: kernel/kernel_entry.o $(OBJ)
	$(LD) -Ttext 0x1000 --oformat binary $^ -o $@

# any .asm -> .o (for the kernel, not the boot sector)
%.o: %.asm
	nasm -f elf $< -o $@

# any .c -> .o (rebuilds if a header changes too)
%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f os-image.bin boot/*.bin kernel/*.bin kernel/*.o drivers/*.o cpu/*.o
