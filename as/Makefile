.PHONY: all
all: kernel.coe
	

%.coe: %.asm
	python as.py $^ $*.out
	python conv_coe.py $*.out $@ 16

.PHONY: clean
clean:
	-rm *.out *.sym
	-rm *.coe
