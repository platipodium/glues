function cl_check_nc_neighbours(varargin)


cl_register_function;

[regs,nreg,~,~]=find_region_numbers('all');

file='../../src/test/regions_11k_685.nc';
if ~exist(file,'file')
    error('File does not exist');
end
ncid=netcdf.open(file,'NC_NOWRITE');

region=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'region'));
neigh=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'region_neighbour'));
nneigh=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'number_of_neighbours'));
lat=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lat'));
lon=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lon'));
ncell=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'number_of_gridcells'));
cells=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'gridcells'))';
netcdf.close(ncid);

file='../../src/test/regions_11k.nc';
if ~exist(file,'file')
    error('File does not exist');
end
ncid=netcdf.open(file,'NC_NOWRITE');
latit=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lat'));
lonit=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lon'));
mapid=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'map_id'));
netcdf.close(ncid);

figure(1); 
clf reset;
set(gcf,'DoubleBuffer','on');    
set(gcf,'PaperType','A4');
hold on;

seacolor=0.7*ones(1,3);
landcolor=0.8*ones(1,3); 

nreg=length(region);

for i=1:nreg
    
  ic=find(cells(i,:)>0);
  rlon=lonit(cells(i,ic));
  rlat=latit(cells(i,ic));
  fprintf('%d %d %f|%f %d\n',i,ncell(i),mean(rlon),mean(rlat),nneigh(i));
  %fprintf('%d %d %f|%f %d\n',i,ncell(i),lon(i),lat(i),nneigh(i));
end

for i=1:-nreg
    
  clf reset;
  ic=find(cells(i,:)>0);
  % Verify:
  if  any(mapid(cells(i,ic))~=i) fprintf('Something wrong with region %d\n',i); end 

  rlon=lonit(cells(i,ic));
  rlat=latit(cells(i,ic));
  % Now plot
  lonlim=[min(rlon)-10 max(rlon)+10];
  latlim=[min(rlat)-10 max(rlat)+10];

  pb=clp_basemap('lon',lonlim,'lat',latlim);
  m_coast('patch',landcolor);
  c=get(gca,'Children');
  ipatch=find(strcmp(get(c(:),'Type'),'patch'));
  npatch=length(ipatch);
  if npatch>0
    iwhite=find(sum(cell2mat(get(c(ipatch),'FaceColor')),2)==3);
    if ~isempty(iwhite) set(c(ipatch(iwhite)),'FaceColor',seacolor); end
  end

  m_plot(rlon,rlat,'r.');
  m_plot(mean(rlon),mean(rlat),'b.','MarkerSize',10);

  
  cmap=colormap(jet(nneigh(i)));
  
  for j=1:nneigh(i)
    n=neigh(i,j);
    if n<1 continue; end
    in=find(cells(n,:)>0);
    nlon=lonit(cells(n,in));
    nlat=latit(cells(n,in));
    m_plot(nlon,nlat,'k.','color',cmap(j,:));
  end
  hold off;
  
end

end















