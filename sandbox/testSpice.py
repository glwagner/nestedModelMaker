import spiceypy as spice
import numpy as np
import scipy.special as scs
import datetime as dt
import matplotlib.pyplot as plt
from numpy import pi, sin, cos
from mpl_toolkits.mplot3d import Axes3D

# Print toolkit version numbers
print spice.tkvrsn('TOOLKIT')

# Load kernels. The kernel files listed in meta_kernel.txt were downloaded 
# from "https://naif.jpl.nasa.gov/pub/naif/generic_kernels/suffix", where
# the string "suffix" matches the directory structure inside the directory
# "spiceypy/kernels".
spice.furnsh("/data5/glwagner/Software/spiceypy/meta_kernel.txt")

def lon_lat_r(body, time):

    """
    Use SPICE software to get

      - longitude and latitude of <body>'s subsolar point, or the 
        coordinates at which <body> is in zenith (or point 'Q' in 
        Munk and Cartwright 1966's figure 13), and

      - the distance between the barycenters of Earth and <body>
        at a specified <time> (in UTC).

    The input <body> is a string like "SUN" or "MOON", and <time>
    is a datestring with format 'yyyy-mm-dd hh:mm:ss'
    """

    # The equivalent spherical radius of earth.
    earth_radius = 6371e3

    # Convert UTC time to ephemeris time in seconds past J2000 TDB.
    time = spice.str2et(str(time) + " UTC")

    # Get the position in km in a rectangular coordinate system whose
    # origin lies at the center of "EARTH", with no time-correction.
    pos_rec, _ = spice.spkpos(body, time, "ITRF93", "NONE", "EARTH")

    # Calculate the lat, lon position on an unflattened sphere with 
    # Earth's average radius on a line passing from pos_rec
    # to (0, 0, 0) (which is the Earth's center).
    flatten_coeff = 0
    pos_geo = spice.recgeo(pos_rec, earth_radius/1e3, flatten_coeff)

    # Transform pos_rec to range (in km), right ascension, declination.
    # The 'range' is the 'r' we seek: the distance between the center 
    # of the body and the center of the Earth.
    pos_rad = spice.recrad(pos_rec)

    # Isolate coordinates we'll need and convert range from km to m
    lon = pos_geo[0]
    lat = pos_geo[1]
    r = pos_rad[0]*1e3

    return lon, lat, r

def GM(body):
    """
    Use SPICE software to get the product of the gravitational constant and the
    mass of <body>.
    """
    _, GM = spice.bodvrd(body, "GM", 1)
    return GM[0]*1e9 # convert km**2 to m**2

def mu(lon1, lat1, lon2, lat2):
    """
    Use the spherical law of cosines to calculate mu = cos(alpha),
    where alpha is the angle between the zenith of the observer and 
    the geodetic point of the body. Reference:

    https://en.wikipedia.org/wiki/Spherical_law_of_cosines
    """
    return sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2)*cos(lon2-lon1)

# Earth's radius (pretending Earth is a perfect sphere here)
earth_radius = 6371e3

# Reference density for seawater for pressure conversion
rho = 1029.

# Love numbers for the 2nd Legendre mode of the solid Earth tide.
h2 = 0.61
k2 = 0.30

# Get GM=G*M, or the gravitational constant G multiplied by mass.
sun_GM  = GM("SUN")
moon_GM = GM("MOON")

# Earth coordinates at 1 deg resolution.
lon = np.reshape(np.arange(-pi,   pi,   pi/180), (1,360))
lat = np.reshape(np.arange(-pi/2, pi/2, pi/180), (180,1))

# Calculate one year of tidal potential values
for i in range(366*24):

    # Set time as i hours after Jan 1st, 2012 at 0:30
    time = dt.datetime(2012,1,1,0,30,0) + dt.timedelta(hours=i)
    print time

    # Get geodetic coordinates of the sun and moon
    sun_lon,  sun_lat,  sun_r  = lon_lat_r("SUN",  time)
    moon_lon, moon_lat, moon_r = lon_lat_r("MOON", time)

    # Cosine of zenith angle alpha
    sun_mu  = mu(lon, lat, sun_lon,  sun_lat)
    moon_mu = mu(lon, lat, moon_lon, moon_lat)

    # Parallaxes
    sun_xi  = earth_radius/sun_r
    moon_xi = earth_radius/moon_r

    # Calculate the 2nd Legendre mode of the potential. Ref: eq A1, 
    # Munk and Carwright, "Tidal spectrosopy and Prediction", 1966
    sun_V  = sun_GM  / sun_r  * sun_xi**2  * scs.legendre(2)(sun_mu)
    moon_V = moon_GM / moon_r * moon_xi**2 * scs.legendre(2)(moon_mu)

    # Convert to pressure units by multiplying by rho, including a 
    # correction for the 2nd Legendre mode of the solid Earth tide.
    sun_p  = (1+k2-h2)*rho*sun_V
    moon_p = (1+k2-h2)*rho*moon_V

    # save figure
    plt.imsave("fig/pot_{:05d}.png".format(i), sun_V+moon_V, vmin=-6, vmax=6,
            dpi=300)
