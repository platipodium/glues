from pylab import *
import netCDF4
import os
from mpl_toolkits.basemap import Basemap
#from mpl_toolkits.basemap import interp as binterp
import numpy
import sys


timelim=(-8000,-1000)
timestep=1000


# Get region id field from grid
ncfile='../../test_0.5x0.5.nc'
nc=netCDF4.Dataset(ncfile)
ncv=nc.variables

if ncv.has_key('lat'): lat=ncv['lat'][:]
else: lat=ncv['latitude'][:]

if ncv.has_key('lon'): 
  lon=ncv['lon'][:]
else: 
  lon=ncv['longitude'][:]

region=ncv['region'][:]
nc.close()

if len(sys.argv)>1:
  ncfile=sys.argv[len(sys.argv)-1]
else:
  ncfile='../../test.nc'

if len(sys.argv)>2:
  varnames=sys.argv[1]
else:
  varnames='farming,carbon_emission'

varlist = []
for v in varnames.split(","):
  varlist.append(v)

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
nlat,nlon=region.shape

if size(varlist)==1 and varlist[0]=='all':
  varlist=nc.variables.keys()
  varlist.remove('time')
  

for varname in varlist:

  data=ncv[varname][:]
  mdata=data#numpy.ma.masked_array(data,numpy.isnan(data))
  mglat=numpy.ma.masked_array(glat,region<0)

  latlim=(numpy.min(mglat),numpy.max(mglat))
  mindata=min(0,numpy.min(mdata))
  maxdata=numpy.max(mdata)

  ntime,nreg=data.shape

  proj = Basemap(projection='mill',
                       resolution='c',
                       llcrnrlon=-180.0,
                       llcrnrlat=latlim[0],
                       urcrnrlon=180.0,
                       urcrnrlat=latlim[1],
                       lat_0=0.0,
                       lon_0=10.0)

  x,y=proj(glon,glat)

  order=int(ceil(log10(ntime)))

  for it in itrange:
  
    print(time[it])
    f=figure(num=it+1,figsize=(10,7),dpi=dpi,facecolor=None,edgecolor=None,frameon=True)
    hold(False)

    gdata=numpy.zeros((nlat,nlon))+numpy.NaN
    for ir in range(nreg):
      ireg=where(region == ir) 
      gdata[ireg]=data[it,ir]

    mdata=numpy.ma.masked_array(gdata,numpy.isnan(gdata))

    pc=proj.contourf(x,y,squeeze(mdata[:,:]),extend='max',levels=linspace(mindata,maxdata,10))
    hold(True)
    cb=colorbar(mappable=pc,cax=None, ax=None,orientation='vertical',format='%.2f');
    
    # todo: check for existence of attribute
    if size(ncv[varname].ncattrs())>0:
      cb.set_label(ncv[varname].units)

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
    #ax.set_xlabel('Longitude')
    #ax.set_ylabel('Latitude')
    ax.set_title(titletext)

    extension='png'
    pfile=ncfile.split('/')[-1] + '_map_region_' + varname + '_' + timestring + '.' + extension
    if os.access(pfile,os.F_OK):
      os.remove(pfile)
    savefig(pfile,dpi=dpi)
    hold(False)

nc.close()