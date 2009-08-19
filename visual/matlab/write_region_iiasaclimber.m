function write_region_iiasaclimber(varargin)

cl_register_function();

nreg=685;

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

climberfile=['region_climber_' num2str(nreg) '.mat'];
iiasafile=strrep(climberfile,'climber','iiasa');

if ~exist(climberfile,'file') 
 error('Climber data not found ');
end

if ~exist(iiasafile,'file') 
 error('IIASA data not found ');
end

load(climberfile);
iiasa=load(iiasafile);

debug=0;
ref=23;
nclim=23;

climate.npp(isnan(climate.npp))=0;
climate.gdd(isnan(climate.gdd))=0;

climate.npp=climate.npp+repmat(iiasa.climate.npp-climate.npp(:,ref),1,nclim);
climate.gdd=climate.gdd+repmat(iiasa.climate.gdd-climate.gdd(:,ref),1,nclim);


matfile=['region_iiasaclimber_' num2str(nreg) '.mat'];
nppfile=['region_iiasaclimber_npp_' num2str(nreg) '.tsv'];
gddfile=strrep(nppfile,'npp','gdd');

save('-v6',matfile,'climate');

v=get_version;
fid=fopen(nppfile,'w');
fprintf(fid,'# ASCII data info: columns\n');
fprintf(fid,'# 1. region id 2. number of climates,\n');
fprintf(fid,'# 3..n dynamic-npp\n');
fprintf(fid,'# Version info: %s\n',struct2stringlines(v));

nreg=length(climate.npp);
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



 

