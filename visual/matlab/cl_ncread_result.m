function res=cl_ncread_result(varargin)

cl_register_function();

%% Open files
infile='../../src/test/results.nc';
outfile='results.mat';

ncid=netcdf.open(infile,'NC_NOWRITE');
[ndim nvar natt udimid] = netcdf.inq(ncid);

% Copy global attributes
globalatts={};
for iatt=0:natt-1
  attname = netcdf.inqattname(ncid,netcdf.getConstant('NC_GLOBAL'),iatt);
end

%% Read variables
r.numvars=nvar;
for varid=0:nvar-1
  [varname,xtype,dimids,natt] = netcdf.inqVar(ncid,varid);
  r.variables{varid+1}=varname;
  val=netcdf.getVar(ncid,varid);
  switch (varname)
      case 'time', r.tend=max(val); r.tstart=min(val); 
        r.nstep=length(val); r.tstep=ceil((r.tend-r.tstart)/r.nstep);
      case 'region', r.nreg=length(val);
  end
  eval(['r.' varname '= val;']); 
end
netcdf.close(ncid);

if (str2num(version('-release'))<14) 
  save(outfile,'r');
else
  save('-v6',outfile,'r');
end
if (nargout>0)
  res=r;
end

return
end
