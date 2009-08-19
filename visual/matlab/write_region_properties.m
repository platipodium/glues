function write_region_properties(varargin)

cl_register_function();

matfile='regionborders_686.mat';

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

pathfile=strrep(matfile,'map','path');
if ~exist(matfile,'file') return; end

datfile=strrep(matfile,'.mat','');
datfile=strrep(datfile,'borders','stat');
txtfile=[datfile,'.txt'];
tsvfile=[datfile '.tsv'];

load(matfile);
load(pathfile);
nreg=region.nreg;

ilat=round(180-2*region.lat);
ilon=round(360+2*region.lon);

fid=fopen(tsvfile,'w','ieee-le');
for ireg=1:nreg 
    nneigh=region.neighbours(ireg);
    %fprintf(fid,'%05d %5d %7d %7.2f %6.2f %3d',ireg,round(region.length(ireg)),round(region.area(ireg)),...
    %    region.lon(ireg),region.lat(ireg),nneigh);
    fprintf(fid,'%05d %5d %7d %4d %4d %3d',ireg,round(region.length(ireg)),round(region.area(ireg)),...
    ilon(ireg),ilat(ireg),nneigh);
    for ineigh=1:nneigh
        
        fprintf(fid,'\t%d:%d:%d',region.neighbourhood(ireg,ineigh),round(region.borders(ireg,ineigh,1:2)));
    end
    fprintf(fid,'\n');
end
fclose(fid);

v=get_version;
fid=fopen(txtfile,'w');
fprintf(fid,'ASCII data info: columns\n');
fprintf(fid,'1. region id 2. number of cells, 3. area in sqkm\n');
fprintf(fid,'4. lon 5. lat  6. number of neighbours\n');
fprintf(fid,'Further columns neighbour id:length of border (km)\n');
fprintf(fid,'Version info: %s',struct2stringlines(v));
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



 

