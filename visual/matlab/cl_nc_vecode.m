function [time,lon,lat,climate]=cl_nc_vecode(varargin)
% Computes from temperature and precipitation 
% npp, gdd, land cover fractions and carbon pools

% todo: add co2 information

cl_register_function;

arguments = {...
  {'file','../../data/plasim_11k.nc'},...
  {'timelim',[-inf inf]},...
  {'co2',280},...
  {'variables',{'npp','gdd','carbon_in_leaves','carbon_in_stems',...
    'carbon_in_litter','carbon_in_soil','gdd0','temperature','precipitation',...
    'desert_share','forest_share','grassland_share'}},...
};

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  lv=length(a.value{i});
  if (lv>1 & iscell(a.value{i}))
    for j=1:lv
      eval( [a.name{i} '{' num2str(j) '} = ''' char(clp_valuestring(a.value{i}(j))) ''';']);         
    end
  else
    eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
  end
end

if ~exist(file,'file') 
  warning('File %s does not exist. Skipped.',file);
  return;
end
ncid=netcdf.open(file,'NC_NOWRITE');
[ndim nvar natt udimid] = netcdf.inq(ncid);


%% find time, lat, lon coordinate variables

try
  varid=netcdf.inqVarID(ncid,'time');
  time=netcdf.getVar(ncid,varid);  
  [varname,xtype,timedim,natts] = netcdf.inqVar(ncid,varid);
  timeunit=netcdf.getAtt(ncid,varid,'units');
catch ('MATLAB:netcdf:inqVarID:variableNotFound');
  try
    varid=netcdf.inqVarID(ncid,'month');
    time=netcdf.getVar(ncid,varid);  
    [varname,xtype,timedim,natts] = netcdf.inqVar(ncid,varid);
    timeunit=netcdf.getAtt(ncid,varid,'units');
  catch ('MATLAB:netcdf:inqVarID:variableNotFound');
  end
end
timename=varname;

try
  varid=netcdf.inqVarID(ncid,'lat');
  lat=netcdf.getVar(ncid,varid);  
  [varname,xtype,latdim,natts] = netcdf.inqVar(ncid,varid);
catch ('MATLAB:netcdf:inqVarID:variableNotFound');
  try
    varid=netcdf.inqVarID(ncid,'latitude');
    lat=netcdf.getVar(ncid,varid);  
    [varname,xtype,latdim,natts] = netcdf.inqVar(ncid,varid);
  catch ('MATLAB:netcdf:inqVarID:variableNotFound');
    try
      varid=netcdf.inqVarID(ncid,'y');
      lat=netcdf.getVar(ncid,varid);  
     [varname,xtype,latdim,natts] = netcdf.inqVar(ncid,varid);
    catch ('MATLAB:netcdf:inqVarID:variableNotFound');
    end
  end
end
latname=varname;

try
  varid=netcdf.inqVarID(ncid,'lon');
  lon=netcdf.getVar(ncid,varid);  
  [varname,xtype,londim,natts] = netcdf.inqVar(ncid,varid);
catch ('MATLAB:netcdf:inqVarID:variableNotFound');
  try
    varid=netcdf.inqVarID(ncid,'longitude');
    lon=netcdf.getVar(ncid,varid);  
    [varname,xtype,londim,natts] = netcdf.inqVar(ncid,varid);
  catch ('MATLAB:netcdf:inqVarID:variableNotFound');
    try
      varid=netcdf.inqVarID(ncid,'x');
      lon=netcdf.getVar(ncid,varid);  
      [varname,xtype,londim,natts] = netcdf.inqVar(ncid,varid);
    catch ('MATLAB:netcdf:inqVarID:variableNotFound');
    end
  end
end
lonname=varname;

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
elseif  any(lon-180) reorder_lons=1; 
  ilon1=find(lon>=-180);
  ilon2=find(lon<-180);
  lon(ilon2)=lon(ilon2)+360;
  [lon,sortlon]=sort(lon);
else
  reorder_lons=0;
end



%% Now read all other variables 
for varid=0:nvar-1
  [varname,xtype,dimids,natt] = netcdf.inqVar(ncid,varid);
  switch(varname)
    case {'lon','lat','time','month','height','level','layer'}, continue; 
    case {'var142','prec','lsp'}, precname=varname; varname='prec'; 
    case {'var167','temp','t2m','t2','tmean'}, tempname=varname; varname='temp';
    case {'var301'}, varname='npp';
    case {'npp','gdd','gdd0','gdd5','natural_fertility','suitable_species'}, ; 
    otherwise warning('Variable with id %d and name %s not used.',varid,varname);      
  end
  varval=netcdf.getVar(ncid,varid);

  % Rearrange if lat decreasing
  if (reverse_lats & any(latdim==dimids))
    idim=find(latdim==dimids);
    varval=flipdim(varval,idim);
  end
  
  % Rearrange if lon gt 180
  if (reorder_lons & any(londim==dimids))
    idim=find(londim==dimids);
    varval=cl_reorder(varval,sortlon,idim);
  end
  
  eval(['climate.' varname ' = varval;']);
end
%netcdf.close(ncid);
ncin=ncid;

%% Correct specific data
% plasim data precip mm/month (not as given kg/m2/s and temp in K
if strfind(file,'plasim')
  if isfield(climate,'temp') climate.temp=climate.temp-273.15; end
  if isfield(climate,'prec') climate.prec=climate.prec; end 
end

%pcolor(lon,lat,double(squeeze(climate.prec(:,:,i)))'); shading interp; colorbar;    
%lonmean=squeeze(mean(climate.prec,1));

%timemean=squeeze(mean(mean(climate.temp,2),1));
%i=1;clf; hold on;
%for i=1:220 plot(lonmean(:,i),lat,'k-'); end

%% Convert monthly precip and temp to annual values
if findstr('plasim',file)
  % values are monthly in third dimension
  nlon=length(lon); % first dimension
  nlat=length(lat); % second dimension
  nmonth=12; 
  nyear=length(time)/nmonth; % third dimension
  %climate.mtemp=reshape(climate.temp,[nlon nlat nyear nmonth]);
  climate.mtemp=reshape(climate.temp,[nlon nlat nmonth nyear]);
  climate.mprec=reshape(climate.prec,[nlon nlat nmonth nyear]);
  climate.temp=squeeze(mean(climate.mtemp,3));
  climate.prec=squeeze(sum(climate.mprec,3));
  %time=1950+[1:nyear]*50-11000;
  time=([1:nyear]*50+1925-11000);
  ntime=length(time);
end

% timemean=squeeze(mean(mean(climate.temp,2),1));
% plot(time/360,timemean);
% xlabel('Time');
% ylabel('Temp deg C');
% title('Plasim 11k annual mean surface temp');

%% Bring co2 to time dimension
if length(co2)==1
  co2=repmat(co2,size(time));
elseif length(co2)==ntime
    % do nothing
else
  error('Todo: stretching of co2 to time scale not yet implemented');
end
    

%% Calculate npp if necessary
if ~isfield(climate,'npp') & isfield(climate,'temp') & isfield(climate,'prec')
  climate.npp=clc_npp(climate.temp,climate.prec);
end

%% Calculate gdd if necessary
if ~isfield(climate,'gdd0') & isfield(climate,'mtemp')
  climate.gdd0=squeeze(sum(climate.mtemp.*(climate.mtemp>0),3))*30;
end

if ~isfield(climate,'gdd5') & isfield(climate,'mtemp')
  climate.gdd5=squeeze(sum(climate.mtemp.*(climate.mtemp>5),3)*30);
end

if ~isfield(climate,'gdd') & isfield(climate,'mtemp')
  climate.gdd=squeeze(sum(climate.mtemp>0,3))*30;
end


%% Calculate forest share and carbon pools
co2matrix=reshape(co2,[1 1 ntime]);
co2matrix=repmat(co2matrix,[nlon nlat 1]);
[climate.production,climate.share,climate.carbon,climate.p]=clc_vecode(climate.temp,climate.prec,climate.gdd0,co2matrix);


%% Write new file
outfile=strrep(file,'.nc','_vecode.nc');
if exist(outfile,'file') delete(outfile); end
ncid=netcdf.create(outfile,'NOCLOBBER');

timedim=netcdf.defDim(ncid,'time',netcdf.getConstant('NC_UNLIMITED'));
latdim=netcdf.defDim(ncid,'lat',nlat);
londim=netcdf.defDim(ncid,'lon',nlon);

for iatt=0:natt-1
  attname = netcdf.inqattname(ncin,netcdf.getConstant('NC_GLOBAL'),iatt);
  netcdf.copyAtt(ncin,netcdf.getConstant('NC_GLOBAL'),attname,ncid,netcdf.getConstant('NC_GLOBAL'));
end

varname='time';
varid = netcdf.defVar(ncid,varname,'NC_DOUBLE',timedim);
ivarid = netcdf.inqVarID(ncin,varname);
[varname,xtype,dimids,natt] = netcdf.inqVar(ncin,ivarid);
for iatt=0:natt-1
  attname = netcdf.inqAttName(ncin,ivarid,iatt);
  netcdf.copyAtt(ncin,ivarid,attname,ncid,varid);
end
netcdf.putAtt(ncid,varid,'calendar','360 day');
netcdf.putAtt(ncid,varid,'scale_factor',1.0);
netcdf.putAtt(ncid,varid,'add_offset',0.0);
netcdf.putAtt(ncid,varid,'units','years since 0001-01-01');
netcdf.putAtt(ncid,varid,'average','central time in 50 a average');

varname='lat';
varid = netcdf.defVar(ncid,varname,'NC_DOUBLE',latdim);
ivarid = netcdf.inqVarID(ncin,latname);
[varname,xtype,dimids,natt] = netcdf.inqVar(ncin,ivarid);
for iatt=0:natt-1
  attname = netcdf.inqAttName(ncin,ivarid,iatt);
  netcdf.copyAtt(ncin,ivarid,attname,ncid,varid);
end
netcdf.putAtt(ncid,varid,'scale_factor',1.0);
netcdf.putAtt(ncid,varid,'add_offset',0.0);

varname='lon';
varid = netcdf.defVar(ncid,varname,'NC_DOUBLE',londim);
ivarid = netcdf.inqVarID(ncin,lonname);
[varname,xtype,dimids,natt] = netcdf.inqVar(ncin,ivarid);
for iatt=0:natt-1
  attname = netcdf.inqAttName(ncin,ivarid,iatt);
  netcdf.copyAtt(ncin,ivarid,attname,ncid,varid);
end
netcdf.putAtt(ncid,varid,'scale_factor',1.0);
netcdf.putAtt(ncid,varid,'add_offset',0.0);

varname='co2';
varid = netcdf.defVar(ncid,varname,'NC_DOUBLE',timedim);
netcdf.putAtt(ncid,varid,'units','ppm'); 
netcdf.putAtt(ncid,varid,'long_name','concentration_of_carbon_dioxide');
netcdf.putAtt(ncid,varid,'valid_min',0.0);
netcdf.putAtt(ncid,varid,'scale_factor',1.0);
netcdf.putAtt(ncid,varid,'add_offset',0.0);

for i=1:length(variables)

  varname=variables{i};
  varid = netcdf.defVar(ncid,varname,'NC_FLOAT',[londim,latdim,timedim]);
  
  if strcmp(varname,'temperature') 
    ivarid = netcdf.inqVarID(ncin,tempname);
    [varname,xtype,dimids,natt] = netcdf.inqVar(ncin,ivarid);
    for iatt=0:natt-1
      attname = netcdf.inqAttName(ncin,ivarid,iatt);
      netcdf.copyAtt(ncin,ivarid,attname,ncid,varid);
    end
    netcdf.putAtt(ncid,varid,'units','degree_celsius');
    netcdf.putAtt(ncid,varid,'average','annual mean');
    netcdf.putAtt(ncid,varid,'long_name','annual_mean_temperature_at_surface');
  elseif strcmp(varname,'precipitation') ivarid = netcdf.inqVarID(ncin,precname);
    ivarid = netcdf.inqVarID(ncin,precname);
    [varname,xtype,dimids,natt] = netcdf.inqVar(ncin,ivarid);
    for iatt=0:natt-1
      attname = netcdf.inqAttName(ncin,ivarid,iatt);
      netcdf.copyAtt(ncin,ivarid,attname,ncid,varid);
    end
    netcdf.putAtt(ncid,varid,'units','mm a-1');
    netcdf.putAtt(ncid,varid,'long_name','annual_precipitation');
  elseif strcmp(varname,'npp')
    netcdf.putAtt(ncid,varid,'units','g m-2 a-1');
    netcdf.putAtt(ncid,varid,'long_name','net_primary_production');
    netcdf.putAtt(ncid,varid,'model','Lieth (1975)');
    netcdf.putAtt(ncid,varid,'calculated_from','annual temperature_at_surface and annual_precipitation');
  elseif strcmp(varname,'gdd')
    netcdf.putAtt(ncid,varid,'units','1');
    netcdf.putAtt(ncid,varid,'long_name','growing_degree_days');
    netcdf.putAtt(ncid,varid,'calculated_from','monthly mean temperature_at_surface');
  elseif strcmp(varname,'gdd0');
    netcdf.putAtt(ncid,varid,'units','1');
    netcdf.putAtt(ncid,varid,'long_name','growing_degree_days_above_zero');
    netcdf.putAtt(ncid,varid,'calculated_from','monthly mean temperature_at_surface');
  elseif strcmp(varname,'gdd5')
    netcdf.putAtt(ncid,varid,'units','1');
    netcdf.putAtt(ncid,varid,'long_name','growing_degree_days_above_five');
    netcdf.putAtt(ncid,varid,'calculated_from','monthly mean temperature_at_surface');
  elseif strcmp(varname,'forest_share')
    netcdf.putAtt(ncid,varid,'units','1');
    netcdf.putAtt(ncid,varid,'long_name','forest_fraction_of_gridcell');
    netcdf.putAtt(ncid,varid,'model','VECODE');
    netcdf.putAtt(ncid,varid,'valid_min',0.0);
    netcdf.putAtt(ncid,varid,'valid_max',1.0);
  elseif strcmp(varname,'desert_share')
    netcdf.putAtt(ncid,varid,'units','1');
    netcdf.putAtt(ncid,varid,'long_name','desert_fraction_of_gridcell');
    netcdf.putAtt(ncid,varid,'model','VECODE');
    netcdf.putAtt(ncid,varid,'valid_min',0.0);
    netcdf.putAtt(ncid,varid,'valid_max',1.0);
  elseif strcmp(varname,'grassland_share')
    netcdf.putAtt(ncid,varid,'units','1');
    netcdf.putAtt(ncid,varid,'long_name','grassland_fraction_of_gridcell');
    netcdf.putAtt(ncid,varid,'model','VECODE');
    netcdf.putAtt(ncid,varid,'valid_min',0.0);
    netcdf.putAtt(ncid,varid,'valid_max',1.0);
  elseif strcmp(varname,'needle_forest_share')
    netcdf.putAtt(ncid,varid,'units','1'); 
    netcdf.putAtt(ncid,varid,'long_name','needle_forest_fraction_of_gridcell');
    netcdf.putAtt(ncid,varid,'model','VECODE');
    netcdf.putAtt(ncid,varid,'valid_min',0.0);
    netcdf.putAtt(ncid,varid,'valid_max',1.0);
  elseif strcmp(varname,'carbon_in_soil')
    netcdf.putAtt(ncid,varid,'units','kg m-2');
    netcdf.putAtt(ncid,varid,'long_name','carbon_in_soil');
    netcdf.putAtt(ncid,varid,'model','VECODE');
  elseif strcmp(varname,'carbon_in_litter') 
    netcdf.putAtt(ncid,varid,'units','kg m-2');
    netcdf.putAtt(ncid,varid,'long_name','carbon_in_litter');
    netcdf.putAtt(ncid,varid,'model','VECODE');
  elseif strcmp(varname,'carbon_in_stems')
    netcdf.putAtt(ncid,varid,'units','kg m-2');
    netcdf.putAtt(ncid,varid,'long_name','carbon_in_stem');
    netcdf.putAtt(ncid,varid,'model','VECODE');
  elseif strcmp(varname,'carbon_in_leaves')
    netcdf.putAtt(ncid,varid,'units','kg m-2');
    netcdf.putAtt(ncid,varid,'long_name','carbon_in_leaves');
    netcdf.putAtt(ncid,varid,'model','VECODE');
  elseif strcmp(varname,'lai')
    netcdf.putAtt(ncid,varid,'units','m^1 m^{-2}');
    netcdf.putAtt(ncid,varid,'long_name','leaf_area_index');
    netcdf.putAtt(ncid,varid,'model','VECODE');
  end
    
  netcdf.putAtt(ncid,varid,'scale_factor',1.0);
  netcdf.putAtt(ncid,varid,'add_offset',0.0);
  netcdf.putAtt(ncid,varid,'date_of_modification',datestr(now));

end

netcdf.endDef(ncid);
netcdf.close(ncin);

varid=netcdf.inqVarID(ncid,'time');
for i=1:length(time)
  netcdf.putVar(ncid,varid,i-1,double(time(i)));
end

netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lat'),lat);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lon'),lon);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'co2'),co2);

for i=1:length(variables)
  varname=variables{i};
  if strcmp(varname,'lai') netcdf.putVar(ncid,netcdf.inqVarID(ncid,varname),climate.production.lai);
  elseif strcmp(varname,'npp') netcdf.putVar(ncid,netcdf.inqVarID(ncid,varname),climate.npp);
  elseif strcmp(varname,'temperature') netcdf.putVar(ncid,netcdf.inqVarID(ncid,varname),climate.temp);
  elseif strcmp(varname,'precipitation') netcdf.putVar(ncid,netcdf.inqVarID(ncid,varname),climate.prec);
  elseif strcmp(varname,'gdd') netcdf.putVar(ncid,netcdf.inqVarID(ncid,varname),climate.gdd);
  elseif strcmp(varname,'gdd0') netcdf.putVar(ncid,netcdf.inqVarID(ncid,varname),climate.gdd0);
  elseif strcmp(varname,'gdd5') netcdf.putVar(ncid,netcdf.inqVarID(ncid,varname),climate.gdd5);
  elseif strcmp(varname,'carbon_in_soil') netcdf.putVar(ncid,netcdf.inqVarID(ncid,varname),climate.carbon.soil);
  elseif strcmp(varname,'carbon_in_stems') netcdf.putVar(ncid,netcdf.inqVarID(ncid,varname),climate.carbon.stem);
  elseif strcmp(varname,'carbon_in_leaves') netcdf.putVar(ncid,netcdf.inqVarID(ncid,varname),climate.carbon.leaf);
  elseif strcmp(varname,'carbon_in_litter') netcdf.putVar(ncid,netcdf.inqVarID(ncid,varname),climate.carbon.litter);
  elseif strcmp(varname,'forest_share') netcdf.putVar(ncid,netcdf.inqVarID(ncid,varname),climate.share.forest);
  elseif strcmp(varname,'needle_forest_share') netcdf.putVar(ncid,netcdf.inqVarID(ncid,varname),climate.share.needle);
  elseif strcmp(varname,'grassland_share') netcdf.putVar(ncid,netcdf.inqVarID(ncid,varname),climate.share.grass);
  elseif strcmp(varname,'desert_share') netcdf.putVar(ncid,netcdf.inqVarID(ncid,varname),climate.share.desert);
  else 
    warning('Variable %s not defined in netCDF file. Skipped',varname);
  end
end
  

netcdf.close(ncid);
      
return;
end
