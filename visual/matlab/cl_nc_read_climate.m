function [time,lon,lat,climate]=cl_nc_read_arve(varargin)

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
  [name,xtype,timedim,natts] = netcdf.inqVar(ncid,varid);
  timeunit=netcdf.getAtt(ncid,varid,'units');
catch ('MATLAB:netcdf:inqVarID:variableNotFound');
end

try
  varid=netcdf.inqVarID(ncid,'lat');
  lat=netcdf.getVar(ncid,varid);  
  [name,xtype,latdim,natts] = netcdf.inqVar(ncid,varid);
catch ('MATLAB:netcdf:inqVarID:variableNotFound');
  try
    varid=netcdf.inqVarID(ncid,'latitude');
    lat=netcdf.getVar(ncid,varid);  
    [name,xtype,latdim,natts] = netcdf.inqVar(ncid,varid);
  catch ('MATLAB:netcdf:inqVarID:variableNotFound');
    try
      varid=netcdf.inqVarID(ncid,'y');
      lat=netcdf.getVar(ncid,varid);  
     [name,xtype,latdim,natts] = netcdf.inqVar(ncid,varid);
    catch ('MATLAB:netcdf:inqVarID:variableNotFound');
    end
  end
end

try
  varid=netcdf.inqVarID(ncid,'lon');
  lon=netcdf.getVar(ncid,varid);  
  [name,xtype,londim,natts] = netcdf.inqVar(ncid,varid);
catch ('MATLAB:netcdf:inqVarID:variableNotFound');
  try
    varid=netcdf.inqVarID(ncid,'longitude');
    lon=netcdf.getVar(ncid,varid);  
    [name,xtype,londim,natts] = netcdf.inqVar(ncid,varid);
  catch ('MATLAB:netcdf:inqVarID:variableNotFound');
    try
      varid=netcdf.inqVarID(ncid,'x');
      lon=netcdf.getVar(ncid,varid);  
      [name,xtype,londim,natts] = netcdf.inqVar(ncid,varid);
    catch ('MATLAB:netcdf:inqVarID:variableNotFound');
    end
  end
end

%% Bring lat and lon in order
if lat(2)>lat(1) reverse_lats=0; else
  lat=flipud(lat);
  reverse_lats=1;
end

if any(lon>180) reorder_lons=1; 
  ilon1=find(lon<=180);
  ilon2=find(lon>180);
  lon(ilon2)=lon(ilon2)-360;
  [lon,sortlon]=sort(lon);
else
  reorder_lons=0;
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
  varval=netcdf.getVar(ncid,varid);

  % Rearrange if lat decreasing
  if (reverse_lats & any(latdim==dimids))
    idim=find(latdim==dimids);
    varval=flipdium(varval,idim);
  end
  
  % Rearrange if lon gt 180
  if (reorder_lons & any(londim==dimids))
    idim=find(londim==dimids);
    varval=cl_reorder(varval,sortlon,idim);
  end
  
  eval(['climate.' varname ' = varval;']);end

%% Correct specific data
% plasim data is mm/day in precip and temp in K
if strfind(file,'plasim')
  if isfield(climate,'temp') climate.temp=climate.temp-273.15; end
  if isfield(climate,'prec') climate.prec=climate.prec*365.25/12; end
end

%% Calculate npp if necessary
if ~isfield(climate,'npp') & isfield(climate,'temp') & isfield(climate,'prec')
  if numel(size(climate.temp))<3
    climate.npp=clc_npp(climate.temp,climate.prec);
  else
    % assume time is third dimension and is monthly
    climate.npp=clc_npp(mean(climate.temp,3),sum(climate.prec,3));
  end
end

%% Calculate gdd if necessary
if ~isfield(climate,'gdd0') & isfield(climate,'temp')
  climate.gdd0=sum(climate.temp.*(climate.temp>=0),3);
end

if ~isfield(climate,'gdd5') & isfield(climate,'temp')
  climate.gdd5=sum(climate.temp.*(climate.temp>=5),3);
end

if ~isfield(climate,'gdd') & isfield(climate,'temp')
  if numel(size(climate.temp))>2
    climate.gdd=sum(climate.temp>=0,3)*365./12;
  end
end


%% Finally reduce precip and temp to annual means
if isfield(climate,'temp')
  timedim=find(size(climate.temp)==12);
  if ~isempty(timedim)
    climate.temp=mean(climate.temp,timedim);
    climate.prec=sum(climate.prec,timedim);
  end
end
netcdf.close(ncid);

matfile=strrep(file,'.nc','.mat');
save(matfile,'lon','lat','time','climate');

return
end
