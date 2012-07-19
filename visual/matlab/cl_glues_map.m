function cl_glues_map(varargin)
% CL_GLUES_MAP creates a mapping of the region ids on a lat-lon grid
%   variable arguments:
%     file = '../../data/glues_map.nc'

% 
%% Standard arguments block
cl_register_function;

arguments = {...
  {'file','../../data/glues_map.nc'},...
};

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end


%%
matfile='regionmap_sea_685.mat';
load(matfile);

lat=map.latgrid;
lon=map.longrid;
nlon=length(lon);
nlat=length(lat);

map.region=zeros(nlon,nlat);
for i=1:length(land.region)
    map.region(land.ilon(i),land.ilat(i))=land.region(i);
end
region=map.region;
lsm=(region>0).*region;

figure(1); clf reset; hold on;
m_proj('equidistant');
m_coast;
m_grid;
m_pcolor(lon,lat,lsm');
shading interp;

if exist(file,'file') delete(file); end

ncid=netcdf.create(file,'NOCLOBBER');
londimid=netcdf.defDim(ncid,'lon',nlon);
latdimid=netcdf.defDim(ncid,'lat',nlat);
lonvarid=netcdf.defVar(ncid,'lon','NC_DOUBLE',londimid);
latvarid=netcdf.defVar(ncid,'lat','NC_DOUBLE',latdimid);
regvarid=netcdf.defVar(ncid,'region','NC_INT',[londimid latdimid]);
netcdf.endDef(ncid);

netcdf.putVar(ncid,lonvarid,lon);
netcdf.putVar(ncid,latvarid,lat);
netcdf.putVar(ncid,regvarid,region);

netcdf.close(ncid);

return;
end