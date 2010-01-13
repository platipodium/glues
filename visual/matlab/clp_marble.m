function [p,lonlim,latlim]=clp_marble(varargin)

cl_register_function;

% typically called after clp_basemap
% Default values
latlim=[-60 70];
lonlim=[-180 180];

% todo: if no figure exists, create one with a call to clp_basemap

if ~exist('filename','var') 
  filename='data/TrueMarble.32km.1350x675.tif'; 
end

if ~exist(filename,'file')
    warning('File %s does not exist, trying to fetch from server (takes some time)',filename);
    [f,status]=urlwrite(['http://ueod-globe.net/globe/TrueMarble_GeoTIFF/' filename '.gz'],[filename '.gz']);
    %if  status==0
    gunzip([filename '.gz']);
    %end
end

if ~exist(filename,'file') 
  return
end

a=imread(filename);
[nla,nlo,ncol]=size(a);
 
gla=[90:-180./(nla-1):-90];
glo=[-180+180./nlo:360./nlo:180-180./nlo];

 
% get only interesting part (i.e. between 60S and 70 N);
igla=find(gla>=latlim(1) & gla<=latlim(2));
iglo=find(glo>=lonlim(1) & glo<=lonlim(2));
latlim(1)=gla(igla(end)); latlim(2)=gla(igla(1));
lonlim(2)=glo(iglo(1)); lonlim(2)=glo(iglo(end));
glo=glo(iglo);
gla=gla(igla);
a=a(igla,iglo,:);
 
% m_proj('equidistant','lat',[latmin,latmax],'lon',[lonmin,lonmax]);
[llx,lly]=m_ll2xy(lonlim(1),latlim(1),'clip','off');
[urx,ury]=m_ll2xy(lonlim(2),latlim(2),'clip','off');
 
p=image([llx,urx],[ury,lly],a(:,:,1:3));

return
end