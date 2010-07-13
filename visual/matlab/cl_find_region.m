function [region,index,latlim,lonlim]=cl_find_region(varargin)

cl_register_function;

%% Control variable arguments input

arguments = {...
  {'latlim',[-60 80]},...
  {'lonlim',[-180 180]},...
  {'name','all'},...
  {'file','../../test.nc'},...
  {'nearest',0}
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end


if ~exist(file,'file') error('File does not exist'); end

ncid=netcdf.open(file,'NC_NOWRITE');
varid=netcdf.inqVarID(ncid,'latitude');
lat=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'longitude');
lon=netcdf.getVar(ncid,varid);
%varid=netcdf.inqVarID(ncid,'region');
%region=netcdf.getVar(ncid,varid);

if length(lonlim)==1 lonlim(2)=lonlim(1); end
if length(latlim)==1 latlim(2)=latlim(1); end


if (nearest==1)
  [mindist,index]=min((lat-latlim(1)).^2 + (lon-lonlim(1)).^2);
else
  index=find(lat>=latlim(1) & lat<=latlim(2) & lon>=lonlim(1) & lon<=lonlim(2));
end

%region=region(index);
region=index;

return
end
