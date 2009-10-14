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

if ~exist('map','var') map.region=regionmap; end
[cols,rows]=size(map.region);


iiasa.temp=mean(iiasa.tmean,2);
iiasa.precip=sum(iiasa.prec,2);
iiasa.gdd=sum(iiasa.tmean>0,2)*30.;
[iiasa.npp,iiasa.fshare,iiasa.dshare]=vecode(iiasa.temp,iiasa.precip,iiasa.gdd);

iiasa.ilon=2*iiasa.lon+360.5;
iiasa.ilat=361-(2*iiasa.lat+180.5);
ncol=720;
nrow=360;
iiasa.nppmap=zeros(ncol,nrow)-NaN;
iiasa.gddmap=iiasa.nppmap;
iiasa.tempmap=iiasa.nppmap;
iiasa.precmap=iiasa.nppmap;
iiasa.fsharemap=iiasa.nppmap;
iiasa.dsharemap=iiasa.nppmap;
niiasa=length(iiasa.npp);
for i=1:niiasa 
    iiasa.nppmap(iiasa.ilon(i),iiasa.ilat(i))=iiasa.npp(i);
    iiasa.gddmap(iiasa.ilon(i),iiasa.ilat(i))=iiasa.gdd(i);
    iiasa.tempmap(iiasa.ilon(i),iiasa.ilat(i))=iiasa.temp(i);
    iiasa.precmap(iiasa.ilon(i),iiasa.ilat(i))= iiasa.precip(i);
    iiasa.fsharemap(iiasa.ilon(i),iiasa.ilat(i))=iiasa.fshare(i);
    iiasa.dsharemap(iiasa.ilon(i),iiasa.ilat(i))=iiasa.dshare(i);
    
end

debug=1;

if debug>0
    figure(2);
    clf reset;
  m_proj('miller','lat',[30,60],'lon',[-10,30]);
  m_coast;
  hold on;
  m_grid;
  m_pcolor(map.longrid,map.latgrid,iiasa.fsharemap');
  shading interp;
end

nclim=1;
climate.npp=zeros(nreg,nclim);
climate.gdd=climate.npp;


for ireg=1:nreg
  % select all cells of this region
  inreg=find(land.region==ireg);
  
  climate.npp(ireg)=calc_geo_mean(land.lat(inreg),iiasa.nppmap(land.map(inreg)));
  climate.gdd(ireg)=calc_geo_mean(land.lat(inreg),iiasa.gddmap(land.map(inreg)));
  climate.prec(ireg)=calc_geo_mean(land.lat(inreg),iiasa.precmap(land.map(inreg)));
  climate.temp(ireg)=calc_geo_mean(land.lat(inreg),iiasa.tempmap(land.map(inreg)));
  climate.fshare(ireg)=calc_geo_mean(land.lat(inreg),iiasa.fsharemap(land.map(inreg)));
  climate.dshare(ireg)=calc_geo_mean(land.lat(inreg),iiasa.dsharemap(land.map(inreg)));
    
end

save('-v6',climatefile,'climate');

v=get_version;
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



 

