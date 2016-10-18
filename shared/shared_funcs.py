#!/usr/bin/env ipython
# -*- coding: utf-8 -*-
import h5py
from h5py import File as h5
from numpy import (
    mean, median, nanmean, nanmedian, std, nan, 
    isnan, min, max, zeros, ones, size, loadtxt
)
from os.path import isfile, isdir
import os, argparse
from scipy.io.netcdf import netcdf_file
import numpy as np
from datetime import datetime, time, timedelta
if 'DISPLAY' in os.environ:
    from pylab import find, pause, figure, savefig, close

class RichTable(object):
    def __init__(s, fname_rich):
        s.fname_rich = fname_rich
        s.tshck 	= []
        s.tini_icme, s.tend_icme	= [], []
        s.tini_mc,   s.tend_mc      = [], []
        s.Qicme		= []
        s.MCsig		= []
        s.Dst		= []

    def read(s):
        print " leyendo tabla Richardson: %s" % s.fname_rich
        frich = open(s.fname_rich, 'r')
        print " archivo leido."
        ll, n = [], 0
        for line in frich:
            ll 	+= [line.split(',')]
            n +=1
        print " lineas leidas: %d" % n
        for i in range(1,n):
            #------ fecha shock
            s.tshck += [datetime.strptime(ll[i][1][1:20],"%Y-%m-%d %H:%M:%S")]
            #------ fecha ini icme
            ss	= ll[i][2][1:11].split()  # string de la fecha ini-icme
            HH	= int(ss[1][0:2])
            MM	= int(ss[1][2:4])
            mm	= int(ss[0].split('/')[0])
            dd	= int(ss[0].split('/')[1])
            if mm==s.tshck[i-1].month:
                yyyy = s.tshck[i-1].year
            else:
                yyyy = s.tshck[i-1].year + 1
            s.tini_icme += [datetime(yyyy, mm, dd, HH, MM)]
            #------ fecha fin icme
            ss      = ll[i][3][1:11].split()
            HH      = int(ss[1][0:2])
            MM      = int(ss[1][2:4])
            mm      = int(ss[0].split('/')[0])
            dd      = int(ss[0].split('/')[1])
            if mm==s.tshck[i-1].month:
                yyyy = s.tshck[i-1].year
            elif s.tshck[i-1].month==12:
                yyyy = s.tshck[i-1].year + 1

            s.tend_icme += [datetime(yyyy, mm, dd, HH, MM)]
            #------ fechas MCs
            if ll[i][6]=='':
                s.tini_mc += [nan]
                s.tend_mc += [nan]
            else:
                hrs_ini	= int(ll[i][6])			# col6 es inicio del MC
                dummy = ll[i][7].split('(')		# col7 es fin del MC
                ndummy = len(dummy)
                if ndummy==1:
                    hrs_end = int(ll[i][7])
                else:
                    hrs_end	= int(ll[i][7].split('(')[0][1:])
                s.tini_mc += [ s.tini_icme[i-1] + timedelta(hours=hrs_ini) ]
                s.tend_mc += [ s.tend_icme[i-1] + timedelta(hours=hrs_end) ]
            # calidad de ICME boundaries
            s.Qicme 	+= [ ll[i][10] ]		# quality of ICME boundaries
            # flag de MC
            s.MCsig	+= [ ll[i][15] ]
            #if ll[i][15]=='2H':
            #	MCsig   += [ 2 ]
            #else:
            #	MCsig	+= [ int(ll[i][15]) ]	# MC flag
            #
            s.Dst	+= [ int(ll[i][16]) ]		# Dst

        #--------------------------------------
        s.MCsig   = np.array(s.MCsig)
        s.Dst	  = np.array(s.Dst)
        s.n_icmes = len(s.tshck)
        #
        """
        col0 : id
        col1 : disturbance time
        col2 : ICME start
        col3 : ICME end
        col4 : Composition start
        col5 : Composition end
        col6 : MC start
        col7 : MC end
        col8 : BDE
        col9 : BIF
        col10: Quality of ICME boundaries (1=best)
        col11: dV --> 'S' indica q incluye shock
        col12: V_ICME
        col13: V_max
        col14: B
        col15: MC flag --> '0', '1', '2', '2H': irregular, B-rotation, MC, or MC of "Huttunen etal05" respectively.
        col16: Dst
        col17: V_transit
        col18: LASCO_CME --> time of associated event, generally the CME observed by SOHO/LASCO.
               A veces tiene 'H' por Halo. 
        """

def Add2Date(date, days, hrs=0, BadFlag=np.nan):
    """
    Mapping to add `days` and `hrs` to a given
    `datetime` object.
    NOTE: `days` can be fractional.
    """
    if type(date) is not datetime:
        return BadFlag
    return date + timedelta(days=days, hours=hrs)

def utc2date(t):
    date_utc = datetime(1970, 1, 1, 0, 0, 0, 0)
    date = date_utc + timedelta(days=(t/86400.))
    return date


def date2utc(date):
    date_utc = datetime(1970, 1, 1, 0, 0, 0, 0)
    utcsec = (date - date_utc).total_seconds() # [utc sec]
    return utcsec

class arg_to_datetime(argparse.Action):
    """
    argparse-action to handle command-line arguments of 
    the form "dd/mm/yyyy" (string type), and converts
    it to datetime object.
    """
    def __init__(self, option_strings, dest, nargs=None, **kwargs):
        if nargs is not None:
            raise ValueError("nargs not allowed")
        super(arg_to_datetime, self).__init__(option_strings, dest, **kwargs)
    def __call__(self, parser, namespace, values, option_string=None):
        #print '%r %r %r' % (namespace, values, option_string)
        dd,mm,yyyy = map(int, values.split('/'))
        value = datetime(yyyy,mm,dd)
        setattr(namespace, self.dest, value)

class arg_to_utcsec(argparse.Action):
    """
    argparse-action to handle command-line arguments of 
    the form "dd/mm/yyyy" (string type), and converts
    it to UTC-seconds.
    """
    def __init__(self, option_strings, dest, nargs=None, **kwargs):
        if nargs is not None:
            raise ValueError("nargs not allowed")
        super(arg_to_utcsec, self).__init__(option_strings, dest, **kwargs)
    def __call__(self, parser, namespace, values, option_string=None):
        #print '%r %r %r' % (namespace, values, option_string)
        dd,mm,yyyy = map(int, values.split('/'))
        value = (datetime(yyyy,mm,dd)-datetime(1970,1,1)).total_seconds()
        setattr(namespace, self.dest, value)

class My2DArray(object):
    """
    wrapper around numpy array with:
    - flexible number of rows
    - records the maximum nrow requested
    NOTE:
    This was test for 1D and 2D arrays.
    """
    def __init__(self, shape, dtype=np.float32):
        self.this = np.empty(shape, dtype=dtype)
        setattr(self, '__array__', self.this.__array__)

    def resize_rows(self, nx_new=None):
        """ Increment TWICE the size of axis=0, **without**
        losing data.
        """
        sh_new = np.copy(self.this.shape)
        nx     = self.this.shape[0]
        if nx_new is None:
            sh_new[0] = 2*sh_new[0]
        elif nx_new<=nx:
            return 0 # nothing to do
        else:
            sh_new[0] = nx_new

        tmp    = self.this.copy()
        #print "----> tmp: ", tmp.shape
        new    = np.zeros(sh_new)
        new[:nx] = tmp
        self.this = new
        """
        for some reason (probably due to numpy 
        implementation), if we don't do this, the:
        >>> print self.__array__()
        
        stucks truncated to the original size that was
        set in __init__() time.
        So we need to tell numpy our new resized shape!
        """
        setattr(self, '__array__', self.this.__array__)

    def __get__(self, instance, owner):
        return self.this

    def __getitem__(self, i):
        return self.this[i]

    def __setitem__(self, i, value):
        """ 
        We can safely use:
        >>> ma[n:n+m,:] = [...]

        assuming n+m is greater than our size in axis=0.
        """
        stop = i
        if type(i)==slice:
            stop = i.stop
        elif type(i)==tuple:
            if type(i[0])==slice:
                """
                in case:
                ma[n:n+m,:] = ...
                """
                stop = i[0].stop
            else:
                stop = i[0]

        #--- if requested row exceeds limits, duplicate
        #    our size in axis=0
        if stop>=self.this.shape[0]:
            nx_new = self.this.shape[0]
            while nx_new<=stop:
                nx_new *= 2
            self.resize_rows(nx_new)

        self.this[i] = value
        #--- register the maximum nrow requested.
        # NOTE here we are referring to size, and *not* row-index.
        self.max_nrow_used = stop+1 # (row-size, not row-index)

    def __getattr__(self, attnm):
        return getattr(self.this, attnm)

def ACEepoch2date(ace_epoch):
    """
    ace_epoch: seconds since 1/1/96
    """
    date = datetime(1996,1,1) + timedelta(seconds=ace_epoch)
    return date

def date2ACEepoch(date):
    ace_o = datetime(1996,1,1)
    return (date - ace_o).total_seconds()



#EOF
