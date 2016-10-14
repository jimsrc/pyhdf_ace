/* filename:	wr_test

 * usage:	wr_test hdf_filename

 * purpose:	Creates an HDF file (hdf_filename) and then writes data to it.

 * perl generated code:	init_cr_test_func -  create for writing 
 * 			write_test_func -    write to hdf_filename
 * 			close_wr_test_func - Close access to Vdata and SDdata 

 * HDF calls:		Hopen -    Creates the HDF file (hdf_filename)
 * 			Vstart -   Allows writing of Vdata 
 * 			SDstart -  Allows writing of SDdata
 * 			HEprint -  Prints out HDF errors
 * 			HEclear -  Clears error buffer
 * 			Vend -     End Vdata attachment
 * 			SDend -    End SDdata attachment
 * 			Hclose -   Close the HDF file
 **************************************************************************/
#include <stdio.h>
#include <string.h>

#include "structure.h"	/* user created file that includes the data structure */

/* HDF include files */
#include "df.h"
#include "mfhdf.h"

void main(argc, argv)	
int argc;
char *argv[];
{
  int32 hdf_fp, sd_id, an_id;	/* HDF file pointer & scientific data ID */
				/* and Anotation ID */

  struct TestSet testdata;   /* TestSet structure defined in structure.h file */

  int ii=0, kk, jj;
/*------------------------------------------------------------------*/
  if (argc!=2)		/* Must have:  executable + 1 argument */
    {
      printf("Usage: wr_test hdf_filename\n");
      exit(1);
    }
  /* **CREATE** hdf file using Hopen */
  if ((hdf_fp=Hopen(argv[1], DFACC_CREATE, 0))==FAIL)
    {
      fprintf(stderr, "Hopen: could not create hdf file\n");
      exit(-1);
    }
  /* allow writing of V data using Vstart */
  if (Vstart(hdf_fp)==FAIL) 
    {
      fprintf(stderr,"Vstart: Could not Vstart\n");
      exit(-1);
    }
  /* allow writing of SD data using SDstart */
  if ((sd_id=SDstart(argv[1], DFACC_RDWR))==FAIL)
    {
      fprintf(stderr, "SDstart: could not open hdf file\n");
      exit(-1);
    }
  /*-- Start up the HDF Annotation interface --*/
  if((an_id = ANstart(hdf_fp))==FAIL) 
    {
      fprintf(stderr,"Err#0085A.0: Could not ANstart\n");
      exit(-1);
    }

/* set all values in testdata to zero */
memset(&testdata, 0, sizeof(struct TestSet));

  /* create for write using perl generated code */
   init_cr_test_func(hdf_fp, sd_id, an_id, "ACE HDF test");

/* Put data into variables */
  for(ii=0; ii<5; ii++) {
      testdata.sctime_readout = 128*ii+3977070;
      testdata.QAC = 0;
      testdata.test1[ii] = 2*ii;
    for(jj=0; jj<NUM1; jj++) 
      for(kk=0; kk<NUM2; kk++) {
        testdata.test_array[jj][kk] = jj+kk+ii;
      }
   /* Write data out to HDF file using perl generated code */
    if(write_test_func(testdata, -1)==FAIL) {
      fprintf(stderr,"write error\n");
      /* Reports HDF errors, then clears buffer */
      HEprint(stderr,0); HEclear(); 
    }
  }
 /*--- all done, close HDF file ---*/
 /*--------------------------------*/
  /* Close access to Vdata and SDdata using perl generated code */
  close_wr_test_func();

  Vend(hdf_fp);			/* End Vdata attachment */

  if (SDend(sd_id)==FAIL)	/* End SDdata attachment */
    {
      fprintf(stderr, "SDend: could not close hdf file\n");
      exit(-1);
    }

  if (Hclose(hdf_fp)==FAIL)	/* Close HDF file */
    {
      fprintf(stderr, "Hclose: could not close hdf file\n");
      exit(-1);
    }
  /* exit program normally */
  exit(0);
}
    
