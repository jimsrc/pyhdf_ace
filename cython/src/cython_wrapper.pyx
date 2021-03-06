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


cdef class mag_l2(object):
    cdef int32          hdf_fp
    cdef int32          sd_id
    cdef MAG_data_1sec  data        # read buffer
    # we choose `float64` since it will cover the 
    # case fot ACEepoch; although we might be 
    # introducing garbage in the last digits of
    # the observables (which are float32 type).
    cdef float64        *buff # buffer for read
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
        self.buff = NULL
        # initialize pointers to all files
        for i in range(self.nf): 
            fname_inp  = fname_inps[i]
            self.findx[i] = {
                'fname_inp':fname_inp, 
                'ind':[None,None], 
                'size':None
            }

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

        #--- check
        # TODO: test if ignoring this block, we gain performance? (the
        #       executable size IS different!)
        open_hdf(self.findx[0]['fname_inp'], &self.hdf_fp, &self.sd_id)
        if read_test_func(&self.data, 0)!=-1:
            assert self.data.ACEepoch<ini, \
                " bad data selection!\n \
                  data_ini: %r\n \
                  ini     : %r" % (self.data.ACEepoch,ini)
            close_hdf(self.hdf_fp, self.sd_id)
        else:
            close_hdf(self.hdf_fp, self.sd_id)
            raise SystemExit(' bad data!')

        self.tsize = 0
        for i in range(self.nf):
            retval = 1 # read status flag
            off    = 0 # start at first record
            # open file
            open_hdf(self.findx[i]['fname_inp'], &self.hdf_fp, &self.sd_id)
            off_size = get_maxrec() # number of records for this file
            self.findx[i]['size'] = off_size
            # read file
            retval = read_test_func(&self.data, 0)
            while (retval!=-1) & NotFound_End:

                if NotFound_Ini & (self.data.ACEepoch>=ini):
                    self.findx[i]['ind'][0] = off
                    NotFound_Ini = 0 # say i found it!

                #TODO: shouldn't need the `NotFound_End` because 
                #      it's already en the while statement! It gives
                #      self.tsize!=len(var) if I remove it! WIERD.
                if (~NotFound_Ini) & NotFound_End: 
                    self.tsize += 1

                if (NotFound_End & (self.data.ACEepoch>=end)) & (retval!=-1):
                    self.findx[i]['ind'][1] = off
                    NotFound_End = 0 # say i found it!
                    #break # we finished!

                off += 1
                retval = read_test_func(&self.data, off)

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
            if self.buff is not NULL: # if occupied, free first
                free(self.buff)
            self.buff = <float64*> calloc(self.tsize, sizeof(float64))
            return 1    # all ok.
   
    def return_var(self, vname):
        cdef int off, off_ini, off_end, off_size
        cdef int retval, i
        cdef float32 *_ptr
        #_ptr = &self.data.Bmag

        """
        select only the files that we need to read from.
        """
        cdef bint initialized, finalized
        cdef i_ini, i_end
        initialized, finalized = False, False
        for i in range(self.nf):
            if self.findx[i]['ind'][0] is not None and not(initialized):
                i_ini = i
                initialized = True

            if initialized and self.findx[i]['ind'][1] is not None:
                i_end = i
                finalized = True
                break

        cdef int nt = 0             # time index
        #--- iterate over files
        for i in range(i_ini, i_end+1):
            retval = 1 # read status flag
            # open file
            open_hdf(self.findx[i]['fname_inp'], &self.hdf_fp, &self.sd_id)
            # get first offset
            off_ini  = self.findx[i]['ind'][0] if self.findx[i]['ind'][0] is not None else 0
            # get max offset
            off_size = get_maxrec() # number of records for this file
            off_end  = self.findx[i]['ind'][1] if self.findx[i]['ind'][1] is not None else (off_size-1)
            # read file
            for off in range(off_ini, off_end+1):
                """
                Maybe not the most efficient way, but practical. This
                might be slow since for a given `vname` it has to go
                through all these conditionals at every time index!
                TODO: check C code generated by Cython, to know if
                it makes an optimized version of this block.
                """
                retval = read_test_func(&self.data, off)
                if   vname=='Bmag'     : self.buff[nt] = self.data.Bmag
                elif vname=='Bgse_x'   : self.buff[nt] = self.data.Bgse_x
                elif vname=='Bgse_y'   : self.buff[nt] = self.data.Bgse_y
                elif vname=='Bgse_z'   : self.buff[nt] = self.data.Bgse_z
                elif vname=='ACEepoch' : self.buff[nt] = self.data.ACEepoch
                else: return -1
                nt += 1

            # close file
            close_hdf(self.hdf_fp, self.sd_id)

        #--- build numpy-array wrapper
        cdef np.ndarray ndarray
        v_arr = ArrayWrapper()
        v_arr.set_data(self.tsize, <void*>&self.buff[0], survive=True)
        ndarray = np.array(v_arr, copy=False)
        ndarray.base = <PyObject*> v_arr
        Py_INCREF(v_arr)
        # return numpy-array wrapper of `self.buff`
        return ndarray


    def __dealloc__(self):
        if self.buff is not NULL:
            free(self.buff)



#cpdef np.ndarray test_myhdf(const char *fname):
cdef class simple(object):
    cdef float64    *buff
    
    def __cinit__(self,):
        self.buff = NULL

    def get_data(self, const char* fname, vname):
        cdef:
            int32 hdf_fp
            int32 sd_id
            int retval=1
            MAG_data_1sec data # C-struct of data
            int off_size, off
            
        # point to file on disk
        open_hdf(fname, &hdf_fp, &sd_id)
        off_size = get_maxrec() # number of records for this file

        #--- buffer to save data from disk
        if self.buff is not NULL:
            free(self.buff)
        self.buff = <float64*> calloc(off_size, sizeof(float64))

        # read data
        for off in range(off_size):
            retval = read_test_func(&data,off)
            #print "%d %d %d %f\n" %(data.year, data.fp_doy, data.hr, data.sec)
            if   vname=='Bmag'     : self.buff[off] = data.Bmag
            elif vname=='Bgse_x'   : self.buff[off] = data.Bgse_x
            elif vname=='Bgse_y'   : self.buff[off] = data.Bgse_y
            elif vname=='Bgse_z'   : self.buff[off] = data.Bgse_z
            elif vname=='ACEepoch' : self.buff[off] = data.ACEepoch
            else: return -1

        print " ---> finished reading data!\n"
        # close file
        close_hdf(hdf_fp, sd_id)

        #--- build numpy-array wrapper
        cdef np.ndarray ndarray
        v_arr = ArrayWrapper()
        v_arr.set_data(off_size, <void*>&self.buff[0], survive=True)
        ndarray = np.array(v_arr, copy=False)
        ndarray.base = <PyObject*> v_arr
        Py_INCREF(v_arr)

        # return numpy-array wrapper of `self.buff`
        return ndarray

    def __dealloc__(self):
        if self.buff is not NULL:
            free(self.buff)

#EOF
