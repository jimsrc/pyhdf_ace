# distutils: language = c
# Author: Jimmy J.
#from libcpp.string cimport string

# Declare the prototype of the C function we are interested in calling

from libc.stdlib cimport free, malloc, calloc
from cpython cimport PyObject, Py_INCREF#, PyMem_Malloc, PyMem_Free
from cpython.mem cimport PyMem_Malloc, PyMem_Free
#from cython.Utility.MemoryView import PyMem_New, PyMeM_Del # why doesn't work??
from cython.operator cimport dereference as deref
from libc.math cimport sqrt, sin, cos
#from libc cimport printf

# agregamos la clase wrapper
include "array_wrapper.pyx"


""" why this doesn't work??
cdef init_out(Output[StepperBS[rhs]] *op):
    o = out()
    o._thisp = op
    return o
"""


cdef class mag_l2:
    cdef int32          hdf_fp
    cdef int32          sd_id
    #cdef int            retval = 1
    #cdef int            off    = 1
    cdef MAG_data_1sec  data
    pdict = {}

    def __cinit__(self, fname_inp):
        open_hdf(fname_inp, &self.hdf_fp, &self.sd_id)

    def indexes_for_period(self, ini, end):
        """
        Returns indexes (file offsets) that englobe the 
        data corresponding to the time period `ìni`-`end`.
        NOTE:
        `ini` and `end` must be in `ACEepoch` units
        """
        assert end>ini, " Not consistent!, (ini,end)=(%f, %f)"%(ini,end)
        cdef int retval = 1
        cdef int off    = 0 # start at first record
        # search flags
        cdef bint NotFound_Ini=1
        cdef bint NotFound_End=1

        # read data
        while(retval!=-1):
            retval = read_test_func(&self.data, off)
            if (self.data.ACEepoch>=ini) & NotFound_Ini:
                index_ini = off
                NotFound_Ini = 0 # say i found it!

            if (self.data.ACEepoch>=end) & NotFound_End:
                index_end = off
                NotFound_End = 0 # say i found it!

            off += 1

        # found nothing in this file
        if NotFound_Ini & NotFound_End:
            return -1, -1
    
        # check that we found both borders && that the index
        # values are consistent!
        assert (~NotFound_Ini & ~NotFound_End) & (index_end>index_ini), \
            " Not consistent indexes!: %f, %f\n"%(index_ini,index_end)

        return index_ini, index_end



cpdef int test_myhdf(const char *fname):
    cdef:
        int32 hdf_fp
        int32 sd_id
        int retval=1
        int off=0       # initial offset
        MAG_data_1sec data # C-struct of data

    # point to file on disk
    open_hdf(fname, &hdf_fp, &sd_id)

    # read data
    while(retval!=-1):
        retval = read_test_func(&data,off)
        print "%d %d %d %f\n" %(data.year, data.fp_doy, data.hr, data.sec)
        #printf("%d %d %d %f\n", data.year, data.hr, data.min, data.sec);
        off += 1

    print " ---> finished reading data!\n"
    # close file
    close_hdf(hdf_fp, sd_id)
    return 0


#cdef void calc_Rlarmor(Doub Ek, Doub Bo, Doub *Rl):
#cpdef double calc_Rlarmor(Doub Ek, Doub Bo):
cpdef double calc_Rlarmor(Doub rigidity, Doub Bo):
    """
    input:
    Ek      : [eV] kinetic energy
    rigi..  : [V] rigidity
    Bo      : [G] magnetic field in Gauss
    output:
    Rl  : [cm] larmor radii
    """
    cdef:
        double q = (4.8032*1e-10) # [statC] carga PROTON
        double mo = 1.6726e-24 # [gr] masa PROTON
        double c = 3e10            # [cm/s] light speed
        double AU_in_cm = 1.5e13     # [cm]
        double E_reposo=938272013.0  # [eV] PROTON
        double beta, gamma, omg, v

    #rigidity = sqrt(Ek*Ek + 2.*Ek*E_reposo);
    #------------------------CALCULO DE GAMMA Y BETA
    gamma = pow(pow(rigidity/E_reposo,2) + 1. , 0.5)
    beta = pow(1. - 1/(gamma*gamma) , 0.5)
    #------------------------------CALCULO CICLOTRON
    omg = q * Bo / (gamma * mo * c)     # [s^-1]
    #---------------------------CALCULO RADIO LARMOR
    v   = beta * c              # [cm/s]
    #Rl[0]  = (v / omg) /AU_in_cm  # [AU]
    return (v / omg) # [cm]


#EOF
