/* $Id: structure.h,v 1.4 1997/04/25 17:58:31 steves Exp steves $ */
/* The line above is a revision control system (rcs) header and is needed so */
/* the perl program (hdfgen.pl) will not complain that this include file */
/* doesn't have an rcs header. */
#include "hdfi.h"

#define NUM1 3
#define NUM2 5

struct TestSet
{
  uint32 sctime_readout;                /* 32 bit spacecraft readout time */
  uint32 QAC;                    	/* Quality counter */
  int16 test1[5];			/* one dim array */
  int8 test_array[NUM1][NUM2];  	/* two dim array */
};
