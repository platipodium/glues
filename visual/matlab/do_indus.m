%% Read plasim for Indus

latlim=[20,40];
lonlim=[60,80];

%lonlim=[-90,90];
%latlim=[-180,180];



file='/Users/lemmen/devel/glues/data/glues_map.nc';
ncid=netcdf.open(file,'NC_NOWRITE');

[ndim nvar natt udimid] = netcdf.inq(ncid); 
for varid=0:nvar-1
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
  if strcmp(varname,'lat') lat=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'lon') lon=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'region') region=netcdf.getVar(ncid,varid); end
end
netcdf.close(ncid);


% Resample dataset
res=0.5
xi=[lonlim(1):res:lonlim(2)]';
yi=[latlim(1):res:latlim(2)];
zi = interp2(lon,lat,region',xi,yi,'nearest'); 
zi=flipud(zi);

ilat=find(yi>=latlim(1) & yi<=latlim(2));
ilon=find(xi>=lonlim(1) & xi<=lonlim(2));

fdir='/Users/lemmen/projects/indus/netlogo/data';

w.data=zi(ilat,ilon);
w.lat=yi(ilat);
w.lon=xi(ilon);

cl_write_arcgis_asc(w,'file',fullfile(fdir,'glues_regions.asc'),'nodata',0,'xtype','int');

w=cl_read_arcgis_asc('file',fullfile(fdir,'glues_regions.asc'),'noprint',0);
m_coast;


file='../../data/plasim_11k.nc';
ncid=netcdf.open(file,'NC_NOWRITE');

[ndim nvar natt udimid] = netcdf.inq(ncid); 
for varid=0:nvar-1
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
  if strcmp(varname,'lat') lat=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'lon') lon=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'time') time=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'lsp') prec=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'t2') temp=netcdf.getVar(ncid,varid); end
end
netcdf.close(ncid);

nlat=length(lat);
nlon=length(lon);
nmonth=12;
ntime=length(time);
nyear=ntime/nmonth;

time=reshape(time,[nmonth nyear]);
monthlen=[time(2:12,1)-time(1:11,1); 31];
toffset=time(1,1);

year=-9000:50:1950;
month=1:12;
temp=temp-273.15;

prec=reshape(prec,[nlon nlat nmonth nyear]);
temp=reshape(temp,[nlon nlat nmonth nyear]);
lon(lon>180)=lon(lon>180)-360;
[lon,sortlon]=sort(lon);
prec=prec(sortlon,:,:,:);
temp=temp(sortlon,:,:,:);


fdir='/Users/lemmen/projects/indus/netlogo/data';

for j=1:length(year)

  
  z=mean(squeeze(temp(:,:,:,j)),3);
  z=fliplr(z);
  zi = interp2(lon,lat,z',xi,yi,'nearest'); 
  
  w.data=zi(ilat,ilon);
  w.lat=yi(ilat);
  w.lon=xi(ilon);
  
  
  z=sum(squeeze(prec(:,:,:,j)),3);
  z=fliplr(z);
  zi = interp2(lon,lat,z',xi,yi,'nearest'); 
  
  p=w;
  p.data=zi(ilat,ilon);
  
  cl_write_arcgis_asc(w,'file',fullfile(fdir,sprintf('plasim_11k_indus_temperature_%04dBP.asc',1950-year(j))),'nodata',-99.0,'xtype','float');
  cl_write_arcgis_asc(p,'file',fullfile(fdir,sprintf('plasim_11k_indus_precipitation_%04dBP.asc',1950-year(j))),'nodata',-99,'xtype','int');

  %w=cl_read_arcgis_asc('file',fullfile(fdir,sprintf('plasim_11k_indus_temperature_%04dBP.asc',1950-year(j))),'noprint',0);
  %m_coast;

end

for j=1:-10
  w=cl_read_arcgis_asc('file',fullfile(fdir,sprintf('plasim_11k_indus_temperature_%04dBP.asc',1950-year(j))),'noprint',0);
  m_coast;
end


