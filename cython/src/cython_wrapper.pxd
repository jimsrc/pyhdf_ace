#--- librerias de c
#from libc.math cimport sqrt, sin, cos
from libc.math cimport sqrt, pow

#--- HDF4
#from "hdfi" cimport int32
#import numpy as np
#cimport numpy as np
#ctypedef np.int32_t int32
#--- defs according to "hdfi.h" (for 64bit arch)
ctypedef int            int32
ctypedef unsigned int   uint32
ctypedef float          float32
ctypedef double         float64
cdef extern from "structure.h":
    cdef struct MAG_data_1sec:
        int32   year;   
        int32   day;        
        int32   hr;     
        int32   min;        
        float32 sec;        
        float64 fp_year;
        float64 fp_doy; 

        float32 Bmag;
        float32 Delta;
        float32 Lambda;

        float32 Bgse_x;
        float32 Bgse_y;
        float32 Bgse_z;

cdef extern from "hdf_test.h":
    int32 read_test_func(MAG_data_1sec *MAG_data_1sec_struc, int32 recnum_rd);
    #int32 init_acc_test_func(int32 hdf_fp, int32 sd_id, char *access_mode);
    #void close_rd_test_func();

cdef extern from "read_hdf.h":
    void open_hdf(const char *fname, int32 *hdf_fp, int32 *sd_id)
    void close_hdf(int32 hdf_fp, int32 sd_id)


#--- para q compile templates especificos
ctypedef double Doub
ctypedef int Int



cdef double AU_in_cm #= 1.5e13
#AU_in_cm = 1.5e13 # corre ok, pero no funciona

#EOF
