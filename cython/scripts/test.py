#!/usr/bin/env ipython
# -*- coding: utf-8 -*- 
import src.cython_wrapper as cw
import os, argparse
import numpy as np
from datetime import datetime, timedelta

#--- retrieve args
parser = argparse.ArgumentParser(
formatter_class=argparse.ArgumentDefaultsHelpFormatter
)
parser.add_argument(
'-dir', '--dir_inp',
type=str,
default='.',
help='inp dir',
)
pa = parser.parse_args()


def fnm_gen(i):
    return pa.dir_inp+'/mag_data_1sec_{i}.hdf'.format(i=i)

#ok = cw.test_myhdf(fnm)
fnm_ls = [fnm_gen(i) for i in range(2494,2497)]
#import pdb; pdb.set_trace()

m = cw.mag_l2(fnm_ls)
# seconds from 1/1/96 (ACE epoch)
ini = np.float64(643593600.00)
end = ini + 5.*86400. # ten more days

ace_o = datetime(1996,1,1)  # start of ACE epoch
# seconds in ACE epoch (secs since 1/1/96)
ini   = (datetime(2016,5,26)-ace_o).total_seconds()
end   = (datetime(2016,8,12)-ace_o).total_seconds()

ind = m.indexes_for_period(ini, end)

for i in range(m.nf):
    print m.findx[i]['ind']

Bmag = m.return_var('ACEepoch')
print " Bmag.size ", len(Bmag)
print " tsize ", m.tsize


#EOF
