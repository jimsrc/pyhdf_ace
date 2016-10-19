#include "structure.h"
#include "read_hdf.h"
#include "hdf.h"

void open_hdf(const char *fname, int32 *hdf_fp, int32 *sd_id){
    /* HDF file pointer & scientific data ID */

    struct MAG_data_1sec testdata;   /* TestSet/SIS_data_1hr structure defined in structure.h file */
    int retval;

    /* **READ** hdf file using Hopen */
    if ((*hdf_fp=Hopen(fname, DFACC_READ, 0))==FAIL)
    {
        fprintf(stderr, "Hopen: could not open hdf file\n");
        exit(-1);
    }

    /* allow reading of V data using Vstart */
    Vstart(*hdf_fp);

    /* allow reading of SD data using SDstart */
    if ((*sd_id=SDstart(fname, DFACC_RDONLY))==FAIL)
    {
        fprintf(stderr, "SDstart: could not open hdf file\n");
        exit(-1);
    }

    /* initialize for read "r" using perl generated code */
    init_acc_test_func(*hdf_fp, *sd_id, "r");
}


void close_hdf(int32 hdf_fp, int32 sd_id){
    /* Close access to Vdata and SDdata using perl generated code */
    close_rd_test_func();

    Vend(hdf_fp);			/* End Vdata attachment */
    //fprintf(stdout,"Vdata connection ended \n");

    if (SDend(sd_id)==FAIL)	{
        /* End SDdata attachment */
        fprintf(stderr, "SDend: could not close hdf file\n");
        exit(-1);
    }
    //fprintf(stdout,"SD connection ended\n");

    if (Hclose(hdf_fp)==FAIL){
        fprintf(stderr, "Hclose: could not close hdf file\n");
        exit(-1);
    }
    //fprintf(stderr,"file closed \n");
}
//EOF
