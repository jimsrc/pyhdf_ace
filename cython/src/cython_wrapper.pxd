#--- librerias de c
#from libc.math cimport sqrt, sin, cos
from libc.math cimport sqrt, pow


#--- estructuras c++
cdef extern from "nr3.h":
    #cdef typename Doub # declarar lo q ya esta definido en general.h?
    #------ NRvector ------#
    cdef cppclass NRvector[T]:
        NRvector(int n) except +
        NRvector(int n, const T *array) except +
        NRvector(int n, const T &value) except +
        #NRvector & operator=(NRvector &rhs)
        T& operator[](int i)
        int size() const

    #------ NRmatrix ------#
    cdef cppclass NRmatrix[T]:
        NRmatrix()
        NRmatrix(int n, int m) except +
        NRmatrix(int n, int m, const T &a) #Initialize to constant
        NRmatrix(int n, int m, const T *a) #Initialize to array
        T* operator[](const int i) #subscripting: pointer to row i
        int nrows() 
        int ncols() const
        void resize(int newn, int newm)

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
    ctypedef struct MAG_data_1sec:
        int32   year;   
        int32   day;        
        int32   hr;     
        int32   min;        
        float32 sec;        
        float64 fp_year;
        float64 fp_doy; 

cdef extern from "hdf_test.h":
    int32 init_acc_test_func(int32 hdf_fp, int32 sd_id, char *access_mode);
    int32 read_test_func(MAG_data_1sec *MAG_data_1sec_struc, int32 recnum_rd);


#--- para q compile templates especificos
ctypedef double Doub
ctypedef int Int
ctypedef NRvector[Doub] VecDoub
ctypedef NRvector[Doub] VecDoub_IO
ctypedef NRvector[Doub] VecDoub_O
ctypedef const NRvector[Doub] VecDoub_I

ctypedef NRmatrix[Doub] MatDoub


#--- clases PARAMS_... y MODEL_TURB
cdef extern from "defs_turb.h":
    cpdef cppclass PARAMS_SEM:
        PARAMS_SEM()
        long slab[3]
        long two[2]
    
    cpdef cppclass PARAMS_TURB:
        PARAMS_TURB()
        void build_spectra()
        Int Nm_slab, Nm_2d
        Doub lmin_s, lmax_s
        Doub lmin_2d, lmax_2d
        #Int n_modos
        #Doub lambda_min
        #Doub lambda_max
        Doub Lc_slab, Lc_2d
        Doub sigma_Bo_ratio;
        Doub percent_slab, percent_2d;
        Doub gS, g2D # potencia espectral slab/2D
        Doub Bo    # campo uniforme
        Doub sigma_S    # intensidad slab
        Doub sigma_2D   # intensidad 2D
        PARAMS_SEM sem  # semillas

    cpdef cppclass MODEL_TURB:
        MODEL_TURB()
        double *B
        double *dB
        double *dB_2D
        double *dB_SLAB
        PARAMS_TURB p_turb
        void calc_B(const double *)



#--- Output, PARAMS y otros
cdef extern from "funcs.h":
    cpdef cppclass PARAMS:
        PARAMS()
        double *B
        double *dB
        double *dB_2D
        double *dB_SLAB
        PARAMS_TURB p_turb
        void calc_B(const double *)
        void fix_B_realization(const int nB) # fija la realizacion en funcion del argumento

    cdef cppclass GuidingCenter:
        GuidingCenter(Int len);
        void calc_gc(Doub* dydx, Doub* y, Doub x);
        MatDoub r_gc
        Doub* t
        Int n

    cdef cppclass Output[T]:
        Output()
        void build(
            char* str_tscalee, 
            Int nsave, Doub tmaxHistTau, 
            Int nHist, Int nThColl_,
            int i, int j, 
            char *dir_out)
        void set_Bmodel(PARAMS *par)
        void save2file()
        int nvar
        char fname_out[200];
        char fname_trj[200];
        char fname_misc[200];
        char fname_owned[200];
        Doub trun # tiempo de simulacion de c/pla
        Int nsteps # nro total de pasos de c/pla 
        Int count
        void tic(), toc() #cronometro para c/pla
        int nreb # nro de rebotes/scatterings en pitch
        MatDoub Tau # tiempo de camino libre medio paralelo, y su posic x
        #MatDoub r_gc
        GuidingCenter *gc
        VecDoub mu
        VecDoub xsave # time
        MatDoub ysave # posic && veloc
        #--- MONIT_STEP
        #MatDoub HistStep
        #MatDoub HistSeq
        #Int NStep
        #void build_HistSeq(const T s);
        MatDoub step_save

    cdef cppclass rhs: # (*1)
        void operator() (PARAMS par, const Doub x, VecDoub_I &y, VecDoub_O &dydx);
    # (*1): si quiero otro sistema de ecuaciones,
    #       debo modificar 'rhs' mismo.


#--- el esquema numerico "Stepper"
cdef extern from "stepperbs.h":
    cdef cppclass StepperBS[D]:
        StepperBS(VecDoub_IO &yy, VecDoub_IO &dydxx, 
            Doub &xx, const Doub atol, const Doub rtol, 
            bint dens, PARAMS parr)
        Doub atol, rtol

#--- odeint
cdef extern from "odeintt.h":
    cdef cppclass Odeint[Stepper]:
        #Odeint()
        Odeint(VecDoub_IO &ystartt, const Doub xx1, 
            const Doub xx2, const Doub atol, 
            const Doub rtol, const Doub h1, 
            const Doub hminn, Output[Stepper] &outt,
            rhs &derivss, # sistema de ecuaciones
            PARAMS par, int w_rank);
        void integrate()
        PARAMS par;
        #--- scattering stuff
        void save_history()
        void check_scattering()
        #--- others
        Doub x1, x2, hmin, h
        Stepper s
        Int nok
        Int nbad
        Int nstp
        Int MAXSTP #=(150*50000);

cdef double AU_in_cm #= 1.5e13
#AU_in_cm = 1.5e13 # corre ok, pero no funciona

#EOF
