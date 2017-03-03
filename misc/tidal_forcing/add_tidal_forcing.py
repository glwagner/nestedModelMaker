# Computes surface pressure loading equivalent to tidal potential and adds it to
# the JRA-55 atmospheric surface pressure field. The code computes a
# superposition of harmonic coefficients to obtain the complete lunisolar tidal
# potential of second degree. See Wunsch, Modern Observational Physical
# Oceanography (2015), Chpt 6.1 for an introduction.
#    
# The function tidal_potential below is an adaption of code by Malte Mueller
# (maltem@met.no), with modifications by Victor Ocana (vocana@ices.utexas.edu).
#
# Required files:
#   LSpot1990-2020.new.mat - has time series of tidal coefficients
#   jra55_grid.npz         - JRA-55 grid information


import numpy as np
import scipy.io as sio
import datetime as dt
import calendar


# year for which tidal forcing is to be added
year = 2012

# path to JRA-55 files (also used as output folder!)
path = "/nobackup1/joernc/patches/jra55/"


def tidal_potential(lat, lon, t):

    # Computes surface pressure representing tidal potential at a given lat/lon
    # grid and at a given time (datetime object).
    # Input:
    #   lat   - latitude array
    #   lon   - longitude array
    #   t     - time at which tidal potential is computed
    # Output:
    #   lspot - map of surface pressure loading
    #              (potential converted to pressure???)
    
    # Account for solid earth tide: see Cartwright (1977), Sctn 6.1. This is
    # the combined effect of the solid earth deformation and the increase in
    # potential due to it. The result is a factor (1 + k2 - h2) = 0.69, where k2
    # and h2 are Love numbers.
    solid = 0.69
    
    # seawater density
    rho = 1029
    
    # Account for self-attraction and loading in the simple scalar
    # approximation (see, e.g. Ray, Ocean self‐attraction and loading in
    # numerical tidal models, Marine Geodesy 1998) ???
    # Not sure this is right, even if one were to accept the scalar
    # approximation, because the SAL term in the LTE depends on the ocean tide,
    # not the equilibrium tide!
    SAL = 0.121

    # locate prediction time (366 offset to match MATLAB convention)
    jd = t.toordinal() + t.hour/24. + 366
    if t.minute == 0: # full hour
        idx = np.argwhere(timepred == jd)[0]
        tr = np.reshape([idx], (1,1,1))
    elif t.minute == 30: # half hour (avg. over adjacent full hours)
        idx = np.argwhere(timepred == jd - .5)[0]
        tr = np.reshape([idx,idx+1], (2,1,1))

    # reshape to allow multiplication by time-dependent array
    lat = np.reshape(lat, (1,np.size(lat),1))
    lon = np.reshape(lon, (1,1,np.size(lon)))

    # Compute spatial dependence on specified lat/lon grid (see Wunsch, eqn 6.9)
    # for the semidiurnal, diurnal, and long-period components.
    spot = s1pot[tr]*np.cos(np.deg2rad(lat))**2*np.cos(np.deg2rad(-2*lon)) \
            + s2pot[tr]*np.cos(np.deg2rad(lat))**2*np.sin(np.deg2rad(-2*lon))   
    dpot = d1pot[tr]*np.sin(np.deg2rad(2*lat))*np.cos(np.deg2rad(-lon)) \
            + d2pot[tr]*np.sin(np.deg2rad(2*lat))*np.sin(np.deg2rad(-lon))
    lpot = l1pot[tr]*(3*np.sin(np.deg2rad(lat)**2-1))

    # Add up components (and avg. over adjacent hours if necessary).
    lspot = np.mean(spot + dpot + lpot, axis=0)

    # multiplication by density to convert to pressure ???
    # what are SAL, solid? is this converted to pressure?
    lspot = (1+SAL)*rho*solid*lspot

    return lspot


def get_pres(t):

    # This reads in the atmospheric surface pressure field from JRA-55 located
    # in the folder specified by the global variable "path" and interpolates to
    # the time t, which is assumed to be given at times 00:30:00, 01:30:00, etc.
    # The method depends on the JRA-55 pressure field being given at times
    # 01:30:00, 04:30:00, etc.

    # decide whether and how to interpolate
    if t.hour % 3 == 0: # one hour before JRA time step
        # times and weights of JRA to be interpolated between
        t0 = t - dt.timedelta(hours=2)
        t1 = t + dt.timedelta(hours=1)
        w0 = 1./3
        w1 = 2./3
    elif t.hour % 3 == 1: # matches JRA time stamp
        # times and weights of JRA (no interpolation needed here)
        t0 = t
        t1 = t
        w0 = 1
        w1 = 0
    elif t.hour % 3 == 2: # one hour after JRA time step
        # times and weights of JRA to be interpolated between
        t0 = t - dt.timedelta(hours=1)
        t1 = t + dt.timedelta(hours=2)
        w0 = 2./3
        w1 = 1./3

    # map to atmospheric surface pressure binary files
    days0 = 366 if calendar.isleap(t0.year) else 365
    days1 = 366 if calendar.isleap(t1.year) else 365
    pres0 = np.memmap("{:s}jra55_pres_{:4d}".format(path, t0.year),
            dtype=np.dtype(">f"), mode="r", shape=(days0*24/3,320,640))
    pres1 = np.memmap("{:s}jra55_pres_{:4d}".format(path, t1.year),
            dtype=np.dtype(">f"), mode="r", shape=(days1*24/3,320,640))

    # interpolate pressure field
    delt0 = t0 - dt.datetime(t0.year,1,1,0,30,0)
    delt1 = t1 - dt.datetime(t1.year,1,1,0,30,0)
    i0 = delt0.days*24 + delt0.seconds/3600
    i1 = delt1.days*24 + delt1.seconds/3600
    pres = w0*pres0[i0/3,:,:] + w1*pres1[i1/3,:,:]

    return pres


# Load tidal potential data. The coefficients represent the astronomical
# forcing, describing the locations of the sub-solar and sub-lunar points and
# folding in some additional factors.
# Where do these come from? What is the difference with LSpot1990-2020.mat?
# These are defined at full hours -- could we get these for half hours to match
# JRA? (interpolating in time for now)
f = sio.loadmat("LSpot1990-2020.new.mat")
timepred = f["timepred"][0,:]
s1pot = f["s1pot"][0,:]
s2pot = f["s2pot"][0,:]
d1pot = f["d1pot"][0,:]
d2pot = f["d2pot"][0,:]
l1pot = f["l1pot"][0,:]

# load JRA-55 grid
f = np.load("jra55_grid.npz")
lat = f["lat"]
lon = f["lon"]

# number of days in the year
days = 366 if calendar.isleap(year) else 365

# map to output file (overwrites existing file, must write entire year at once)
pres_tide = np.memmap("{:s}jra55_pres_tide_{:4d}".format(path, year),
        dtype=np.dtype(">f"), mode="w+", shape=(days*24,320,640))

# loop over hours and add tidal potential
for i in range(days*24):

    # time
    t = dt.datetime(year,1,1,0,30,0) + dt.timedelta(hours=i)
    print t

    # get pressure field
    pres = get_pres_field(t)

    # get tidal potential
    lspot = tidal_potential(lat, lon, t)

    # save to file (using memmap)
    pres_tide[i,:,:] = pres + lspot
