function write_region_climber(varargin)

cl_register_function();

matfile='regionmap_686.mat';

climatefile='climber.mat';

if ~exist(climatefile,'file') 
  warning('No climate change information found / %s missing. writing static climate',climatefile);
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
nppfile=[strrep(prefix,'map','_climber_npp') '.tsv'];
gddfile=[strrep(prefix,'map','_climber_gdd') '.tsv'];

load(matfile);
nreg=length(region.length);
[cols,rows]=size(map.region);

climber.gdd=squeeze(sum(climber.temp>0,2))*30.;
climber.npp=squeeze(climber.npp(:,1,:,:));

nclim=size(climber.npp,1);
climate.npp=zeros(nreg,nclim);
climate.gdd=climate.npp;

for ireg=1:nreg
  % select all cells of this region
  iselect=find(land.region == ireg);
  nselect=length(iselect);
  if nselect<1 error('Something is wrong here, no cells with region'); end
  [ilon,ilat]=regidx2geoidx(land.map(iselect),cols);
  iclon=ceil(ilon/cols*length(climber.lon));
  w=cosd(map.latgrid(361-ilat));
  iclat=ceil((361-ilat)/rows*length(climber.lat));
  rnpp=1000*squeeze(climber.npp(:,iclon,iclat));
  rgdd=climber.gdd(:,iclon,iclat);
  valid=[];
  for i=1:length(ilat)
    if ~isnan(rnpp(1,i,i))
      climate.npp(ireg,:)=climate.npp(ireg,:)+w(i)*rnpp(:,i,i)';
      climate.gdd(ireg,:)=climate.gdd(ireg,:)+w(i)*rgdd(:,i,i)';
     valid=[valid,i];
    end
  end
  
  climate.npp(ireg,:)=climate.npp(ireg,:)/sum(w(valid));
  climate.gdd(ireg,:)=climate.gdd(ireg,:)/sum(w(valid));
end

save('-v6','regionclimate_686','climate');

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



 

