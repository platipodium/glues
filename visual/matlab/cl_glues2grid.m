function cl_glues2grid(varargin)
% This function takes glues results for glues regions, and maps them to a 
% grid of specified resolution

arguments = {...
  {'timelim',[-8500,-3000]},...
  {'variables',{'farming','farming_timing'}},...
  {'timestep',50},...
  {'file','../../euroclim_0.4.nc'},...
  {'resolution',0.5},...
  {'latlim',[-inf inf]},...
  {'lonlim',[-inf inf]},...
  {'reg','lbk'}
};

cl_register_function;

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


[ireg,nreg,loli,lali]=find_region_numbers(reg);
lonlim(isinf(lonlim))=loli(isinf(lonlim));
latlim(isinf(latlim))=lali(isinf(latlim));


%% Read results file
if ~exist(file,'file') error('File does not exist'); end
ncid=netcdf.open(file,'NC_NOWRITE');

varname='region'; varid=netcdf.inqVarID(ncid,varname);
[varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
rdim=dimids;
id=netcdf.getVar(ncid,varid);
nid=length(id);

varname='time'; varid=netcdf.inqVarID(ncid,varname);
time=netcdf.getVar(ncid,varid);

[ndim nvar natt udimid] = netcdf.inq(ncid); 
if ~iscell(variables) 
    
  if strcmp(variables,'all')
    clear('variables');
    for varid=0:nvar-1
      [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
      variables{varid+1}=varname;
    end
  else
      v=variables; clear('variables');
      variables{1}=v;
  end
end

% Find time dimension
tid=netcdf.inqVarID(ncid,netcdf.inqDim(ncid,udimid));
tdim=udimid;
time=netcdf.getVar(ncid,tid);
ntime=length(time);
if numel(timelim)==1 timelim(1:2) = timelim(1); end
if ntime>1
  dtime=abs(time(2)-time(1));
  itime=find(time>=timelim(1) & time<=timelim(2));
  if isempty(itime)
    error('Not data in specified time range')
  end
  itime=itime([1:round(timestep/dtime):length(itime)]);
else itime=1;  
end
time=time(itime);


ofile=strrep(file,'.nc',['_' num2str(resolution) 'x' num2str(resolution) '.nc']);
if exist(ofile,'file') delete(ofile); end
ncout=netcdf.create(ofile,'NOCLOBBER');

latgrid=[90-resolution/2.0:-resolution:-90+resolution/2.0];
iglat=find(latgrid>=latlim(1) & latgrid<=latlim(2));
latgrid=latgrid(iglat);

longrid=[-180+resolution/2.0:resolution:180-resolution/2.0];
iglon=find(longrid>=lonlim(1) & longrid<=lonlim(2));
longrid=longrid(iglon);

nglon=length(longrid);
nglat=length(latgrid);

timedimid=netcdf.defDim(ncout,'time',0);
londimid=netcdf.defDim(ncout,'lon',nglon);
latdimid=netcdf.defDim(ncout,'lat',nglat);
lonvarid=netcdf.defVar(ncout,'time','NC_DOUBLE',timedimid);
lonvarid=netcdf.defVar(ncout,'lon','NC_DOUBLE',londimid);
latvarid=netcdf.defVar(ncout,'lat','NC_DOUBLE',latdimid);
regvarid=netcdf.defVar(ncout,'region','NC_INT',[londimid,latdimid]);

% Copy attributes for GLOBAL, time, region
varids=[netcdf.getConstant('NC_GLOBAL') netcdf.inqVarID(ncid,'time') netcdf.inqVarID(ncid,'region')];
ovarids=[netcdf.getConstant('NC_GLOBAL') netcdf.inqVarID(ncout,'time') netcdf.inqVarID(ncout,'region')];
for ivarid=1:length(varids)
  varid=varids(ivarid);
  ovarid=ovarids(ivarid);
  if ivarid>1 [name,xtype,dimids,natts]=netcdf.inqVar(ncid,varid); else natts=natt; end
  for iatt=0:natts-1
    attname = netcdf.inqAttName(ncid,varid,iatt);
    netcdf.copyAtt(ncid,varid,attname,ncout,ovarid);
  end
  netcdf.putAtt(ncout,ovarid,'date_of_modification',datestr(now));
end

% Make attributes for lat, lon
varid=netcdf.inqVarID(ncout,'lat');
netcdf.putAtt(ncout,varid,'units','degrees_north');
netcdf.putAtt(ncout,varid,'long_name','latitude');
netcdf.putAtt(ncout,varid,'description','centered latitude of grid cell');
netcdf.putAtt(ncout,varid,'coordinates','lat');
netcdf.putAtt(ncout,varid,'date_of_creation',datestr(now));
varid=netcdf.inqVarID(ncout,'lon');
netcdf.putAtt(ncout,varid,'units','degrees_east');
netcdf.putAtt(ncout,varid,'long_name','longitude');
netcdf.putAtt(ncout,varid,'description','centered longitude of grid cell');
netcdf.putAtt(ncout,varid,'coordinates','lon');
netcdf.putAtt(ncout,varid,'date_of_creation',datestr(now));


stype=netcdf.getConstant('NC_FLOAT');
dtype=netcdf.getConstant('NC_DOUBLE');
itype=netcdf.getConstant('NC_INT');


% Define variables and copy atts
for ivar=1:length(variables)
  varname=variables{ivar};
  switch varname
    case {'time','region','latitude','longitude','area'}, continue;
  end
  
  % Exclude instantaneous variables 
  if (timestep~=dtime)
    switch varname
      case {'relative_growth_rate','migration_density'}, continue;
    end
    if findstr('spread',varname) continue; end
  end
  
  try 
    varid=netcdf.inqVarID(ncid,varname);
  catch
    warning('Requested variable %s not in input file',varname);
    continue;
  end
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);  
  if length(dimids)==1
    if dimids==tdim
      ovarid=netcdf.defVar(ncout,varname,xtype,timedimid);      
    elseif dimids==rdim
      ovarid=netcdf.defVar(ncout,varname,xtype,[londimid latdimid]);
    else
      warning('Additional dimension of %s not implemented, skipped',varname);
      continue;
    end
  elseif length(dimids)==2
    if dimids(1)==rdim & dimids(2)==tdim
      if (xtype==dtype) xtype=stype; end
      ovarid=netcdf.defVar(ncout,varname,xtype,[londimid latdimid timedimid]);
    else
      warning('Additional dimension of %s not implemented, skipped',varname); 
      continue;
    end
  else
    warning('Additional dimension of %s not implemented, skipped',varname); 
    continue;
  end
  for iatt=0:natts-1
    attname = netcdf.inqAttName(ncid,varid,iatt);
    netcdf.copyAtt(ncid,varid,attname,ncout,ovarid);
  end
  netcdf.putAtt(ncout,ovarid,'date_of_modification',datestr(now));  
end
netcdf.endDef(ncout);


%% Read GLUES raster
% map.latgrid is 89 . -89
% map.longrid is -179.. 179
% size(map.region) is 360 x 720

load('regionmap_sea_685.mat');
nrow=size(map.region,1);
ncol=size(map.region,2);

map.region=zeros(720,360);
for i=1:length(land.region)
    map.region(land.ilon(i),land.ilat(i))=land.region(i);
end


map.smallregion=map.region(iglon,iglat);
ncell=zeros(nreg,1);
for i=1:nreg
  ncell(i)=length(find(map.smallregion==ireg(i)));
end
mapping=ones(nreg,max(ncell))-NaN;

for i=1:nreg
  mapping(i,1:ncell(i))=find(map.smallregion==ireg(i));
end


% Put new time records and lat/lon grid
for i=1:length(time)
  ovarid=netcdf.inqVarID(ncout,'time');
  netcdf.putVar(ncout,ovarid,i-1,double(time(i)));
end
ovarid=netcdf.inqVarID(ncout,'lon');
netcdf.putVar(ncout,ovarid,longrid);
ovarid=netcdf.inqVarID(ncout,'lat');
netcdf.putVar(ncout,ovarid,latgrid);

tstride=round(timestep)/dtime;
ntime=length(itime);
[ndim nvar natt udimid] = netcdf.inq(ncout); 
for ovarid=0:nvar-1
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncout,ovarid);        
  switch varname
    case {'time','lat','lon'}, continue;
  end
    
  varid=netcdf.inqVarID(ncid,varname);
  
  if length(dimids)==3 & (dimids==[londimid latdimid timedimid])
    data=netcdf.getVar(ncid,varid,[0 itime(1)-1],[nid ntime],[1 tstride]);
    mdata=zeros(nglon,nglat)-NaN;
    rdata=zeros(nglon,nglat,ntime);
    for j=1:ntime 
      for i=1:nreg
        mdata(mapping(i,1:ncell(i)))=data(ireg(i),j);
      end
      mdata(1)=NaN;
      rdata(:,:,j)=mdata;
    end
  elseif length(dimids)==2 & (dimids==[londimid latdimid])
    data=netcdf.getVar(ncid,varid);
    rdata=zeros(nglon,nglat)-NaN;
    for i=1:nreg
      rdata(mapping(i,1:ncell(i)))=data(ireg(i));
    end
    %rdata(1)=NaN;
  else
    warning('Writing of %s with this dimension not implemented. Skipped',varname);
    continue;
  end
    
  if (xtype==itype) rdata(isnan(rdata))=-9999; rdata=round(rdata); end 
  if (xtype==stype) rdata=single(rdata); end 
  if (xtype==dtype) rdata=double(rdata); end 

  fprintf('Writing variable %s ...\n',varname);
  netcdf.putVar(ncout,ovarid,rdata);
end
netcdf.close(ncout);
netcdf.close(ncid);


return
end