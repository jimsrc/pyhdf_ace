#!/bin/bash
CC = gcc        # gnu c compiler
CFLAGS= #-g for debugging

# You will need to set this on your system
HDFHOME=${HOME}/local

LIBDIR = ${HDFHOME}/lib
INC =${HDFHOME}/include

# These are system dependent variables (currently set for Solaris)
# Look at your HDF README file for information on your platform
HDFLIBS = -lmfhdf -ldf -ljpeg -lz -lsz -lnsl

# Some of the libraries on our system are here. You may need to change this.
LIBDIR2 = ${HDFHOME}/lib2

all: wr_test rd_test	# create these executable files

rd_test: rd_test.o hdf_test.o
	$(CC) ${CFLAGS} $^ -I${INC} -L${LIBDIR} ${HDFLIBS} ${MLIBS} -o $@ 

rd_test.o: rd_test.c
	$(CC) ${CFLAGS} -c $< -o $@ -I${INC} -L${LIBDIR}

wr_test: wr_test.o hdf_test.o
	$(CC) ${CFLAGS} $^ -I${INC} -L${LIBDIR} ${HDFLIBS} ${MLIBS} -o $@ 

wr_test.o: wr_test.c
	$(CC) ${CFLAGS} -c $< -o $@ -I${INC} -L${LIBDIR}

hdf_test.o: hdf_test.c
	$(CC) ${CFLAGS} -c $< -o $@ -I${INC} -L${LIBDIR}

hdf_test.c: structure.h hdfgen.pl
	./hdfgen.pl $< $@ F=test_func

clean:
	rm -r hdf_test.c hdf_test.o rd_test.o wr_test.o rd_test wr_test

#--- run the compiled executables
hfile = ex1.hdf
run_write:
	export LD_LIBRARY_PATH=${LIBDIR}
	./wr_test ${hfile}

run_read:
	export LD_LIBRARY_PATH=${LIBDIR}
	./rd_test ${hfile}


#EOF
