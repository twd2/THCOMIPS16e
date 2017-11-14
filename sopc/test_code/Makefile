AS = mips-linux-gnu-as
OBJCOPY = mips-linux-gnu-objcopy

.PHONY: all
all: rom.mif
	

%.mif: %.s
	$(AS) $^ -o $*.out
	$(OBJCOPY) -j .text -O binary $*.out $*.bin
	python3 conv_mif.py $*.bin $@ 32

.PHONY: clean
clean:
	-rm *.out
	-rm *.bin
	-rm *.mif
