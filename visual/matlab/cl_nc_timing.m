function data=cl_nc_timing(varargin)
% CL_NC_TIMING adds the timing of threshold exceedance to 
% a netcdf file

% Carsten Lemmen <carsten.lemmen@hzg.de>
% License: GNU Public License v3

arguments = {...
%  {'latlim',[-inf inf]},...
%  {'lonlim',[-inf inf]},...
  {'timelim',[-inf,inf]},...
  {'variable','farming'},...
  {'threshold',0.5},...
  {'file','../../euroclim_0.4.nc'},...%  {'retdata',NaN},...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end

if ~exist(file,'file')
    error('File does not exist');
end
ncid=netcdf.open(file,'NC_WRITE');

[ndim nvar natt udimid] = netcdf.inq(ncid); 
for varid=0:nvar-1
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
  if strcmp(varname,'time') 
      timeunit=netcdf.getAtt(ncid,varid,'units');
      time=netcdf.getVar(ncid,varid);
      time=cl_time2yearAD(time,timeunit);
      timeid=varid;
      if sum(round(time)-time)>0 error('Something wrong with day/year conversion'); end
  end
  if strcmp(varname,'lat') lat=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'lon') lon=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'latitude') latit=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'longitude') lonit=netcdf.getVar(ncid,varid); end
end

if exist('lat','var') 
  if length(lat)~=length(region)
    if exist('latit','var') lat=latit; end
  end
else
  if exist('latit','var') lat=latit; end
end

if exist('lon','var') 
  if length(lon)~=length(region)
    if exist('lonit','var') lon=lonit; end
  end
else
  if exist('lonit','var') lon=lonit; end
end


varname=variable; varid=netcdf.inqVarID(ncid,varname);
try
    description=netcdf.getAtt(ncid,varid,'description');
catch
    description=varname;
end

data=double(netcdf.getVar(ncid,varid));
[varname,xtype,dimids,natt] = netcdf.inqVar(ncid,varid);
ntime=length(time);

timing=(data>=threshold)*1.0;
izero=find(timing==0);
timing(izero)=NaN;

if size(timing==2)
  % This is the case for (nreg,ntime) dimension
  timing=timing.*repmat(time',size(data,1),1);
  timing(isnan(timing))=inf;
  timing=min(timing,[],2);
else
  error('Not yet implemented');
end

data=timing;
data(isinf(data))=NaN;
timingname=[varname '_timing'];
thresh=threshold;
timingid=0;

for varid=0:nvar-1
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
  if strcmp(varname,timingname) 
    timingid=varid;
    thresh=netcdf.getAtt(ncid,varid,'threshold');
    break;
  end
end

if timingid==0 | thresh~=threshold 
  regid=netcdf.inqDimID(ncid,'region');
  netcdf.reDef(ncid); 
  if timingid==0
    varid=netcdf.defVar(ncid,timingname,'NC_DOUBLE',regid);
    netcdf.putAtt(ncid,varid,'long_name',['timing_of_' varname]);
    netcdf.putAtt(ncid,varid,'description',['Timing of ' description]);
    netcdf.putAtt(ncid,varid,'units',netcdf.getAtt(ncid,timeid,'units'));
    netcdf.putAtt(ncid,varid,'calendar',netcdf.getAtt(ncid,timeid,'calendar'));
    netcdf.putAtt(ncid,varid,'comment',netcdf.getAtt(ncid,timeid,'comment'));
    netcdf.putAtt(ncid,varid,'date_of_creation',datestr(now));
    
  end
  netcdf.putAtt(ncid,varid,'threshold',threshold);
  netcdf.putAtt(ncid,varid,'date_of_modification',datestr(now));
  netcdf.endDef(ncid);
end    

netcdf.putVar(ncid,varid,(data-2000)*360);
netcdf.close(ncid);

end















