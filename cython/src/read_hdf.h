#ifdef READ_HDF_H
#define READ_HDF_H
/**************************************************************************
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


void open_hdf(const char*, int32 *hdf_fp, int32 *sd_id);
void close_hdf(int32 hdf_fp, int32 sd_id);

#endif //READ_HDF_H
