#!/usr/bin/env ipython
# -*- coding: utf-8 -*- 
import src.cython_wrapper as cw
import os
import numpy as np


fnm = '{HOME}/data_ace/1sec_mag-swepam/mag_data_1sec_2494.hdf'.format(**os.environ)
#ok = cw.test_myhdf(fnm)

m = cw.mag_l2(fnm)
# seconds from 1/1/96 (ACE epoch)
ini = np.float64(643593600.00)
end = ini + 5.*86400. # ten more days
ind = m.indexes_for_period(ini, end)


#EOF
