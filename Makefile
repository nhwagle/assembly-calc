#
# CSF Assignment 2 Makefile
#

# Executables to build for the "all" target
EXES = cPostfixCalc cTests asmPostfixCalc asmTests

# C source files
C_SRCS = cPostfixCalcMain.c cPostfixCalcFuncs.c cPostfixCalcEval.c cTests.c tctest.c

# Assembler source files
ASM_SRCS = asmPostfixCalcMain.S asmPostfixCalcFuncs.S asmPostfixCalcEval.S asmPostfixCalcEval.S

# C compiler flags
CFLAGS = -g -Og -Wall -no-pie

# Flags to use when assembling
ASMFLAGS = -g -no-pie

# Flags to use when linking an executable
LDFLAGS = -no-pie

# Rule for assembling a .S file to produce a .o file
%.o : %.S
	gcc -c $(ASMFLAGS) $*.S -o $*.o

# Rule for compiling and assembling a .c file to produce a .o file
%.o : %.c
	gcc $(CFLAGS) -c $*.c -o $*.o

# Default target: build all executables
all : $(EXES)

# C version of postfix calculator
cPostfixCalc : cPostfixCalcMain.o cPostfixCalcFuncs.o cPostfixCalcEval.o
	gcc -o $@ $(LDFLAGS) cPostfixCalcMain.o cPostfixCalcFuncs.o cPostfixCalcEval.o

# Unit test program for C functions
cTests : cTests.o tctest.o cPostfixCalcFuncs.o cPostfixCalcEval.o
	gcc -o $@ $(LDFLAGS) cTests.o tctest.o cPostfixCalcFuncs.o cPostfixCalcEval.o

# Assembly language version of postfix calculator
# using cPostfixCalcMain.c
asmPostfixCalc : cPostfixCalcMain.o asmPostfixCalcFuncs.o asmPostfixCalcEval.o
	gcc -o $@ $(LDFLAGS) cPostfixCalcMain.o asmPostfixCalcFuncs.o asmPostfixCalcEval.o

# Assembly language version of postfix calculator
# using asmPostfixCalcMain.c (extra credit)
asmPostfixCalc2 : asmPostfixCalcMain.o asmPostfixCalcFuncs.o asmPostfixCalcEval.o
	gcc -o $@ $(LDFLAGS) asmPostfixCalcMain.o asmPostfixCalcFuncs.o asmPostfixCalcEval.o

# Unit test program for assembly language functions
asmTests : cTests.o tctest.o asmPostfixCalcFuncs.o asmPostfixCalcEval.o
	gcc -o $@ $(LDFLAGS) cTests.o tctest.o asmPostfixCalcFuncs.o asmPostfixCalcEval.o

# Clean up generated files (such as object files and executables)
clean :
	rm -f *.s *.o $(EXES) depend.mak

depend.mak :
	touch $@

# This target generates C header file dependencies (so that C modules
# get recompiled whenever their source or included header files get
# modified).
depend :
	gcc -M $(CFLAGS) $(C_SRCS) >> depend.mak

include depend.mak
