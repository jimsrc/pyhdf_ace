/* filename:	rd_test

 * usage:	rd_test hdf_filename

 * purpose:	Reads data from an HDF file (hdf_filename).

 * perl generated code:	init_acc_test_func -  initialize for accessing
 * 			read_test_func -     read from hdf_filename
 * 			close_rd_test_func - Close access to Vdata and SDdata

 * HDF calls:		Hopen -    Opens the HDF file for reading
 * 			Vstart -   Allows reading of Vdata
 * 			SDstart -  Allows reading of SDdata
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
  int32 hdf_fp, sd_id;		/* HDF file pointer & scientific data ID */

  struct MAG_data_1sec testdata;   /* TestSet/SIS_data_1hr structure defined in structure.h file */

  int ii,jj,kk,cc=0,retval;
/*------------------------------------------------------------------*/
  if (argc!=2)		/* Must have:  executable + 1 argument */
    {
      printf("Usage: rd_test hdf_file\n");
      exit(1);
    }

  /* **READ** hdf file using Hopen */
  if ((hdf_fp=Hopen(argv[1], DFACC_READ, 0))==FAIL)
    {
      fprintf(stderr, "Hopen: could not open hdf file\n");
      exit(-1);
    }

  /* allow reading of V data using Vstart */
  Vstart(hdf_fp);

  /* allow reading of SD data using SDstart */
  if ((sd_id=SDstart(argv[1], DFACC_RDONLY))==FAIL)
    {
      fprintf(stderr, "SDstart: could not open hdf file\n");
      exit(-1);
    }

  /* initialize for read "r" using perl generated code */
  init_acc_test_func(hdf_fp, sd_id, "r");

  ii=0;	/* start at first record */

   /* Read data out of HDF file using perl generated code */
  while((retval= read_test_func(&testdata,ii))!=-1) {
	  printf("%d %d %d %f\n", testdata.year, testdata.hr, testdata.min, testdata.sec);
	  //printf("QAC = %d\n", testdata.QAC);
	  //printf("test1[%d] = %d\ntest_array:\n", cc, testdata.test1[cc++]);
      //for (jj=0; jj < NUM1; jj++){
      //  for (kk=0; kk < NUM2; kk++){
	  //printf("  %d ", testdata.test_array[jj][kk]);
      //  }
      //  printf("\n");
      //}
      //printf("\n");
      ii++;
  }
 /*--- all done, close HDF file ---*/
 /*--------------------------------*/
  /* Close access to Vdata and SDdata using perl generated code */
  close_rd_test_func();

  Vend(hdf_fp);			/* End Vdata attachment */
  fprintf(stdout,"Vdata connection ended \n");

  if (SDend(sd_id)==FAIL)	/* End SDdata attachment */
    {
      fprintf(stderr, "SDend: could not close hdf file\n");
      exit(-1);
    }
  fprintf(stdout,"SD connection ended\n");

  if (Hclose(hdf_fp)==FAIL)
    {
      fprintf(stderr, "Hclose: could not close hdf file\n");
      exit(-1);
    }
  fprintf(stderr,"file closed \n");
  /* exit program normally */
  exit(0);
}
    
