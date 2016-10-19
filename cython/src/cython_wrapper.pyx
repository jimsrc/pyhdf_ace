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
#include "array_wrapper.pyx"


""" why this doesn't work??
cdef init_out(Output[StepperBS[rhs]] *op):
    o = out()
    o._thisp = op
    return o
"""


cdef class mag_l2(object):
    cdef int32          hdf_fp
    cdef int32          sd_id
    cdef MAG_data_1sec  data        # read buffer
    #--- available in Python space
    cdef public int32   nf # number of input filenames
    cdef public int32   tsize # size of selected time domain
    findx = {} # fname list && associations

    def __cinit__(self, fname_inps):
        """
        fname_inps: list of input filenames
        NOTE:
        * we assume `fnames_inps` is listed in chronological way.
        """
        cdef int32 i
        cdef char *fname_inp
        self.nf = len(fname_inps)
        # initialize pointers to all files
        for i in range(self.nf): 
            fname_inp  = fname_inps[i]
            #open_hdf(fname_inp, &self.hdf_fp[i], &self.sd_id[i])
            self.findx[i] = {'fname_inp':fname_inp, 'ind':[None,None], 'size':None}

    def indexes_for_period(self, ini, end):
        """
        Returns indexes (file offsets) that englobe the 
        data corresponding to the time period `ìni`-`end`.
        NOTE:
        * `ini` and `end` must be in `ACEepoch` units
        * we assume `fnames_inps` is listed in chronological way.
        """
        assert end>ini, " Not consistent!, (ini,end)=(%f, %f)"%(ini,end)
        # search flags (indexes "not found" by default)
        cdef bint NotFound_Ini=1
        cdef bint NotFound_End=1
        cdef int i, retval, off, off_size

        # check
        # TODO: test if ignoring this block, we gain performance? (the
        #       executable size IS different!)
        open_hdf(self.findx[0]['fname_inp'], &self.hdf_fp, &self.sd_id)
        if read_test_func(&self.data, 0)!=-1:
            assert self.data.ACEepoch<ini, " bad data selection!"
            close_hdf(self.hdf_fp, self.sd_id)
        else:
            close_hdf(self.hdf_fp, self.sd_id)
            raise SystemExit(' bad data!')
        off_ = 0 
        self.tsize = 0
        for i in range(self.nf):
            retval = 1 # read status flag
            off    = 0 # start at first record
            # open file
            open_hdf(self.findx[i]['fname_inp'], &self.hdf_fp, &self.sd_id)
            off_size = get_maxrec() # number of records for this file
            self.findx[i]['size'] = off_size
            # read file
            while (retval!=-1) & NotFound_End:
                retval = read_test_func(&self.data, off)
                if NotFound_Ini & (self.data.ACEepoch>=ini):
                    self.findx[i]['ind'][0] = off
                    NotFound_Ini = 0 # say i found it!

                #TODO: shouldn't need the `NotFound_End` because 
                #      it's already en the while statement! It gives
                #      self.tsize!=len(var) if I remove it! WIERD.
                if (~NotFound_Ini) & NotFound_End: 
                    self.tsize += 1

                if NotFound_End & (self.data.ACEepoch>=end):
                    self.findx[i]['ind'][1] = off
                    NotFound_End = 0 # say i found it!
                    break # we finished!

                off += 1

            # close file
            close_hdf(self.hdf_fp, self.sd_id)
            

        # found nothing in these files
        if NotFound_Ini | NotFound_End:
            """
            Fail! But well keep the 'ind' members for
            further analyze, and return 0
            """
            print " ---> Didn't match both borders!\n"
            return 0
        else:
            return 1    # all ok.
   
    def return_var(self, vname):
        cdef int off, off_ini, off_end, off_size
        cdef int retval, i
        cdef float32 *_ptr
        #_ptr = &self.data.Bmag
        if   vname=='Bmag'     : _ptr = &self.data.Bmag
        elif vname=='Bgse_x'   : _ptr = &self.data.Bgse_x
        elif vname=='Bgse_y'   : _ptr = &self.data.Bgse_y
        elif vname=='Bgse_z'   : _ptr = &self.data.Bgse_z
        #elif vname=='ACEepoch' : _ptr = &self.data.ACEepoch
        else: raise SystemExit(' Not implemented for: %s'%vname)
        var = []
        #--- iterate over files
        for i in range(self.nf):
            if self.findx[i]['ind'][0] is None and self.findx[i]['ind'][1] is None:
                continue # next file
            retval = 1 # read status flag
            # open file
            open_hdf(self.findx[i]['fname_inp'], &self.hdf_fp, &self.sd_id)
            # get first offset
            off_ini  = self.findx[i]['ind'][0] if self.findx[i]['ind'][0] is not None else 0
            # get max offset
            off_size = get_maxrec() # number of records for this file
            off_end  = self.findx[i]['ind'][1] if self.findx[i]['ind'][1] is not None else (off_size-1)
            print " --> reading: %d,  %d/%d" % (off_ini, off_end, off_size-1)
            # read file
            for off in range(off_ini, off_end+1):
                retval = read_test_func(&self.data, off)
                var.append(deref(_ptr))

            # close file
            close_hdf(self.hdf_fp, self.sd_id)
        return var

    def return_ACEepoch(self):
        cdef int off, off_ini, off_end, off_size
        cdef int retval, i
        cdef float64 *_ptr
        _ptr = &self.data.ACEepoch
        var = []
        #--- iterate over files
        for i in range(self.nf):
            #--- is this file inside our period of interest?
            if self.findx[i]['ind'][0] is None and self.findx[i]['ind'][1] is None:
                continue # next file
            retval = 1 # read status flag
            # open file
            open_hdf(self.findx[i]['fname_inp'], &self.hdf_fp, &self.sd_id)
            # get first offset
            off_ini  = self.findx[i]['ind'][0] if self.findx[i]['ind'][0] is not None else 0
            # get max offset
            off_size = get_maxrec() # number of records for this file
            off_end  = self.findx[i]['ind'][1] if self.findx[i]['ind'][1] is not None else (off_size-1)
            print " --> reading: %d,  %d/%d" % (off_ini, off_end, off_size-1)
            # read file
            for off in range(off_ini, off_end+1):
                retval = read_test_func(&self.data, off)
                var.append(deref(_ptr))

        # close file
        close_hdf(self.hdf_fp, self.sd_id)
        return var

    """
    def __dealloc__(self):
        free(self.hdf_fp)
        free(self.sd_id)
    """



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
