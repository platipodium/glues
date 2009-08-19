function write_region_lpj(varargin)

cl_register_function();

timestart=-10000;
timeend=1500;

matfile='regionmap_685.mat';

climatefile='e-allh2.mat';

if ~exist(climatefile,'file') 
  error('No climate change information found');
else
  lpj=load(climatefile);
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
nppfile=[strrep(prefix,'map','_lpj_npp') '.tsv'];
gddfile=[strrep(prefix,'map','_lpj_gdd') '.tsv'];
climatefile=[strrep(prefix,'map','_lpj') '.mat'];

load(matfile);
nreg=length(region.length);
[cols,rows]=size(map.region);

lpj.time=lpj.TIME+2000;

lon=lpj.LONGITUDE;
dlon=lon(2)-lon(1);
lon=lon+dlon/2;
lpj.lon=lon;

lat=lpj.LATITUDE;
dlat=lat(2)-lat(1);
lat=lat-dlat/2;
lpj.lat=lat;

nlon=length(lon);
nlat=length(lat);
nclim=length(lpj.time);

npp=squeeze(lpj.npp);
gdd=squeeze(lpj.gdd)/25;

npp(find(npp<=0))=NaN;
gdd(find(gdd<=0))=NaN;

lpj.npp=npp;
lpj.gdd=gdd;

climate.npp=zeros(nreg,nclim);
climate.gdd=climate.npp;

debug=0;

for ireg=1:nreg
  % select all cells of this region
  
  iselect=find(land.region == ireg);
  nselect=length(iselect);
  if nselect<1 error('Something is wrong here, no cells with region'); end

  [ilon,ilat]=regidx2geoidx(land.map(iselect),cols);
  iclon=ceil(ilon/cols*length(lpj.lon));
  iclat=ceil((361-ilat)/rows*length(lpj.lat));
  
  rnpp=zeros(region.length(ireg),nclim)-NaN;
  rgdd=rnpp;
  
  fprintf('%4d',ireg);
  for iclim=1:nclim
      climate.gdd(ireg,iclim)=calc_geo_mean(land.lat(iselect),diag(squeeze(lpj.gdd(iclon,iclat,iclim))));
      climate.npp(ireg,iclim)=calc_geo_mean(land.lat(iselect),diag(squeeze(lpj.npp(iclon,iclat,iclim))));
      fprintf('.');
  end  
  
  fprintf('\n');
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

iclimmin=max([1;find(lpj.time<timestart)]+1);
iclimmax=min([nclim;find(lpj.time>timeend)]);

for ireg=1:nreg 
    fprintf(fid,'%04d %5d',ireg,iclimmax-iclimmin+1);
    for iclim=iclimmin:iclimmax
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
    fprintf(fid,'%04d %5d',ireg,iclimmax-iclimmin+1);
    for iclim=iclimmin:iclimmax
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



 

