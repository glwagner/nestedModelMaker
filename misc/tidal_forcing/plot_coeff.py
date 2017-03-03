import numpy as np
import matplotlib.pyplot as plt
import scipy.io as sio
import datetime as dt

f = sio.loadmat("LSpot1990-2020.new.mat")
timepred = f["timepred"][0,:]
s1pot = f["s1pot"][0,:]
s2pot = f["s2pot"][0,:]
d1pot = f["d1pot"][0,:]
d2pot = f["d2pot"][0,:]
l1pot = f["l1pot"][0,:]

t = dt.datetime(2012,1,1,0,00,0)
jd = t.toordinal() + t.hour/24. + 366

plt.figure()
plt.plot(timepred, l1pot)
plt.axvline(jd, color="black")
plt.show()
