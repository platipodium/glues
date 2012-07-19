function sra2nc(srafile,ncfile)

if ~exist('srafile','var')
  srafile='/h/lemmen/projects/glues/plasim/most16.014/plasim/dat/T21/N032_surf_0174.sra'; % albedo
  %srafile='/h/lemmen/projects/glues/plasim/most16.014/plasim/dat/T21/N032_surf_0173.sra'; % z0
  %srafile='/h/lemmen/projects/glues/plasim/most16.014/plasim/dat/T21/N032_surf_0199.sra'; % forest cover
  %srafile='/h/lemmen/projects/glues/plasim/most16.014/plasim/dat/T21/N032_surf_0212.sra'; % veg cover
end

if ~exist('ncfile','var')
  [d,f,e]=fileparts(srafile);
  ncfile=fullfile('../../data/',[f '.nc']);
end

if ~exist(srafile,'file')
  warning('Surface file %s does not exist',srafile);
  return;
end

if exist(ncfile,'file')
  warning('NetCDF file %s exists.',ncfile);
  return;
end


fid=fopen(srafile,'r');
d=textscan(fid,'%f%f%f%f%f%f%f%f','multipledelimsasone',1);
fclose(fid);

d=cell2mat(d);
iheader=find(~isnan(d(:,8)));
idata=find(isnan(d(:,8)));

header=d(iheader,:);
nmonth=size(header,1);
nlat=header(1,6);
nlon=header(1,5);
data=d(idata,1:4);
nrow=nlat*nlon/4;

for imonth=1:nmonth
  a{imonth}=reshape(data((imonth-1)*nrow+1:imonth*nrow,:)',[nlon,nlat]);
end
x=1:nlon;
y=1:nlat;

figure(1); clf reset;
m_proj('equidistant');
dlon=360/nlon;
dlat=180/nlat;
lon=0+0*dlon/2:360/nlon:360-dlon;
lat=90-dlat/2:-180/nlat:-90+dlat/2;

ishift=find(lon>180);
inoshift=find(lon<=180);
lon=[lon(ishift)-360 lon(inoshift)];

grid=zeros(nmonth,nlon+2,nlat);
for imonth=1:nmonth
  grid(imonth,2:nlon+1,:)=([a{imonth}(ishift,:) ; a{imonth}(inoshift,:) ]);
  grid(imonth,nlon+2,:)=grid(imonth,2,:);
  grid(imonth,1,:)=grid(imonth,nlon+1,:);
end
lon=[-180 lon-0*dlon/2 180];

for imonth=1:nmonth
  m_pcolor(lon,lat,squeeze(grid(imonth,:,:))');
  m_grid;
  m_coast('color','w');
  pause(0.7);
end



