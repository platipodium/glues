function [time,lon,lat,climate]=cl_nc_read_arve(varargin)

%% Standard arguments block
cl_register_function;

arguments = {...
  {'file','../../data/biome4out.nc'},...
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

%% Now read all other variables 
for varid=0:nvar-1
  [varname,xtype,dimids,natt] = netcdf.inqVar(ncid,varid);
  switch(varname)
    case {'lon','lat','time','height','level','layer'}, continue; 
    case {'var142','prec','lsp'}, varname='prec'; 
    case {'var167','temp','t2m','t2'}, varname='temp'; 
    case {'var301'}, varname='npp';
    case {'npp','gdd','gdd0','gdd5'}, ; 
    otherwise warning('Variable with id %d and name %s not used.',varid,varname);      
  end
  eval(['climate.' varname ' = netcdf.getVar(ncid,varid);']);
end

netcdf.close(ncid);

matfile=strrep(file,'.nc','.mat');
save(matfile,'lon','lat','time','climate');

return
end
