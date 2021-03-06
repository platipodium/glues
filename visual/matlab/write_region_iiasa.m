function write_region_iiasa(varargin)

cl_register_function();

matfile='regionmap_685.mat';

climatefile='iiasa.mat';

if ~exist(climatefile,'file') 
  warning('No climate change information found / %s missing. writing static climate',climatefile);
else
  iiasa=load(climatefile);
end

iarg=1;
while iarg<=nargin
  arg=lower(varargin{iarg});
  
  switch arg(1:3)
    case 'fil'
          matfile=varargin{iarg+1};
          iarg=iarg+1;
      otherwise
        fprintf('Unknown keyword %s.',varargin{iarg});    
  end
  iarg=iarg+1;
end

if ~exist(matfile,'file') return; end

prefix=strrep(matfile,'.mat','');
nppfile=[strrep(prefix,'map','_iiasa_npp') '.tsv'];
gddfile=[strrep(prefix,'map','_iiasa_gdd') '.tsv'];
climatefile=[strrep(prefix,'map','_iiasa') '.mat'];


load(matfile);
if ~exist('region','var') region.length=regionlength; end
nreg=length(region.length);

if ~exist('map','var') 
  map.region=regionmap;
  map.longrid=longrid;
  map.latgrid=fliplr(latgrid);
end

[cols,rows]=size(map.region);


iiasa.temp=mean(iiasa.tmean,2);
iiasa.precip=sum(iiasa.prec,2);
[iiasa.gdd,iiasa.gdd0,iiasa.gdd5]=clc_gdd(iiasa.tmean);
[production,share,carbon,p]=clc_vecode(iiasa.temp,iiasa.precip,iiasa.gdd0);

iiasa.npp=production.npp;



b12f=p.b1t+p.b2t;
b34f=p.b3t+p.b4t;
b12g=p.b1g+p.b2g;
b34g=p.b3g+p.b4g;

fshare=share.forest;
gshare=share.grass;

iiasa.ilon=2*iiasa.lon+360.5;
iiasa.ilat=361-(2*iiasa.lat+180.5);
ncol=720;
nrow=360;
iiasa.nppmap=zeros(ncol,nrow)-NaN;
iiasa.gddmap=iiasa.nppmap;
iiasa.gdd0map=iiasa.nppmap;
iiasa.tempmap=iiasa.nppmap;
iiasa.precmap=iiasa.nppmap;

fsharemap=iiasa.nppmap;
gsharemap=fsharemap;
b12fmap=fsharemap;
b34fmap=fsharemap;
b12gmap=fsharemap;
b34gmap=fsharemap;

iiasa.fcarbonmap=iiasa.nppmap;
niiasa=length(iiasa.npp);
for i=1:niiasa 
    iiasa.nppmap(iiasa.ilon(i),iiasa.ilat(i))=iiasa.npp(i);
    iiasa.gddmap(iiasa.ilon(i),iiasa.ilat(i))=iiasa.gdd(i);
    iiasa.gdd0map(iiasa.ilon(i),iiasa.ilat(i))=iiasa.gdd0(i);
    iiasa.tempmap(iiasa.ilon(i),iiasa.ilat(i))=iiasa.temp(i);
    iiasa.precmap(iiasa.ilon(i),iiasa.ilat(i))= iiasa.precip(i);
    fsharemap(iiasa.ilon(i),iiasa.ilat(i))=fshare(i);
    gsharemap(iiasa.ilon(i),iiasa.ilat(i))=gshare(i);
    b12fmap(iiasa.ilon(i),iiasa.ilat(i))=b12f(i);
    b12gmap(iiasa.ilon(i),iiasa.ilat(i))=b12g(i);
    b34fmap(iiasa.ilon(i),iiasa.ilat(i))=b34f(i);
    b34gmap(iiasa.ilon(i),iiasa.ilat(i))=b34g(i);  
    
end

debug=0;

if debug>0
    figure(2);
    clf reset;
  m_proj('miller','lat',[30,60],'lon',[-10,30]);
  m_coast;
  hold on;
  m_grid;
  m_pcolor(map.longrid,map.latgrid,iiasa.fcarbonmap');
  %shading interp;
end

nclim=1;
climate.npp=zeros(nreg,nclim);
climate.gdd=climate.npp;
climate.gdd0=climate.npp;

if ~exist('land','var')
  land.region=regionnumber;
  land.map=regionindex;
  land.lat=lat;
  land.lon=lon;
end

for ireg=1:nreg
  % select all cells of this region
  inreg=find(land.region==ireg);
  
  climate.npp(ireg)=calc_geo_mean(land.lat(inreg),iiasa.nppmap(land.map(inreg)));
  climate.gdd(ireg)=calc_geo_mean(land.lat(inreg),iiasa.gddmap(land.map(inreg)));
  climate.gdd0(ireg)=calc_geo_mean(land.lat(inreg),iiasa.gdd0map(land.map(inreg)));
  climate.prec(ireg)=calc_geo_mean(land.lat(inreg),iiasa.precmap(land.map(inreg)));
  climate.temp(ireg)=calc_geo_mean(land.lat(inreg),iiasa.tempmap(land.map(inreg)));
  climate.fshare(ireg)=calc_geo_mean(land.lat(inreg),fsharemap(land.map(inreg)));
  climate.gshare(ireg)=calc_geo_mean(land.lat(inreg),gsharemap(land.map(inreg)));
  climate.b12f(ireg)=calc_geo_mean(land.lat(inreg),b12fmap(land.map(inreg)));
  climate.b12g(ireg)=calc_geo_mean(land.lat(inreg),b12gmap(land.map(inreg)));
  climate.b34f(ireg)=calc_geo_mean(land.lat(inreg),b34fmap(land.map(inreg)));
  climate.b34g(ireg)=calc_geo_mean(land.lat(inreg),b34gmap(land.map(inreg)));
    
end

save('-v6',climatefile,'climate');

v=cl_get_version;
fid=fopen(nppfile,'w');
fprintf(fid,'# ASCII data info: columns\n');
fprintf(fid,'# 1. region id 2. number of climates,\n');
fprintf(fid,'# 3..n dynamic-npp\n');
fprintf(fid,'# Version info: %s\n',struct2stringlines(v));

climate.npp(isnan(climate.npp))=0;
climate.gdd(isnan(climate.gdd))=0;

for ireg=1:nreg 
    fprintf(fid,'%04d %5d',ireg,nclim);
    for iclim=1:nclim
        fprintf(fid,' %d',round(climate.npp(ireg,iclim)));
    end
    fprintf(fid,'\n');
end
fclose(fid);

fid=fopen(gddfile,'w');
fprintf(fid,'# ASCII data info: columns\n');
fprintf(fid,'# 1. region id 2. number of climates \n');
fprintf(fid,'# 4..n dynamic-gdd\n');
fprintf(fid,'# Version info: %s\n',struct2stringlines(v));

for ireg=1:nreg 
    fprintf(fid,'%04d %5d',ireg,nclim);
    for iclim=1:nclim
        fprintf(fid,' %d',round(climate.gdd(ireg,iclim)));
    end
    fprintf(fid,'\n');
end
fclose(fid);

return
end

function lat=x2lat(ilat)
  lat=90.0-ilat/2.0;
  return;
end

function lon=x2lon(ilon)
  lon=ilon/2.0-180;
  return;
end

function ilat=lat2x(lat)
  ilat=ceil((90.0-lat)*2.0);
  return;
end


function ilon=lon2x(lon)
  ilon=ceil((lon+180)*2.0);
  return;
end



 

