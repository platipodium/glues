function cl_write_region(varargin)

%% Standard arguments block
cl_register_function;

arguments = {...
  {'file','../../data/iiasa.nc'},...
  {'timelim',[-inf inf]}
};

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end


%% Read data file
[time,lon,lat,climate]=cl_nc_read_climate('file',file);



%% Read glues mapping file
if (1)
mapfile='regionmap_sea_685.mat';
if ~exist(mapfile,'file') return; end

  load(mapfile);
  map.nlon=720; map.nlat=360;
  map.region=zeros(map.nlon,map.nlat);
  for i=1:length(land.region)
    map.region(land.ilon(i),land.ilat(i))=land.region(i);
  end
  
else 
  mapfile='../../data/popregions6.nc'; 
  ncid=netcdf.open(mapfile,'NOWRITE');
  varid=netcdf.inqVarID(ncid,'lat');
  map.latgrid=netcdf.getVar(ncid,varid);
  varid=netcdf.inqVarID(ncid,'lon');
  map.longrid=netcdf.getVar(ncid,varid);
  varid=netcdf.inqVarID(ncid,'z');
  map.region=netcdf.getVar(ncid,varid);
  [map.nlon map.nlat]=size(map.region);
end
region=unique(map.region(map.region>0));
nreg=length(region);

names=fieldnames(climate);
nnames=length(names);

%nreg=10;
for ireg=1:nreg
  % select all cells of this region
    
  
  [map.ilon,map.ilat]=find(map.region==region(ireg));
  fprintf('%d %d %d',ireg,region(ireg),length(map.ilon));
  
  % Project this grid on the climate grid
  map.ilon=ceil(map.ilon*1.0*length(lon)/map.nlon);
  map.ilat=ceil(map.ilat*1.0*length(lat)/map.nlat);
  [uirc,iirc,jirc]=unique([map.ilon map.ilat],'rows');
  nirc=size(uirc,1);
  hirc=hist(jirc,nirc);
  
  fprintf(' %d',length(uirc));
  %if strfind(mapfile,'popregion') & length(map.ilon)>10000 continue; end

  for i=1:nnames
    varvalue=double(climate.(names{i}));
    
    weight=cosd(map.latgrid(uirc(:,2))).*hirc';
    sweight=sum(weight);
    meanval=sum(weight.*diag(varvalue(uirc(:,1),uirc(:,2))))/sweight;
    
    %out.(names{i})(ireg)=calc_geo_mean(map.latgrid(map.ilat),varvalue(map.ilon,map.ilat));
    out.(names{i})(ireg)=meanval;
  end
  
  %if mod(ireg,2)==1 
      fprintf('\n'); 
  %end
end

climate=out;

%% prepare output names
matfile=strrep(file,'.nc',['_' num2str(nreg) '.mat']);
save(matfile,'climate');

%% output to text files
v=cl_get_version;
nclim=1;
for i=1:nnames
  txtfile=strrep(file,'.nc',['_' num2str(nreg) '_' names{i} '.tsv']);
  fid=fopen(txtfile,'w');
  fprintf(fid,'# ASCII data info: columns\n');
  fprintf(fid,'# 1. region id 2. number of climates,\n');
  fprintf(fid,'# 3..n annual %s\n',names{i});
  fprintf(fid,'# Version info: %s\n',struct2stringlines(v));

  for ireg=1:nreg 
    fprintf(fid,'%04d %03d',ireg,nclim);
    fprintf(fid,' %.2f',climate.(names{i})(ireg));
    fprintf(fid,'\n');
  end
  fclose(fid);
end


return; 
end


