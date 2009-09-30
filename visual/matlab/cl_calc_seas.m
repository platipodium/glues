function cl_calc_seas(varargin)

cl_register_function();

regionmapfile='regionmap_1439.mat';
load(regionmapfile);

%load('/h/lemmen/projects/glues/glues/glues/examples/setup/686/mapping_80_685.mat');


if ~exist('region','var') | ~isstruct(region) 
    map.region=regionmap;
    region.length=regionlength;
    map.latgrid=latgrid;
    map.longrid=longrid;
    region.land=regionarray;
    land.region=regionnumber;
    land.map=regionindex;
    land.lat=lat;
    land.lon=lon;
    region.nreg=length(region.length);
end

[cols rows]=size(map.region);
nreg=length(region.length);

% Set water to 999 in map.region
tmpmap=map.region.*0-1;
tmpmap(land.map)=land.region;
iwater=find(tmpmap < 0);
nwater=length(iwater);
map.region(iwater)=-10;

latmap=ones(720,1) * -map.latgrid;
lonmap=map.longrid' * ones(1,360);
 
imedi=find( (lonmap >= -5.3 & lonmap <= 37) ...
          & (latmap <= 46.5   & latmap >= 30) ...
          & (latmap <= 40 | lonmap >= 0) ...
          & (latmap <= 41 | lonmap <= 22) & map.region < 0 );
map.region(imedi)=-200;

iblack=find(latmap >= 41 & latmap <= 48 ...
         & lonmap >= 22 & lonmap <= 45  & map.region < 0);
map.region(iblack)=-300;

ired= find(latmap <= 30 & latmap >= 12 ...
         & lonmap >= 32 & lonmap <= 43.5 & map.region < 0);
map.region(ired)=-400;

ipersian= find(latmap <= 32 & latmap >= 23 ...
         & lonmap >= 47 & lonmap <= 57 & map.region < 0);
map.region(ipersian)=-450;

icaspian= find(latmap <= 50 & latmap >= 35 ...
         & lonmap >= 47 & lonmap <= 54 & map.region < 0);
map.region(icaspian)=-350;

ibaltic= find( ((latmap <= 56 & latmap >= 53 ...
                & lonmap >= 9 & lonmap <= 32) ...
         | (latmap >= 56 & latmap <= 66 ...
         & lonmap >= 13 & lonmap <= 32 )) & map.region < 0);
map.region(ibaltic)=-650;

regionmapseafile=sprintf('regionmap_sea_%d',nreg);

save('-v6',regionmapseafile,'region','land','map');

return
