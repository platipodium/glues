%% Read plasim for Africa
t=[0:50:4000];
nt=length(t);

lonlim=[-30,60];
latlim=[-40,45];

%lonlim=[-90,90];
%latlim=[-180,180];


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

ilat=find(lat>=latlim(1) & lat<=latlim(2));
ilon=find(lon>=lonlim(1) & lon<=lonlim(2));

fdir='/Users/lemmen/projects/zimbabwe/netlogo/data';

for i=1:nt
  j=find(year==1950-t(i));

  w.data=mean(squeeze(temp(ilon,ilat,:,j)),3);
  w.data=fliplr(w.data);
  w.lat=lat(ilat);
  w.lon=lon(ilon);
  p.data=sum(squeeze(prec(ilon,ilat,:,j)),3);
  p.data=fliplr(p.data);
  p.lat=lat(ilat);
  p.lon=lon(ilon);
  cl_write_arcgis_asc(w,'file',fullfile(fdir,sprintf('plasim_11k_africa_temperature_%04dBP.asc',t(i))),'nodata',-99,'xtype','float');
  cl_write_arcgis_asc(p,'file',fullfile(fdir,sprintf('plasim_11k_africa_precipitation_%04dBP.asc',t(i))),'nodata',-99,'xtype','float');
 
end

for i=1:-10
 % p=cl_read_arcgis_asc('file',fullfile(fdir,sprintf('plasim_11k_africa_precipitation_%04dBP.asc',t(i))),'noprint',0);
  w=cl_read_arcgis_asc('file',fullfile(fdir,sprintf('plasim_11k_africa_temperature_%04dBP.asc',t(i))),'noprint',0);
  m_coast;
end




%% Plot plasim for Zimbabwe
lonlim=[23.8,34.6];
latlim=[-23.8,-14.2];
timelim=[-2000 2000];
clp_nc_plasim('latlim',latlim,'lonlim',lonlim,'timelim',timelim);
cl_print('name','../plots/plasim/plasim_overview_zimbabwe','ext',{'pdf','png'});


%% Plot three continental scenarios of farming timing
[d,b]=clp_nc_variable('reg','afr','timelim',[-5000 1500],'threshold',0.5,'file','../../eurolbk_base.nc');
[d,b]=clp_nc_variable('reg','afr','timelim',[-5000 1500],'threshold',0.5,'file','../../eurolbk_nospread.nc');
[d,b]=clp_nc_variable('reg','afr','timelim',[-5000 1500],'threshold',0.5,'file','../../eurolbk_events.nc');


%% Zimbabwe
[d,b]=clp_nc_variable('reg','zim','timelim',[-4000 -1000],'threshold',0.5,'file','../../eurolbk_events.nc');

load('../../data/naturalearth/10m_admin_0_countries.mat');
for i=1:length(shape)
    if strmatch(shape(i).SOVEREIGNT,'Zimbabwe') ipak=i; break; end
end
plat=shape(ipak).Y;
plon=shape(ipak).X;

m_plot(plon,plat,'r-');

[d,b]=clp_nc_trajectory('reg','zim','var','population_density','timelim',[-4000 -1000],0.5,'file','../../eurolbk_events.nc');
