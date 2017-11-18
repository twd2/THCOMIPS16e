.PHONY: all
all: rom.coe kernel.coe
	

%.coe: %.asm
	python as.py $^ $*.out
	python conv_coe.py $*.out $@ 16
	python conv_bintxt.py $*.out $*.mif 16

.PHONY: clean
clean:
	-rm *.out *.sym
	-rm *.coe
