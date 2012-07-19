function [time,lon,lat,temp,prec,npp]=cl_nc_read_plasim(varargin)

%% Standard arguments block
cl_register_function;

arguments = {...
  {'file','../../data/plasim_LSG_6999_6000_mean.nc'},...
  {'timelim',[-inf inf]}
};

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end


ncid=netcdf.open(file,'NC_NOWRITE');
[ndim nvar natt udimid] = netcdf.inq(ncid);

%% find time, lat, lon coordinate variables

try
  varid=netcdf.inqVarID(ncid,'time');
  time=netcdf.getVar(ncid,varid);  
  [name,xtype,timedim,natts] = netcdf.inqVar(varid);
catch ('MATLAB:netcdf:inqVarID:variableNotFound');
end

try
  varid=netcdf.inqVarID(ncid,'lat');
  lat=netcdf.getVar(ncid,varid);  
  [name,xtype,latdim,natts] = netcdf.inqVar(varid);
catch ('MATLAB:netcdf:inqVarID:variableNotFound');
  try
    varid=netcdf.inqVarID(ncid,'latitude');
    lat=netcdf.getVar(ncid,varid);  
    [name,xtype,latdim,natts] = netcdf.inqVar(varid);
  catch ('MATLAB:netcdf:inqVarID:variableNotFound');
    try
      varid=netcdf.inqVarID(ncid,'y');
      lat=netcdf.getVar(ncid,varid);  
     [name,xtype,latdim,natts] = netcdf.inqVar(varid);
    catch ('MATLAB:netcdf:inqVarID:variableNotFound');
    end
  end
end

try
  varid=netcdf.inqVarID(ncid,'lon');
  lon=netcdf.getVar(ncid,varid);  
  [name,xtype,londim,natts] = netcdf.inqVar(varid);
catch ('MATLAB:netcdf:inqVarID:variableNotFound');
  try
    varid=netcdf.inqVarID(ncid,'longitude');
    lon=netcdf.getVar(ncid,varid);  
    [name,xtype,londim,natts] = netcdf.inqVar(varid);
  catch ('MATLAB:netcdf:inqVarID:variableNotFound');
    try
      varid=netcdf.inqVarID(ncid,'x');
      lon=netcdf.getVar(ncid,varid);  
      [name,xtype,londim,natts] = netcdf.inqVar(varid);
    catch ('MATLAB:netcdf:inqVarID:variableNotFound');
    end
  end
end

%% Now find information on precip, temperature, npp
for varid=0:nvar-1
  [varname,xtype,dimids,natt] = netcdf.inqVar(ncid,varid);
  switch(varname)
    case {'lon','lat','time','height','level'}, continue; 
    case {'var142','var143','prec','lsp'}, pvarid=varid; 
    case {'var167','temp','t2m','t2'}, tvarid=varid; 
    case {'var301','npp'}, nvarid=varid;
      otherwise warning('Variable with id %d and name %s not used.',varid,varname);
  end
end

vars_to_save={'time','lat','lon'};
if exist('pvarid','var') prec=netcdf.getVar(ncid,pvarid); vars_to_save{end+1}='prec'; 
else prec=NaN;
end
if exist('tvarid','var') temp=netcdf.getVar(ncid,pvarid); vars_to_save{end+1}='temp';
else temp=NaN;
end
if exist('nvarid','var') npp=netcdf.getVar(ncid,pvarid); vars_to_save{end+1}='npp';
else npp=NaN;
end
netcdf.close(ncid);

matfile=strrep(file,'.nc','.mat');
save(matfile,vars_to_save{:});

return
end
