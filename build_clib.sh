#!/bin/sh
clang -c -g original/src/risc-fp.c
clang -c -g original/src/risc.c
clang -c -g original/src/disk.c
clang -c -g original/src/pclink.c
clang -c -g original/src/raw-serial.c
ar rcs librisc.a *.o
rm *.o
