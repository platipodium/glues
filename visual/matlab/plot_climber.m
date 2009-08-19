function plot_climber


cl_register_function();

matfile='climber.mat';


load(matfile);

time=climber.time+2000;


lat=climber.lat;
dlat=abs(lat(1)-lat(2));
lat=lat-dlat/2;

lon=climber.lon;
dlon=abs(lon(1)-lon(2));
lon=lon-dlon/2;

nlon=length(lon);
nlat=length(lat);
ntime=length(time);

gdd=squeeze(sum(climber.temp>0,2)*30);
npp=squeeze(mean(climber.npp,2))*1000;
prec=squeeze(sum(climber.prec,2));
temp=squeeze(mean(climber.temp,2));
nppl=vecode_npp_lieth(temp,prec);

nh=find(lat>0);
[glon,glat]=meshgrid(lon,lat);

nppl(isnan(npp))=NaN;
gdd(isnan(npp))=NaN;

for i=1:ntime
    mnppl(i)=calc_geo_mean(glat(nh,:),squeeze(nppl(i,:,nh))');
    mnpp(i)=calc_geo_mean(glat(nh,:),squeeze(npp(i,:,nh))');
    mgdd(i)=calc_geo_mean(glat(nh,:),squeeze(gdd(i,:,nh))');
end
mnpp=squeeze(mnpp);
mgdd=squeeze(mgdd);


time(find(time==0))=1;

[d,f]=get_files;

latlimits=[-58,80];

figure(1);
clf reset;
m_proj('Miller','lat',latlimits);

[x1,y1]=m_ll2xy(-35,latlimits(1)+5);
[x2,y2]=m_ll2xy(110,-32);

hold on;
m_coast; m_grid;

set(gcf,'position',[692   641   560   271]);

for i=ntime:-1:1
  if time(i)<0 bc='BC'; else bc='AD'; end
  title(sprintf('Climber NPP %4d %s',abs(time(i)),bc));
  p1=m_pcolor(lon,lat,squeeze(npp(i,:,:))');
  set(gca,'clim',[0 1500]);
shading flat;
  a1=gca;
  cb=colorbar;
  set(cb,'Ylim',[0,1500]);
  
  if ~exist('p2','var') 
    p2=plot([x2,x1,x1],[y1,y1,y2],'k-'); 
    p3=plot( (time-min(time))/(max(time)-min(time))*(x2-x1)+x1 ,...
      (mnpp-min(mnpp))/(max(mnpp)-min(mnpp))*(y2-y1)+y1,...
      'm','LineWidth',4); 
    text(x1,y1,num2str(min(round(mnpp))),'color','m','HorizontalAlignment','right');
    text(x1,y2,num2str(max(round(mnpp))),'color','m','HorizontalAlignment','right');
  
  end
  p4=plot((time(i)-min(time))/(max(time)-min(time))*(x2-x1)+x1,...
      (mnpp(i)-min(mnpp))/(max(mnpp)-min(mnpp))*(y2-y1)+y1,...
      'ko','MarkerSize',7,'MarkerFaceColor','y');

  print('-dpng',fullfile(d.plot,'climber',['climber_npp_' sprintf('%3.3d_',i) num2str(abs(time(i))) bc]));
  delete(p1,p4);
end

for i=ntime:-1:1
  if time(i)<0 bc='BC'; else bc='AD'; end
  title(sprintf('Climber NPP (Lieth) %4d %s',abs(time(i)),bc));
  p1=m_pcolor(lon,lat,squeeze(nppl(i,:,:))');
  set(gca,'clim',[0 1500]);
shading flat;
  a1=gca;
  cb=colorbar;
  set(cb,'Ylim',[0,1500]);
  
  if ~exist('p2','var') 
    p2=plot([x2,x1,x1],[y1,y1,y2],'k-');
    p3=plot( (time-min(time))/(max(time)-min(time))*(x2-x1)+x1 ,...
      (mnppl-min(mnppl))/(max(mnppl)-min(mnppl))*(y2-y1)+y1,...
      'm','LineWidth',4);
    text(x1,y1,num2str(min(round(mnppl))),'color','m','HorizontalAlignment','right');
    text(x1,y2,num2str(max(round(mnppl))),'color','m','HorizontalAlignment','right');
  end
  p4=plot((time(i)-min(time))/(max(time)-min(time))*(x2-x1)+x1,...
      (mnppl(i)-min(mnppl))/(max(mnppl)-min(mnppl))*(y2-y1)+y1,...
      'ko','MarkerSize',7,'MarkerFaceColor','y');

  print('-dpng',fullfile(d.plot,'climber',['climber_nppl_' sprintf('%3.3d_',i) num2str(abs(time(i))) bc]));
  delete(p1,p4);
end


figure(3);
clf reset;
m_proj('Miller','lat',latlimits);

[x1,y1]=m_ll2xy(-40,latlimits(1)+5);
[x2,y2]=m_ll2xy(110,-32);

hold on;
m_coast; m_grid;

set(gcf,'position',[692   641   560   271]);

for i=ntime:-1:1
  if time(i)<0 bc='BC'; else bc='AD'; end
  title(sprintf('Climber GDD_0 %4d %s',abs(time(i)),bc));
  p1=m_pcolor(lon,lat,squeeze(gdd(i,:,:))');
  set(gca,'clim',[0 360]);
shading flat;
  a1=gca;
  cb=colorbar;
  set(cb,'Ylim',[0,360]);
  
  if ~exist('p2','var') p2=plot([x2,x1,x1],[y1,y1,y2],'k-'); end
  if ~exist('p3','var') p3=plot( (time-min(time))/(max(time)-min(time))*(x2-x1)+x1 ,...
      mgdd/360*(y2-y1)+y1,...
      'm','LineWidth',4); end
  p4=plot((time(i)-min(time))/(max(time)-min(time))*(x2-x1)+x1,...
      mgdd(i)/360*(y2-y1)+y1,...
      'ko','MarkerSize',7,'MarkerFaceColor','y');

  print('-dpng',fullfile(d.plot,'climber',['climber_gdd_' sprintf('%3.3d_',i) num2str(abs(time(i))) bc]));
  delete(p1,p4);
  end



return
end
