function clp_region_climate(varargin)

%% Standard arguments block
cl_register_function;

arguments = {...
  {'file','../../data/plasim_LSG_6999_6000_mean.nc'},...
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

%save(matfile,'climate');

%% input from text files
for i=1:nnames
  txtfile=strrep(file,'.nc',['_' num2str(nreg) '_' names{i} '.tsv']);
  fid=fopen(txtfile,'r');
  c = textscan(fid,'%04d %03d %.2f\n','CommentStyle','#');
  reg.(names{i})=c{3};
  fclose(fid);
end

for i=1:nnames
  figure(i); clf reset; 
  subplot(2,1,1);
  m_proj('equidistant'); hold on;
  m_coast;
  m_grid;
  
  m_pcolor(lon,lat,double(climate.(names{i}))');
  %shading interp;
  cmap=colormap(jet);
  cb=colorbar;
  ylimit=get(cb,'YLim');
  val=reg.(names{i})
  rcolor=floor((val-min(val))./(max(val)-min(val)).*(64-1)+1);
  
  subplot(2,1,2);
  m_proj('equidistant'); hold on;
  m_coast;
  m_grid;
  for ireg=1:nreg
  % select all cells of this region
  
    [map.ilon,map.ilat]=find(map.region==region(ireg));
  
    % Project this grid on the climate grid
    %map.ilon=ceil(map.ilon*1.0*length(lon)/map.nlon);
    %map.ilat=ceil(map.ilat*1.0*length(lat)/map.nlat);
    [uirc,iirc,jirc]=unique([map.ilon map.ilat],'rows');
    m_plot(map.longrid(uirc(:,1)),map.latgrid(uirc(:,2)),'d','color',cmap(rcolor(ireg),:),'MarkerSize',0.2);
    %m_line(map.longrid(uirc(:,1)),map.latgrid(uirc(:,2)),'color','k');
  end
end

return; 
end


