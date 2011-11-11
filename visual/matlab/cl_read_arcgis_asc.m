function d=cl_read_arcgis_asc(varargin)
% Reads raster data compiled by ARCGIS and output as ascii

% This format is expected
% ncols         392
% nrows         341
% xllcorner     25.228034779539 % or xllcenter
% yllcorner     -22.426731220461
% cellsize      0.02
% NODATA_value  -9999
% <data>

arguments = {...
  {'latlim',[-inf inf]},...
  {'lonlim',[-inf inf]},...
  {'file','/Users/lemmen/projects/zimbabwe/netlogo/data/p800.asc'},... 
  {'noprint',0}...
};

cl_register_function();

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end

if ~exist(file,'file')
    error('File does not exist');
end


fid=fopen(file,'r');
t=textscan(fid,'%s%f');
for i=1:6
  eval(sprintf('%s=t{2}(i);',lower(char(t{1}(i)))));
end
fclose(fid);

if exist('xllcorner','var')
  lon=xllcorner+[0:ncols-1]*cellsize;
  lat=yllcorner+[nrows-1:-1:0]*cellsize;
else
  lon=xllcenter+[0:ncols-1]*cellsize-0.5*cellsize;
  lat=yllcenter+[nrows-1:-1:0]*cellsize-0.5*cellsize;
end    
latlim=[min(lat) max(lat)];
lonlim=[min(lon) max(lon)];

data=textread(file,'%f','headerlines',6);
data=reshape(data,ncols,nrows)';
data(data==nodata_value)=NaN;

if nargout>0
  d.data=data;
  d.lat=lat;
  d.lon=lon;
  d.latlim=latlim;
  d.lonlim=lonlim;
  d.filename=file;
end

if ~noprint
figure(1);
clf reset; hold on;
m_proj('equidistant','lat',latlim,'lon',lonlim);
m_coast;
m_grid;
m_pcolor(lon,lat,data);
m_contour(lon,lat,data,[500 500],'color','r','linewidth',3);
shading interp;
colorbar;
end

return
end


