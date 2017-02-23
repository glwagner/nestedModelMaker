import numpy as np
import matplotlib.pyplot as plt
import datetime as dt
import calendar

# year for which tidal forcing is to be added
year = 2012

# path to JRA-55 files (also used as output folder!)
path = "/nobackup1/joernc/patches/jra55/"

# number of days in the year
days = 366 if calendar.isleap(year) else 365

# map to file
pres_tide = np.memmap("{:s}jra55_pres_tide_{:4d}".format(path, year),
        dtype=np.dtype(">f"), mode="r", shape=(days*24,320,640))

# loop over hours and plot surface pressure plus tidal loading
for i in range(days*24):

    # time
    t = dt.datetime(year,1,1,0,30,0) + dt.timedelta(hours=i)
    print t

    # plot
    plt.figure()
    plt.imshow(pres_tide[i,:,:]/100, extent=[0,360,-90,90], origin="lower")
    plt.title(t)
    plt.xticks(np.linspace(0,360,5))
    plt.yticks(np.linspace(-90,90,3))
    plt.clim(900,1060)
    plt.colorbar(orientation="horizontal", fraction=.05)
    plt.tight_layout()
    plt.savefig("fig/pres_tide_{:4d}_{:05d}.png".format(year,i), dpi=300)
    plt.close()
    plt.show()
