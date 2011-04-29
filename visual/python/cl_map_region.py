from pylab import *
import netCDF4
from mpl_toolkits.basemap import Basemap
#from mpl_toolkits.basemap import interp as binterp
import numpy
import sys


timelim=(-8000,2000)
timestep=100

# Get region id field from grid
ncfile='../../test_0.5x0.5.nc'
nc=netCDF4.Dataset(ncfile)
ncv=nc.variables
lat=ncv['lat'][:]
lon=ncv['lon'][:]
region=ncv['region'][:]
nc.close()

if len(sys.argv)==2:
  ncfile=sys.argv[1]
else:
  ncfile='../../test.nc'

dpi=150

nc=netCDF4.Dataset(ncfile)
ncv=nc.variables

time=ncv['time'][:]
timeres=numpy.abs(time[2]-time[1])
itmin=numpy.min(where(time>=timelim[0]))
itmax=numpy.max(where(time<=timelim[1]))
itstep=numpy.int(numpy.round(timestep/timeres))
itrange=range(itmin,itmax,itstep)

glon,glat=meshgrid(lon,lat)
varname='population_density'
data=ncv[varname][:]
mdata=data#numpy.ma.masked_array(data,numpy.isnan(data))
mglat=numpy.ma.masked_array(glat,region<0)

latlim=(numpy.min(mglat),numpy.max(mglat))
mindata=min(0,numpy.min(mdata))
maxdata=numpy.max(mdata)

ntime,nreg=data.shape
nlat,nlon=region.shape

proj = Basemap(projection='mill',
                       resolution='c',
                       llcrnrlon=-180.0,
                       llcrnrlat=latlim[0],
                       urcrnrlon=180.0,
                       urcrnrlat=latlim[1],
                       lat_0=0.0,
                       lon_0=10.0)

x,y=proj(glon,glat)

#cmap=cm.gist_rainbow_r
order=int(ceil(log10(ntime)))

#for it in range(1):#itrange
for it in itrange:
#for it in range(itmin,itmax,itstep):
  
  print(time[it])
  f=figure(num=it+1,figsize=(10,7),dpi=dpi,facecolor=None,edgecolor=None,frameon=True)
  hold(True)

  gdata=numpy.zeros((nlat,nlon))+numpy.NaN
  for ir in range(nreg):
    ireg=where(region == ir) 
    gdata[ireg]=data[it,ir]

  mdata=numpy.ma.masked_array(gdata,numpy.isnan(gdata))

  pc=proj.contourf(x,y,squeeze(mdata[:,:]),extend='max',levels=linspace(mindata,maxdata,10))
  proj.drawcoastlines(linewidth=0.1)
  proj.drawmapboundary()

  timestring='%d' % it
  timestring.zfill(order)
  timestring += '_'

  if time[it]<0:
    timestring+='BC'
    title='BC'
  else:
    timestring+='AD'
    title='AD'

  timestring += str(numpy.int(numpy.abs(time[it]))).zfill(4)
 
  titletext=varname.replace('_',' ') + ' ' + str(numpy.int(numpy.abs(time[it]))) + ' ' + title
  
  ax=gca()
  #ax.set_xlim(min(time),max(time))
  ax.set_xlabel('Longitude')
  ax.set_ylabel('Latitude')
  #ax.set_ylim(min(ymin),max(ymax))
  ax.set_title(titletext)

  extension='png'
  pfile=ncfile.split('/')[-1] + '_map_region_' + varname + '_' + timestring + '.' + extension
  savefig(pfile,dpi=dpi)
  hold(False)

