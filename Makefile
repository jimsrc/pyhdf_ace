CC = gcc        # gnu c compiler
CFLAGS=

# You will need to set this on your system
HDFHOME=/home/mussel9/asc/HDF4.1r1

LIBDIR = ${HDFHOME}/lib
INC =${HDFHOME}/include

# These are system dependent variables (currently set for Solaris)
# Look at your HDF README file for information on your platform
HDFLIBS = -lmfhdf -ldf -ljpeg -lz -lnsl

# Some of the libraries on our system are here. You may need to change this.
LIBDIR2 = /usr/local/lang/SUNWspro/lib

all: wr_test rd_test	# create these executable files

rd_test: rd_test.o hdf_test.o
	$(CC) ${CFLAGS} $^ -I${INC} -L${LIBDIR} -L${LIBDIR2} ${HDFLIBS} ${MLIBS} -o $@ 

rd_test.o: rd_test.c
	$(CC) ${CFLAGS} -c $< -o $@ -I${INC} 

wr_test: wr_test.o hdf_test.o
	$(CC) ${CFLAGS} $^ -I${INC} -L${LIBDIR} -L${LIBDIR2} ${HDFLIBS} ${MLIBS} -o $@ 

wr_test.o: wr_test.c
	$(CC) ${CFLAGS} -c $< -o $@ -I${INC} 

hdf_test.o: hdf_test.c
	$(CC) ${CFLAGS} -c $< -o $@ -I${INC} 

hdf_test.c: structure.h hdfgen.pl
	hdfgen.pl $< $@ F=test_func
