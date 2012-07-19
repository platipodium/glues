function clp_nc_plasim(varargin)

arguments = {...
  {'latlim',[-inf inf]},...
  {'lonlim',[-inf inf]},...
  {'timelim',[-inf inf]},...
  {'lim',[-inf,inf]},...
  {'variables','all'},...
  {'file','../../data/plasim_11k.nc'},... 
  {'noprint',0}...
};

cl_register_function();

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end

if ~exist(file,'file')
    error('File does not exist');
end
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
latweight=cosd(lat);

ilat=find(lat>=latlim(1) & lat<=latlim(2));
ilon=find(lon>=lonlim(1) & lon<=lonlim(2));
itime=find(year>=timelim(1) & year<=timelim(2));

wtemp=sum(temp(ilon,ilat,:,itime).*repmat(latweight(ilat)',[length(ilon),1,nmonth,length(itime)]),2)/sum(latweight(ilat));
gtemp=squeeze(mean(wtemp,1));
wprec=sum(prec(ilon,ilat,:,itime).*repmat(latweight(ilat)',[length(ilon),1,nmonth,length(itime)]),2)/sum(latweight(ilat));
gprec=squeeze(mean(wprec,1));



if isinf(latlim)
  ilat=1:nlat/2;  
  wtemp=sum(temp(:,ilat,:,:).*repmat(latweight(ilat)',[nlon,1,nmonth,nyear]),2)/sum(latweight(ilat));
  shtemp=squeeze(mean(wtemp,1));

  ilat=nlat/2+1:nlat;
  wtemp=sum(temp(:,ilat,:,:).*repmat(latweight(ilat)',[nlon,1,nmonth,nyear]),2)/sum(latweight(ilat));
  nhtemp=squeeze(mean(wtemp,1));
end
  
aprec=squeeze(sum(prec,3));

figure(1); clf reset;
templim=[5 25];

a1=subplot(3,3,1);
plot(year(itime),mean(gtemp),'r-');
hold on;
plot(year(itime),min(gtemp),'b-');
plot(year(itime),mean(gtemp([1,2,12],:)),'g-');
plot(year(itime),max(gtemp),'b-');
plot(year(itime),mean(gtemp([6,7,8],:)),'g-');
%set(gca,'Xlim',timelim,'Ylim',templim);
title('Global mean monthly temperature ');
%legend('Annual','Coldest/Warmest','Winter/Summer');

if isinf(latlim)
a2=subplot(3,3,2);
plot(year,mean(nhtemp),'r-');
hold on;
plot(year,min(nhtemp),'b-');
plot(year,max(nhtemp),'b-');
plot(year,mean(nhtemp([1,2,12],:)),'g-');
plot(year,mean(nhtemp([6,7,8],:)),'g-');
set(gca,'Xlim',[min(year), max(year)],'Ylim',templim);
title('NH temperature');

a3=subplot(3,3,3);
plot(year,mean(shtemp),'r-');
hold on;
plot(year,min(shtemp),'b-');
plot(year,max(shtemp),'b-');
plot(year,mean(shtemp([1,2,12],:)),'g-');
plot(year,mean(shtemp([6,7,8],:)),'g-');
set(gca,'Xlim',[min(year), max(year)],'Ylim',templim);
title('SH temperature');
else
    
    
% Seasponal cycles    
a1=subplot(3,3,2);
hold on;
cmap=colormap(jet(length(itime)));
for i=1:length(itime)
  plot(month,gtemp(:,i)','r-','color',cmap(i,:));
end
set(gca,'Xlim',[.5 12.5]);
plot(month,mean(gtemp,2),'k-','linewidth',3);
title('Temperature seasonal cycle');

a1=subplot(3,3,3);
hold on;
cmap=colormap(jet(length(itime)));
for i=1:length(itime)
  plot(month,gprec(:,i)','r-','color',cmap(i,:));
end
set(gca,'Xlim',[.5 12.5]);
plot(month,mean(gprec,2),'k-','linewidth',3);
title('Precipitation seasonal cycle');


end

a4=subplot(3,3,4);
plot(year(itime),mean(gprec),'r-');
hold on;
plot(year(itime),min(gprec),'b-');
plot(year(itime),mean(gprec([1,2,12],:)),'g-');
plot(year(itime),max(gprec),'b-');
plot(year(itime),mean(gprec([6,7,8],:)),'g-');
%set(gca,'Xlim',[min(year), max(year)]);
title('Global sum monthly precipitation');

a5=subplot(3,3,5);
plot(year(itime),mean(gtemp),'r.');
hold on;
plot(movavg(year(itime),year(itime),1000),movavg(year(itime),mean(gtemp),1000),'b-','LineWidth',3);
%set(gca,'Xlim',timelim);
title('Global mean annual temperature');

a6=subplot(3,3,6);
plot(year(itime),12*mean(gprec),'r.');
hold on;
plot(movavg(year(itime),year(itime),1000),12*movavg(year(itime),mean(gprec),1000),'b-','LineWidth',3);
%set(gca,'Xlim',timelim);
title('Global sum annual precipitation');


atemp=double(squeeze(mean(temp,3)));
wtemp=double(squeeze(mean(temp(:,:,[1,2,12],:),3)));
stemp=double(squeeze(mean(temp(:,:,[6,7,8] ,:),3)));

if length(ilon)>1 & length(ilat)>1
a7=subplot(3,3,7);
m_proj('equidistant','lat',latlim,'lon',lonlim);
m_coast;
m_grid; %('fancy');
hold on;
it=find(year(itime)>=timelim(1) & year(itime)<=-timelim(1)+1000);
m_pcolor(lon(ilon),lat(ilat),squeeze(mean(atemp(ilon,ilat,it),3))');
shading interp;
set(gca,'CLim',[-30 30]);
title('9k BP annual mean temperature');

a8=subplot(3,3,8);
m_proj('equidistant');
m_coast;
m_grid('fancy');
hold on;
it=find(year(itime)>=mean(timelim)-500 & year(itime)<=mean(timelim)+500);
m_pcolor(lon,lat,squeeze(mean(wtemp(:,:,it),3))');
shading interp;
set(gca,'CLim',[-30 30]);
title('9k BP DJF temperature');

a9=subplot(3,3,9);
m_proj('equidistant');
m_coast;
m_grid('fancy');
hold on;
it=year>=-7500 & year<=-6500;
m_pcolor(lon,lat,squeeze(mean(stemp(:,:,it),3))');
shading interp;
set(gca,'CLim',[-30 30]);
title('9k BP JJA temperature');

else
a7=subplot(3,3,7);
[npp,npp_p,npp_t,lp,lt]=clc_npp(atemp(ilon,ilat,itime),aprec(ilon,ilat,itime))

npp_p=squeeze(mean(mean(npp_p,1),1))
npp_t=squeeze(mean(mean(npp_t,1),1))

iblue=find(npp_p<npp_t);
ired=find(npp_p>=npp_t);
npp=npp_t;
npp(iblue)=NaN;

if ~isempty(ired) plot(year(itime),npp,'r-'); end
npp=npp_p;
npp(ired)=NaN;
hold on;
if ~isempty(iblue) plot(year(itime),npp,'b-'); end

%set(gca,'Xlim',timelim);
title('Net primary productivity');
    
end





return
end