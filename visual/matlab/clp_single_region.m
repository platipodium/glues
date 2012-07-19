function clp_single_region(varargin)
% This function takes arve grid cells (and data on it) and projects it onto
% the glues regions

arguments = {...
  {'file','../../pop.nc'},...
  {'id',272},...
  {'scenario',''}...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end


%% Read results file
if ~exist(file,'file') error('File does not exist'); end
ncid=netcdf.open(file,'NC_NOWRITE');

varname='region'; varid=netcdf.inqVarID(ncid,varname);
reg=netcdf.getVar(ncid,varid);
ireg=find(reg>-1);

[ndim nvar natt udimid] = netcdf.inq(ncid); 
for varid=0:nvar-1
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
  if strcmp(varname,'lat') lat=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'lon') lon=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'latitude') latit=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'longitude') lonit=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'area') area=netcdf.getVar(ncid,varid); end
end

if exist('lat','var') 
  if length(lat)~=(region)
    if exist('latit','var') lat=latit; end
  end
else
  if exist('latit','var') lat=latit; end
end

if exist('lon','var') 
  if length(lon)~=(region)
    if exist('lonit','var') lon=lonit; end
  end
else
  if exist('lonit','var') lon=lonit; end
end

netcdf.close(ncid);

nreg=length(id);


load('regionmap_sea_685.mat');
nrow=size(map.region,1);
ncol=size(map.region,2);


map.region=zeros(720,360);
for i=1:length(land.region)
    map.region(land.ilon(i),land.ilat(i))=land.region(i);
end

[irow,icol,val]=find(map.region==id);
gridarea=sum(calc_gridcell_area(map.latgrid(icol),0.5,0.5));
  

figure(id); clf reset; hold on;
m_proj('equidistant','lon',...
      [min(map.longrid(irow))-1 max(map.longrid(irow))+1],...
      'lat',[min(map.latgrid(icol))-1 max(map.latgrid(icol))+1]);
m_coast;
m_grid;
hold on;
m_plot(map.longrid(irow),map.latgrid(icol),'b.');
title(['Region ' num2str(id)]);
legend(['Lon ' num2str(lon(id))],['Lat ' num2str(lat(id))],['Area ' num2str(area(id))],['GArea ' num2str(gridarea)],'location','northeastoutside');

return
end