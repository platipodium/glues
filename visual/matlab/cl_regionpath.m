function [lon,lat,rlon,rlat]=cl_regionpath(varargin)

cl_register_function;

arguments = {...
  {'latlim',[-inf inf]},...
  {'lonlim',[-inf inf]},...
  {'reg','all'},...
  {'filename','regionpath_685'}...
};

[args,rargs]=clp_arguments(varargin,arguments);
for i=1:args.length   
  eval([ args.name{i} ' = ' clp_valuestring(args.value{i}) ';']); 
end

if all(isfinite([latlim lonlim]))
  [iselect,nfound,loli,lali]=find_region_numbers('lat',latlim,'lon',lonlim,'file',filename);
else
  [iselect,nfound,lonlim,latlim]=find_region_numbers(reg,'file',filename);%[216, 279, 315, 170];
end

load(filename);

if exist('region','var') & isstruct(region) 
  nreg=region.nreg; 
  regionpath=region.path;
  lat=region.lat;
  lon=region.lon;
else
    region.path=regionpath;
    region.nreg=nreg;
    region.neighbourhood=regionneighbourhood;
    region.neighbours=regionneighbours;
    lon=regionlon;
    lat=regionlat;
end

pf=polyfit((1:nreg)',regionpath(:,1,2),1);
if (pf(1)*nreg>30) regionpath(:,:,2)=regionpath(nreg:-1:1,:,2); end

lonoffset=10; latoffset=10;

lats=squeeze(regionpath(iselect,:,2));
lons=squeeze(regionpath(iselect,:,1));
latmin=min(lats(lats>-999))-latoffset;
latmax=max(lats(lats>-999))+latoffset;
lonmax=max(lons(lons>-999))+lonoffset;
lonmin=min(lons(lons>-999))-lonoffset;

if exist('lonlim','var') lonmin=lonlim(1); lonmax=lonlim(2); end;
if exist('latlim','var') latmin=latlim(1); latmax=latlim(2); end;


lon=lon(iselect);
lat=lat(iselect);
for i=1:length(iselect)
  
  valid=find(isfinite(regionpath(iselect(i),:,2)));
  if isempty(valid) continue; end
  
  lonpath=regionpath(iselect(i),valid,1);
  latpath=regionpath(iselect(i),valid,2);
    
end

if nargout>0
    lon=lonpath;
    lat=latpath;
  rlon=mean(lonpath);
  rlat=mean(latpath);
end

return
end