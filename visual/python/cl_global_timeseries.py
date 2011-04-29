import netCDF4
#import netcdftime
from pylab import *

if len(sys.argv)>1:
  ncfile=sys.argv[1]
else:
  ncfile='../../test.nc'

nc=netCDF4.Dataset(ncfile)
ncv=nc.variables

ntime=len(nc.dimensions['time'])
time=ncv['time'][:]

nreg=len(nc.dimensions['region']);
area=ncv['area'][:]
areaweight=area/sum(area)

nvar=len(ncv)
for varname in ncv:

  var=ncv[varname]
  try:
    tdim=var.dimensions.index('time')
  except ValueError:
    print 'Skipped ' + varname
    continue

  try:
    rdim=var.dimensions.index('region')
  except ValueError:
    print 'Skipped ' + varname
    continue

  print 'Plotting ' + varname

  if varname == 'population_size':
    yw=sum(var[:,:],rdim)
    yg=yw
  else: 
    yw=average(var[:,:],axis=rdim,weights=areaweight)
    yg=mean(var[:,:],rdim) 

  ymin=amin(var[:,:],rdim)
  ymax=amax(var[:,:],rdim)

  figure(figsize=(10,7))
  ax=axes([0.1,0.1,0.85,0.8])
  ax.set_title('Global ' + varname.replace('_',' '))
  ax.set_xlim(min(time),max(time))
  ax.set_xlabel('Time (year BC/AD)')
  ax.set_ylim(min(ymin),max(ymax))

  pg=ax.plot(time,yg,'b--',lw=3.0)
  pw=ax.plot(time,ymin,'r--',lw=2.0)
  pw=ax.plot(time,ymax,'r--',lw=2.0)
  pw=ax.plot(time,yw,'r-',lw=5.0)

  pfile='../plot/quicklook/' + ncfile.split('/')[-1].replace('.nc','') + '_' + varname + '.pdf'
  savefig(pfile,dp=150)

  close()

