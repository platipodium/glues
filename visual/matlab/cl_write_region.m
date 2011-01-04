function cl_write_region(varargin)

%% Standard arguments block
cl_register_function;

arguments = {...
  {'file','../../data/biome4.nc'},...
  {'timelim',[-inf inf]}
};

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end


%% Read data file
[time,lon,lat,climate]=cl_nc_read_climate('file',file);
names=fieldnames(climate);
nnames=length(names);

% In glues, the latitudes are from N to S, i.e. descending
%  if lat(2)>lat(1)
%    lat=flipud(lat);
%    latdim=find(size(climate.(names{1}))==length(lat));
%    for iname=1:nnames
%      climate.(names{i})=flipdim(climate.(names{i}),latdim);
%    end
%  end


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
if size(map.latgrid,1)==1 map.latgrid=map.latgrid'; end
if size(map.longrid,1)==1 map.longrid=map.longrid'; end
    
nreg=length(region);

%nreg=10;
for ireg=1:nreg
  % select all cells of this region
    
  
  [map.ilon,map.ilat]=find(map.region==region(ireg));
  fprintf('%d %d %d',ireg,region(ireg),length(map.ilon));
  
  % Project this grid on the climate grid
  ilon=ceil(map.ilon*1.0*length(lon)/map.nlon);
  ilat=ceil(map.ilat*1.0*length(lat)/map.nlat);
  if (lat(2)>lat(1)) ilat=length(lat)+1-ilat; end
  [uirc,iirc,jirc]=unique([ilon ilat],'rows');
  nirc=size(uirc,1);
  hirc=hist(jirc,nirc);
  hirc=reshape(hirc,size(jirc));
  
  fprintf(' %d',length(uirc));
  %if strfind(mapfile,'popregion') & length(map.ilon)>10000 continue; end

  for i=1:nnames
    varvalue=double(climate.(names{i}));
    varvalue=diag(varvalue(uirc(:,1),uirc(:,2)));
    if strmatch(names{i},{'biome','npp','gdd','gdd0','gdd5',...
      'natural_fertility','suitable_species','prec'})
      ivalid=find(varvalue>=0 & isfinite(varvalue));
    else
      ivalid=find(isfinite(varvalue));
    end
    
    if isempty(ivalid)
     warning('No corresponding grid cell found');
    end
    
    weight=cosd(lat(uirc(ivalid,2))).*hirc(ivalid);
    sweight=sum(weight);
    meanval=sum(weight.*varvalue(ivalid))/sweight;
    
    %out.(names{i})(ireg)=calc_geo_mean(map.latgrid(map.ilat),varvalue(map.ilon,map.ilat));
    out.(names{i})(ireg)=meanval;
  end
  
  debug=0;
  if debug
    figure(1); clf reset;
     m_proj('miller','lat',[min(lat(ilat))-5 max(lat(ilat))+5],...
         'lon',[min(lon(ilon))-5 max(lon(ilon))+5]);
%    m_proj('miller');
    m_grid;
    hold on;
    m_coast;
    m_pcolor(map.longrid(unique(map.ilon)),map.latgrid(unique(map.ilat)),double(map.region(unique(map.ilon),unique(map.ilat)))'); 
    m_pcolor(lon(unique(ilon)),lat(unique(ilat)),double(climate.npp(unique(ilon),unique(ilat)))'); 
    shading interp;
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


