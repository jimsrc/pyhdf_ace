#!/usr/bin/env ipython
# -*- coding: utf-8 -*- 
import src.cython_wrapper as cw
import os


fnm = '{HOME}/data_ace/1sec_mag-swepam/mag_data_1sec_2494.hdf'.format(**os.environ)
ok = cw.test_myhdf(fnm)


#EOF
