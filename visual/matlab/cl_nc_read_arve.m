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
  [name,xtype,timedim,natts] = netcdf.inqVar(ncid,varid);
  attid=netcdf.inqAtt(ncid,varid,'unit');
  timeunit=netcdf.getAtt(ncid,varid,attid);
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
    case {'lon','lat','time','height','level','layer','biome'}, continue; 
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
    switch (idim)
      case 1, varval=varval(sortlon,:);
      case 2, varval=varval(:,sortlon);
      case 3, varval=varval(:,:,sortlon);
      case 4, varval=varval(:,:,:,sortlon);
    end
  end
  
  eval(['climate.' varname ' = varval;']);
  
end
netcdf.close(ncid);


matfile=strrep(file,'.nc','.mat');
save(matfile,'lon','lat','time','climate');

return
end
