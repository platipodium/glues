function write_arveregion_biome4(varargin)

cl_register_function();


%% Read popregions file
% arvelat is -89.xx .. 89.xx
% arvelon is -179.xx .. 179.xx (col=lat)
% size arveregion is 4320 x 2160 (row=lon)

file='/h/lemmen/projects/glues/tex/2010/holopop/arve/popregions6.nc';
ncid=netcdf.open(file,'NC_NOWRITE');
varid=netcdf.inqVarID(ncid,'z');
region=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'lat');
lat=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'lon');
lon=netcdf.getVar(ncid,varid);
netcdf.close(ncid);

%% Region region names
file='/h/lemmen/projects/glues/tex/2010/holopop/arve/pop_region_key2.txt';
fid=fopen(file,'r');
C=textscan(fid,'%d %s');
fclose(fid);
arveid=C{1};
arvename=C{2};
arvename{999}='Not_named';
arveid(999)=0;

file='/h/lemmen/projects/glues/tex/2010/holopop/arve/biome4out.nc';
ncid=netcdf.open(file,'NC_NOWRITE');
varid=netcdf.inqVarID(ncid,'npp');
npp=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'gdd0');
gdd0=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'gdd5');
gdd5=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'lat');
blat=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'lon');
blon=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'time');
month=netcdf.getVar(ncid,varid);
netcdf.close(ncid);

prefix='biome4';

%% For each ARVE region find cells and read GLUES
ar=unique(arveregion);
nland=sum(sum(arveregion>0));
nwater=sum(sum(arveregion<0));

ar=ar(ar>0);
nar=length(ar);
[narow,nacol]=size(arveregion);






for i=1:nar
  
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



 
