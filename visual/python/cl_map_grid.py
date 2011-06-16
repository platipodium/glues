from pylab import *
import netCDF4
import os
from mpl_toolkits.basemap import Basemap
#from mpl_toolkits.basemap import interp as binterp
import numpy
import sys


timelim=(-8000,-1000)
timestep=1000

if len(sys.argv)>1:
  ncfile=sys.argv[len(sys.argv)-1]
else:
  ncfile='../../test_0.5x0.5.nc'

if len(sys.argv)>2:
  varnames=sys.argv[1]
else:
  varnames='population_density'

varlist = []
for v in varnames.split(","):
  varlist.append(v)

dpi=150

nc=netCDF4.Dataset(ncfile)
ncv=nc.variables

time=ncv['time'][:]
if size(time)>1:
  timeres=numpy.abs(time[2]-time[1])
else:
  timres=0  
 
it=where(time>=timelim[0])
if size(it)>0:
  itmin=numpy.min(it)
else:
  itmin=0
it=where(time<=timelim[1])
if size(it)>0:
  itmax=numpy.max(it)
else:
  itmax=0

itstep=numpy.int(numpy.round(timestep/timeres))
itrange=range(itmin,itmax,itstep)


lat=ncv['lat'][:]
lon=ncv['lon'][:]

glon,glat=meshgrid(lon,lat)

for varname in varlist:

  data=ncv[varname][:]
  mdata=numpy.ma.masked_array(data,numpy.isnan(data))
  mglat=numpy.ma.masked_array(glat,numpy.isnan(data[0,:,:]))

  latlim=(numpy.min(mglat),numpy.max(mglat))
  mindata=min(0,numpy.min(mdata))
  maxdata=numpy.max(mdata)

  ntime,nlat,nlon=data.shape

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

  for it in itrange:
  #for it in range(1):
  
    print(time[it])
    f=figure(num=it+1,figsize=(5,3),dpi=dpi,facecolor=None,edgecolor=None,frameon=True)

    hold(False)
    pc=proj.contourf(x,y,squeeze(mdata[it,:,:]),extend='max',levels=linspace(mindata,maxdata,10))
    hold(True)
    cb=colorbar(mappable=pc,cax=None, ax=None,orientation='vertical',format='%.2f');
    cb.set_label(ncv[varname].units);

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

    timestring += str(numpy.int(numpy.abs(time[it])))
 
    titletext=varname.replace('_',' ') + ' %d ' % numpy.abs(time[it]) + title 
  
    ax=gca()
  #ax.set_xlim(min(time),max(time))
    ax.set_xlabel('Longitude')
    ax.set_ylabel('Latitude')
  #ax.set_ylim(min(ymin),max(ymax))
    ax.set_title(titletext)

    extension='png'
    pfile=ncfile.split('/')[-1] + '_map_grid_' + varname + '_' + timestring + '.' + extension
  
    if os.access(pfile,os.F_OK):
      os.remove(pfile)
    
    savefig(pfile,dpi=dpi,facecolor='w', edgecolor='w',
        orientation='portrait', papertype=None, format=None,
        transparent=False, bbox_inches=None, pad_inches=0.)
    hold(False)
    close(f)

nc.close()