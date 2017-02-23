# requires file:
#   jra55_example.grb      - grib file of example JRA-55 output for grid info

import numpy as np
import matplotlib.pyplot as plt
import pygrib

# load JRA-55 example file and grab lat/lon information
grbs = pygrib.open("jra55_example.grb")
lat = grbs[1].latitudes.reshape((320,640))[::-1,:]
lon = grbs[1].longitudes.reshape((320,640))[::-1,:]
lat = np.reshape(lat[:,1], (320,1))
lon = np.reshape(lon[1,:], (1,640))
np.savez("jra55_grid.npz", lat=lat, lon=lon)

print lat
