/* $Id: structure.h,v 1.4 1997/04/25 17:58:31 steves Exp steves $ */
/* The line above is a revision control system (rcs) header and is needed so */
/* the perl program (hdfgen.pl) will not complain that this include file */
/* doesn't have an rcs header. */
#include "hdfi.h"

struct MAG_data_1sec {

  /* UT time at the start of the periods */
  int32   year;                         /* integer year */
  int32   day;                          /* integer day of year */
  int32   hr;                           /* hour of day */
  int32   min;                          /* min of hour */
  float32 sec;                          /* seconds */
  float64 fp_year;                      /* floating point year */
  float64 fp_doy;                       /* floating point Day of YearDOY */ 
  float64 ACEepoch;                     /* UT time in sec since 1/1/96 */

  /* ACE frame count */
  uint32 SCclock;
      
  /* mag average data */
  float32 Br;
  float32 Bt;
  float32 Bn;

  float32 Bmag;
  float32 Delta;
  float32 Lambda;

  float32 Bgse_x;
  float32 Bgse_y;
  float32 Bgse_z;

  float32 Bgsm_x;
  float32 Bgsm_y;
  float32 Bgsm_z;

  /* data quality for period */
  int32  Quality;                      /* =0 Normal; */
                                       /* =1 Maneuver & Relaxation*/
				       /* =2 Bad data */
};
