function write_region_hyde(varargin)

cl_register_function();

matfile='regionmap_685.mat';

climatefile='hyde.mat';

if ~exist(climatefile,'file') 
  warning('No database information found / %s missing.',climatefile);
  return
else
  load(climatefile);
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
cropfile=[strrep(prefix,'map','_hyde_crop') '.tsv'];
grasfile=[strrep(prefix,'map','_hyde_gras') '.tsv'];

popcfile=[strrep(prefix,'map','_hyde_popc') '.tsv'];
popdfile=[strrep(prefix,'map','_hyde_popd') '.tsv'];

climatefile=[strrep(prefix,'map','_hyde') '.mat'];

load(matfile);
region.length=regionlength;
land.map=regionindex;
land.region=regionnumber;
land.lon=lon;
land.lat=lat;
nreg=length(region.length);
map.region=regionmap;
[cols,rows]=size(map.region);

nclim=length(hyde.cropfraction);
climate.crop=zeros(nreg,nclim);
climate.gras=climate.crop;
climate.popc=climate.crop;
climate.popd=climate.crop;

debug=0;

[stime,isort]=sort(hyde.time);

for ireg=1:nreg
  % select all cells of this region
  
  
  iselect=find(land.region == ireg);
  nselect=length(iselect);
  if nselect<1 error('Something is wrong here, no cells with region'); end

  [ilon,ilat]=regidx2geoidx(land.map(iselect),cols);
  %% TODO here
  iclon=ceil(ilon/cols*length(hyde.lon));
  iclat=ceil((ilat)/rows*length(hyde.lat));
  
  rcrop=zeros(region.length(ireg),nclim)-NaN;
  rgras=rcrop;
  
  for iclim=1:nclim
      climate.gras(ireg,iclim)=calc_geo_mean(land.lat(iselect),diag(double(hyde.pasturefraction{isort(iclim)}(iclon,iclat))));
      climate.crop(ireg,iclim)=calc_geo_mean(land.lat(iselect),diag(double(hyde.cropfraction{isort(iclim)}(iclon,iclat))));
      climate.popc(ireg,iclim)=calc_geo_mean(land.lat(iselect),diag(double(hyde.populationcount{isort(iclim)}(iclon,iclat))));
      climate.popd(ireg,iclim)=calc_geo_mean(land.lat(iselect),diag(double(hyde.populationdensity{isort(iclim)}(iclon,iclat))));
  end  
  
end

save('-v6',climatefile,'climate');

v=cl_get_version;
fid=fopen(cropfile,'w');
fprintf(fid,'# ASCII data info: columns\n');
fprintf(fid,'# 1. region id 2. number of entries,\n');
fprintf(fid,'# 3..n dynamic-crop\n');
fprintf(fid,'# Version info: %s\n',struct2stringlines(v));

climate.crop(isnan(climate.crop))=0;
climate.gras(isnan(climate.gras))=0;

for ireg=1:nreg 
    fprintf(fid,'%04d %5d',ireg,nclim);
    for iclim=1:nclim
        fprintf(fid,' %d',round(climate.crop(ireg,iclim)));
    end
    fprintf(fid,'\n');
end
fclose(fid);

fid=fopen(grasfile,'w');
fprintf(fid,'# ASCII data info: columns\n');
fprintf(fid,'# 1. region id 2. number of entries \n');
fprintf(fid,'# 4..n dynamic-gras\n');
fprintf(fid,'# Version info: %s\n',struct2stringlines(v));

for ireg=1:nreg 
    fprintf(fid,'%04d %5d',ireg,nclim);
    for iclim=1:nclim
        fprintf(fid,' %d',round(climate.gras(ireg,iclim)));
    end
    fprintf(fid,'\n');
end
fclose(fid);


fid=fopen(popcfile,'w');
fprintf(fid,'# ASCII data info: columns\n');
fprintf(fid,'# 1. region id 2. number of entries \n');
fprintf(fid,'# 4..n population count\n');
fprintf(fid,'# Version info: %s\n',struct2stringlines(v));

for ireg=1:nreg 
    fprintf(fid,'%04d %5d',ireg,nclim);
    for iclim=1:nclim
        fprintf(fid,' %d',round(climate.popc(ireg,iclim)));
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



 

