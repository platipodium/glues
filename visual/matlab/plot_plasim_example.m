function plot_plasim_example

cl_register_function();

m=[1:12];

[d,f]=get_files;

ncfile='plasim_klima.nc';
matfile=strrep(ncfile,'nc','mat');

if ~exist(matfile,'file')

  ncid=netcdf.open(ncfile,'NC_NOWRITE');
  [ndim nvar natt udimid] = netcdf.inq(ncid);

% Copy variables
for ivar=0:nvar-1
  [varname,xtype,dimids,natt] = netcdf.inqVar(ncid,ivar);
  data=netcdf.getVar(ncid,ivar);
  switch(varname)
    case 'time',time = double(data);
    case 'P', precip=double(data);
    case 'T', temp=double(data);
    case 'NPP', npp=double(data)*3E3;
  end
end
netcdf.close(ncid);
save('plasim_klima','time','precip','temp','npp');

else
  load(matfile);
end

npp=sum(npp,3)*1000;

nlon=size(temp,1);
nlat=size(temp,2);


lon=[0:nlon-1]/nlon*360-180/nlon;

lon1=find(lon<=180);
lon2=find(lon>180);

lon=[lon(lon2)-360 lon(lon1)];

%lon(lon2)=lon(lon2)-360;
temp=[ temp(lon2,:,:);temp(lon1,:,:) ];
precip=[ precip(lon2,:,:); precip(lon1,:,:) ];
npp=[ npp(lon2,:,:);npp(lon1,:,:) ];
npp(find(npp<=0))=NaN;


lat=[0:nlat-1]/nlat*180-90+90/nlat;
lat=fliplr(lat);
latlimits=[-58,80];

figure(1);
clf reset;
m_proj('Miller','lat',latlimits);
set(gcf,'position',[692   641   560   271]);


mtemp=mean(temp,3);
anpp=sum(npp,3);
aprecip=sum(precip,3);
lnpp=vecode_npp_lieth(mtemp,aprecip);
gdd=sum(temp>12,3)*30;

lnpp(find(isnan(npp)))=NaN;
m_pcolor(lon,lat,double(lnpp'));
shading flat;
hold on;
set(gca,'clim',[0 1500]);
m_coast; m_grid; colorbar('Ylim',[0,1500]);
title('PlaSim CTRL NPP (Lieth)');
plot_multi_format(gcf,fullfile(d.plot,'plasim',['plasim_example_lnpp']));
hold off;

m_pcolor(lon,lat,double(npp'))
hold on;
set(gca,'clim',[0 1500]);
shading flat;
m_coast; m_grid; colorbar('Ylim',[0,1500]);
title('PlaSim CTRL NPP');
plot_multi_format(gcf,fullfile(d.plot,'plasim',['plasim_example_npp']));
hold off;

m_pcolor(lon,lat,double(gdd'));
hold on;
set(gca,'clim',[0 360]);
shading flat;
m_coast; m_grid; colorbar('Ylim',[0,360]);
title('PlaSim CTRL GDD_0');
plot_multi_format(gcf,fullfile(d.plot,'plasim',['plasim_example_gdd']));

hold off;
m_pcolor(lon,lat,double(mtemp'));
hold on;
shading flat;
m_coast; m_grid; colorbar;
title('PlaSim CTRL mean annual temperature');
plot_multi_format(gcf,fullfile(d.plot,'plasim',['plasim_example_temp']));
hold off;

m_pcolor(lon,lat,double(aprecip'));
hold on;
m_coast; m_grid; colorbar;
shading flat;
title('PlaSim CTRL annual precipitation');
plot_multi_format(gcf,fullfile(d.plot,'plasim',['plasim_example_precip']));
hold off;


return
end
