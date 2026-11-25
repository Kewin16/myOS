# Makefile for myOS
# just run `make` to build os-image.bin, `make clean` to delete build files

CC = i686-elf-gcc
LD = i686-elf-ld
CFLAGS = -ffreestanding -Wall -Wextra -O0

all: os-image.bin

# final disk image = boot sector + kernel, padded to a 1.44MB floppy size
os-image.bin: boot/boot.bin kernel/kernel.bin
	dd if=/dev/zero of=$@ bs=512 count=2880
	cat $^ | dd of=$@ conv=notrunc

boot/boot.bin: boot/*.asm
	nasm -f bin -I boot/ boot/boot.asm -o $@

# kernel_entry.o has to come first so it's at the start of kernel.bin
kernel/kernel.bin: kernel/kernel_entry.o kernel/kernel.o
	$(LD) -Ttext 0x1000 --oformat binary $^ -o $@

kernel/kernel_entry.o: kernel/kernel_entry.asm
	nasm -f elf $< -o $@

kernel/kernel.o: kernel/kernel.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f os-image.bin boot/*.bin kernel/*.bin kernel/*.o
