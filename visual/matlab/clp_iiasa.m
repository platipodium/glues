function clp_iiasa
%CLP_IIASA plots iiasa data and derivatives
%   CLP_IIASA plots annual mean precip and temperature from the IIASA
%   database, furthermore, npp and gdd are shown as well.
%
%   This function requires the m_map toolbox
%
%   See also CL_READ_IIASA
%
% Copyright 2009 Carsten Lemmen <carsten.lemmen@gkss.de>

cl_register_function;

[d,f]=get_files;

matfile='iiasa.mat';
if ~exist(matfile,'file')
  cl_read_iiasa;
end

iiasa=load(matfile);

prec=sum(iiasa.prec,2);
temp=mean(iiasa.tmean,2);
[gdd,gdd0,gdd5]=clc_gdd(iiasa.tmean);
%=30*sum(iiasa.tmean>0,2);
npp=cl_npp_lieth(temp,prec);

lon=iiasa.lon;
lat=iiasa.lat;
latlim=[-58,80];


figure(1);
clf reset;
m_proj('Miller','lat',latlim);
m_grid;
m_coast;
hold on;
m_plot(lon,lat,'r.');


ilon=(iiasa.lon+0.25)/0.5+360;
ilat=(iiasa.lat+0.25)/0.5+180;

nlon=720;
nlat=360;

lon=[1:nlon]/2-180.25;
lat=[1:nlat]/2-90.25;

nmap=zeros(nlon,nlat)-NaN;
gmap=nmap;
gmap0=nmap;
gmap5=nmap;

for i=1:nlat
   j=find(ilat==i);
   if isempty(j) continue; end
   
   nmap(ilon(j),i)=npp(j);
   gmap(ilon(j),i)=gdd(j);
   gmap0(ilon(j),i)=gdd0(j);
   gmap5(ilon(j),i)=gdd5(j);
end
latlimits=[-58,80];

   
figure(1);
clf reset;
m_proj('Miller','lat',latlimits);
hold on;
set(gcf,'position',[692   641   560   271]);
m_pcolor(lon,lat,nmap')
set(gca,'clim',[0 1500]);
shading flat;
m_coast; m_grid; colorbar('Ylim',[0,1500]);
title('IIASA NPP (Lieth)');
plot_multi_format(gcf,fullfile(d.plot,['iiasa_npp']));
hold off;

%%
figure(2);
clf reset;
m_pcolor(lon,lat,gmap0');
hold on;
set(gca,'clim',[0 3000]);
shading flat;
m_coast; m_grid; colorbar('Ylim',[0,3000]);
title('IIASA GDD_0');
plot_multi_format(gcf,fullfile(d.plot,['iiasa_gdd0']));

%%
figure(3);
clf reset;
m_pcolor(lon,lat,gmap5');
hold on;
set(gca,'clim',[0 3000]);
shading flat;
m_coast; m_grid; colorbar('Ylim',[0,3000]);
title('IIASA GDD_5');
plot_multi_format(gcf,fullfile(d.plot,['iiasa_gdd5']));


figure(4);
clf reset;
m_pcolor(lon,lat,gmap');
hold on;
set(gca,'clim',[0 360]);
shading flat;
m_coast; m_grid; colorbar('Ylim',[0,360]);
title('IIASA GDD');
plot_multi_format(gcf,fullfile(d.plot,['iiasa_gdd']));

return
end
