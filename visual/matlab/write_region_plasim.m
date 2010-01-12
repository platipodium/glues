function write_region_plasim(varargin)

cl_register_function();

matfile='regionmap_685.mat';

climatefile='plasim_klima.mat';

if ~exist(climatefile,'file') 
  warning('No climate change information found / %s missing. writing static climate',climatefile);
else
  plasim=load(climatefile);
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
nppfile =[strrep(prefix,'map','_plasim_npp')  '.tsv'];
npplfile=[strrep(prefix,'map','_plasim_nppl') '.tsv'];
gddfile =[strrep(prefix,'map','_plasim_gdd')  '.tsv'];
climatefile=[strrep(prefix,'map','_plasim') '.mat'];


load(matfile);
nreg=length(region.length);
[cols,rows]=size(map.region);

plasim.npp=sum(plasim.npp,3)*360;

nlon=size(plasim.temp,1);
nlat=size(plasim.temp,2);

lon=[0:nlon-1]/nlon*360-180/nlon;

lon1=find(lon<=180);
lon2=find(lon>180);

lon=[lon(lon2)-360 lon(lon1)];

%lon(lon2)=lon(lon2)-360;
plasim.temp=[ plasim.temp(lon2,:,:);plasim.temp(lon1,:,:) ];
plasim.precip=[ plasim.precip(lon2,:,:); plasim.precip(lon1,:,:) ];
plasim.npp=[ plasim.npp(lon2,:,:);plasim.npp(lon1,:,:) ];
plasim.npp(find(plasim.npp<=0))=NaN;

lat=[0:nlat-1]/nlat*180-90+90/nlat;
lat=fliplr(lat);

plasim.nppl=vecode_npp_lieth(mean(plasim.temp,3),sum(plasim.precip,3));
plasim.gdd=sum(plasim.temp>0,3)*30.;

for ireg=1:nreg
  % select all cells of this region
  
  
  iselect=find(land.region == ireg);
  nselect=length(iselect);
  if nselect<1 error('Something is wrong here, no cells with region'); end

  [ilon,ilat]=regidx2geoidx(land.map(iselect),cols);
  iclon=ceil(ilon/cols*nlon);
  iclat=ceil((361-ilat)/rows*nlat);
    
  climate.gdd(ireg)=calc_geo_mean(land.lat(iselect),diag(squeeze(plasim.gdd(iclon,iclat))));
  climate.npp(ireg)=calc_geo_mean(land.lat(iselect),diag(squeeze(plasim.npp(iclon,iclat))));
  climate.nppl(ireg)=calc_geo_mean(land.lat(iselect),diag(squeeze(plasim.nppl(iclon,iclat))));
  
end

if (str2num(version('-release'))<14)
  save(climatefile,'climate');
else
save('-v6',climatefile,'climate');
end

v=cl_get_version;
fid=fopen(nppfile,'w');
fprintf(fid,'# ASCII data info: columns\n');
fprintf(fid,'# 1. region id 2. number of climates,\n');
fprintf(fid,'# 3..n dynamic-npp\n');
fprintf(fid,'# Version info: %s\n',struct2stringlines(v));

climate.npp(isnan(climate.npp))=0;
climate.gdd(isnan(climate.npp))=0;
climate.nppl(isnan(climate.npp))=0;
nclim=1;

for ireg=1:nreg 
    fprintf(fid,'%04d %03d',ireg,nclim);
    fprintf(fid,' %d',round(climate.npp(ireg)));
    fprintf(fid,'\n');
end
fclose(fid);

fid=fopen(npplfile,'w');
fprintf(fid,'# ASCII data info: columns\n');
fprintf(fid,'# 1. region id 2. number of climates,\n');
fprintf(fid,'# 3..n dynamic-npp_Lieth\n');
fprintf(fid,'# Version info: %s\n',struct2stringlines(v));

for ireg=1:nreg 
    fprintf(fid,'%04d %03d',ireg,nclim);
    fprintf(fid,' %d',round(climate.nppl(ireg)));
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
        fprintf(fid,' %d',round(climate.gdd(ireg)));
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



 

asdf
