function plot_iiasa

cl_register_function();

[d,f]=get_files;

matfile='iiasa.mat';

iiasa=load(matfile);


prec=sum(iiasa.prec,2);
temp=mean(iiasa.tmean,2);
gdd=30*sum(iiasa.tmean>0,2);
npp=cl_npp_lieth(temp,prec);

ilon=(iiasa.lon+0.25)/0.5+360;
ilat=(iiasa.lat+0.25)/0.5+180;

nlon=720;
nlat=360;

nmap=zeros(nlon,nlat)-NaN;
gmap=nmap;

for i=1:nlat
   j=find(ilat==i);
   if length(j)<1 continue;
   
   nmap(ilon,i)=npp(j);
   gmap(ilon,i)=gdd(j);
end

lon=[1:nlon]/2-180.25;
lat=[1:nlat]/2-90.25;
latlimits=[-58,80];

   
figure(1);
clf reset;
m_proj('Miller','lat',latlimits);
set(gcf,'position',[692   641   560   271]);

m_pcolor(lon,lat,nmap')
hold on;
set(gca,'clim',[0 1500]);
shading flat;
m_coast; m_grid; colorbar('Ylim',[0,1500]);
title('IIASA NPP (Lieth)');
plot_multi_format(gcf,fullfile(d.plot,['iiasa_npp']));
hold off;

m_pcolor(lon,lat,gmap');
hold on;
set(gca,'clim',[0 360]);
shading flat;
m_coast; m_grid; colorbar('Ylim',[0,360]);
title('IIASA GDD_0');
plot_multi_format(gcf,fullfile(d.plot,['iiasa_gdd']));

return
end
