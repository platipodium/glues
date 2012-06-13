function [h,lonlimit,latlimit,lon,lat]=clp_regionpath(varargin)

cl_register_function;

arguments = {...
  {'latlim',[-inf inf]},...
  {'lonlim',[-inf inf]},...
  {'colpath','k'},...
  {'drawmode','optimal'},...
  {'reg','all'},...
  {'rpath','regionpath_685'}...
};

[args,rargs]=clp_arguments(varargin,arguments);
for i=1:args.length   
  eval([ args.name{i} ' = ' clp_valuestring(args.value{i}) ';']); 
end

if all(isfinite([latlim lonlim]))
  [iselect,nfound,loli,lali]=cl_select_regions('lat',latlim,'lon',lonlim,'rpath',rpath);
else
  [iselect,nfound,lonlim,latlim]=cl_select_regions('reg',reg,'rpath',rpath);%[216, 279, 315, 170];
end

load(sprintf('%s.mat',rpath));


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


if strcmp(drawmode,'optimal')
    icolors=calc_regioncolors(region);
    ncolors=max(icolors);
    colors=[0.9 0.2 0.9; 0.2 0.9 0.9; 0.9 0.9 0.2; 
            0.8 0.4 0.8; 0.4 0.8 0.8; 0.8 0.8 0.4;
            0.6 0.6 0.8; 0.6 0.8 0.6; 0.8 0.6 0.6];
    colors=prism;
    colors=rgb2hsv(colors(1:6,:));
    colors(:,2)=0.3; % make pastel;
    colors=hsv2rgb(colors);
end

% TODO remove correction in lat/lon
%regionpath(:,:,1)=regionpath(:,:,1)-0.5;
%regionpath(:,:,2)=regionpath(:,:,2)-1;

% Adjust to different orientations in regionpath file. generally, lat
% should be decreasing and lon should be increasing
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

% if the current figure is not on hold, create a new one
if ~ishold
  clp_basemap('lat',latlim,'lon',lonlim);
end

phdl=[];

lon=lon(iselect);
lat=lat(iselect);
for i=1:length(iselect)
  
  valid=find(isfinite(regionpath(iselect(i),:,2)));
  if isempty(valid) continue; end
  
  lonpath=regionpath(iselect(i),valid,1);
  latpath=regionpath(iselect(i),valid,2);
  if strcmp(drawmode,'optimal')
    colpath=colors(icolors(iselect(i)),:);
  end
    
  if strcmp(drawmode,'patch')
    phdl(i)=m_patch(lonpath,latpath,colpath,'EdgeColor','none');
  elseif strcmp(drawmode,'line') 
    %if ~isempty(varargin) phdl(i)=m_line(lonpath,latpath,'color',colpath,rargs);
    %else 
    phdl(i)=m_line(lonpath,latpath,'color',colpath); %end
  else 
    phdl(i)=m_patch(lonpath,latpath,colpath,'EdgeColor','none');      
    %set(mp,'LineStyle','none');
  end
  
  %lat(i)=calc_geo_mean(latpath,latpath);
  %lon(i)=calc_geo_mean(latpath,lonpath);
end

if nargout>0
  lonlimit=lonlim;
  latlimit=latlim;
  h=phdl;
end

return
