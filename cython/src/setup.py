#!/usr/bin/env ipython
from distutils.core import setup, Extension
from Cython.Build import cythonize
import numpy, os

modname = 'cython_wrapper'

ext = Extension(
    name = modname,
    sources=[
        "%s.pyx" % modname, 
        "defs_turb.cc", 
        "funcs.cc",
        "general.cc", # declara a 'scl'
        "odeintt.cc", 
        "stepperbs.cc",
        'hdf_test.c',
    ],
    language="c++",
    include_dirs=[
    numpy.get_include(),
    '{HOME}/local/include'.format(**os.environ),
    ],
    #---
    runtime_library_dirs=[
    '{HOME}/local/lib'.format(**os.environ),
    ],
    library_dirs=[
    '{HOME}/local/lib'.format(**os.environ),
    ],
    #--- for debugging with 'gdb python'
    #extra_compile_args = ['-g'],
    #extra_link_args = ['-g'],
)

setup(
    name = modname,
    ext_modules = cythonize(ext)
)

#EOF
