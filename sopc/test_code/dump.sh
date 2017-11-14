#!/bin/bash

mips-linux-gnu-objdump -M gpr-names=numeric,reg-names=numeric -d $1
