% Run script for eurolbk paper about spread and migration in Europe

%% Define region to lbk
reg='lbk';
timelim=[-8000 -4000];
hreg=[271 255  211 183 178 170 146 142 122 123];
nhreg=length(hreg);
letters='ABCDEFGHIJKLMNOPQRSTUVW';
letters=letters(1:nhreg);

file='../../eurolbk_base.nc';
ncid=netcdf.open(file,'NOWRITE');
varid=netcdf.inqVarID(ncid,'region');
region=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'time');
time=netcdf.getVar(ncid,varid);
itime=find(time>=timelim(1) & time<=timelim(2));
time=time(itime);
varid=netcdf.inqVarID(ncid,'farming');
farming=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'latitude');
lat=double(netcdf.getVar(ncid,varid));
varid=netcdf.inqVarID(ncid,'longitude');
lon=double(netcdf.getVar(ncid,varid));
netcdf.close(ncid);
nreg=length(region);

% get lat/lon from regionpath, since they are wrong in the above file
if ~exist('lonlat_685.mat','file')
  load('regionpath_685');
  regionpath(:,:,1)=regionpath(:,:,1)+0.5;
  regionpath(:,:,2)=regionpath(:,:,2)+1;
  lats=squeeze(regionpath(:,:,2));
  lons=squeeze(regionpath(:,:,1));

  for ir=1:nreg
    lat(ir)=calc_geo_mean(lats(ir,:),lats(ir,:));
    lon(ir)=calc_geo_mean(lats(ir,:),lons(ir,:));
  end
  save('lonlat_685','lon','lat');
else load('lonlat_685');
end
  

if ~exist('neolithicsites.mat','file')
    fprintf('Required file neolithicsites.mat not found, please contact distributor.\n');
    return
end


load('neolithicsites');
slat=Forenbaher.Latitude;
slon=Forenbaher.Long;
period=Forenbaher.Period;
site=Forenbaher.Site_name;
sage=Forenbaher.Median_age;
ns=length(sage);
dlat=[slat' repmat(lat(272),ns,1)];
dlat=reshape(dlat',2*ns,1);
dlon=[slon' repmat(lon(272),ns,1)];
dlon=reshape(dlon',2*ns,1);
sdists=m_lldist(dlon,dlat);
sdists=sdists(1:2:end);

[ifound,nfound,lonlim,latlim]=find_region_numbers(reg);
farming=farming(ifound,itime);

ncol=19;
cmap=flipud(jet(ncol));
stime=1950-sage;
iscol=floor((stime-min(timelim))./(timelim(2)-timelim(1))*ncol)+1;
viscol=find(iscol>0 & iscol<=ncol & slat>=latlim(1) & slat<=latlim(2) ...
    & slon>=lonlim(1) & slon<=lonlim(2));
  


%% Do Ammerman plot (figure 4)
figure(1); clf reset; hold on;
set(gcf,'Units','centimeters','Position',[0 0 18 18]);
% Single column 90 mm 1063 1772 3543 
% 1.5 column 140 mm 1654 2756 5512
% Full width 190 mm 2244 3740 7480



i272=find(ifound==272);
for i=1:nhreg
  ihreg(i)=find(ifound==hreg(i)+1);
end

dlat=[lat repmat(lat(272),nreg,1)];
dlat=reshape(dlat',2*nreg,1);
dlon=[lon repmat(lon(272),nreg,1)];
dlon=reshape(dlon',2*nreg,1);
dists=m_lldist(dlon,dlat);
dists=dists(1:2:end);
dists=dists(ifound);
threshold=0.5;
it=(farming>=threshold).*repmat(1:length(itime),nfound,1);
it(it==0)=inf;
it=min(it,[],2);
itv=isfinite(it);
onset=zeros(nfound,1)+inf;
onset(itv)=time(min(it(itv),[],2));

gtime=timelim(1):200:timelim(2);

set(gca,'color','none','FontSize',14,'FontName','Times');
p3=plot(-onset(ihreg),dists(ihreg),'ys','MarkerFaceColor','y','MarkerSize',7);
p1=plot(-stime,sdists,'bo','MarkerFaceColor','none','MarkerSize',2);
ylabel('Distance from Levante (km)');
xlabel('Time (year BC)'); 
set(gca,'Xlim',-fliplr([timelim]));
set(gca,'XDir','reverse');
p2=plot(-onset,dists,'rd','MarkerFaceColor','r','MarkerSize',5)
%plot(7500:-200:3500,0:200:4000,'k--');

pf1=polyfit(-onset(itv),dists(itv),1);
p4=plot(-gtime,-gtime*pf1(1)+pf1(2),'r-','LineWidth',2);
pf2=polyfit(-stime(viscol)',sdists(viscol),1);
% Indistiguishable, thus not shown
%plot(-gtime,-gtime*pf2(1)+pf2(2),'b--','MarkerSize',2);

[cr1,cp1]=corrcoef(onset(itv),dists(itv));
[cr2,cp2]=corrcoef(stime(viscol),sdists(viscol));

ytl=get(gca,'YTickLabel');
ytl(1,:)=' ';
set(gca,'YTickLabel',ytl);

l=legend([p1,p2],sprintf('Site data (n=%d, r^2=%.2f, v=%.2f km a^{-1})',length(viscol),cr2(2).^2,-pf2(1)),...
    sprintf('Simulation (n=%d, r^2=%.2f, v=%.2f km a^{-1})',length(itv),cr1(2).^2,-pf1(1)),...
    'location','NorthWest','FontSize',7);
%set(l,'color','none');

offsets=100*[0 1 -1 1 -1 0 0 0 0 0];
for i=1:nhreg
  t1(i)=text(-onset(ihreg(i)),-200+offsets(i),letters(i),'Horizontal','center','FontName','Times','FontSize',14);
end

plot_multi_format(1,'ammerman_rgb','pdf');


%% Do black and white version
set(p3,'MarkerFaceColor',repmat(0.5,3,1),'Color',repmat(0.5,3,1));
set([p2,p1,p4],'Color',repmat(0,3,1));
set(p2,'MarkerFaceColor',repmat(0,3,1));
plot_multi_format(1,'ammerman_bw','pdf');

%% Do non-uniform spread
%movdists=movavg(onset(itv),dists(itv),500,1);
%[sorton,isorton]=sort(onset(itv));
%figure(2); clf reset;
%plot(sorton,movdists(isorton),'r-');
%pf3=polyfit(-onset(itv),dists(itv),3);
%p5=plot(-gtime,(-gtime).^3*pf3(1)+(-gtime).^2*pf3(2)+-gtime*pf3(3)+pf3(4),'r-','LineWidth',2);




%% plot farming timing (figure 3)
ncol=19;

[data,basename]=clp_nc_variable('var','farming','threshold',0.5,'reg',reg,'marble',2,'transparency',1,'nocolor',0,...
      'showstat',0,'timelim',timelim,'showtime',0,'flip',1,'showvalue',0,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base',...
      'noprint',1,'notitle',1,'ncol',ncol);
  
set(gcf,'Units','centimeters','Position',[0 0 18 18]);

cb=findobj('tag','colorbar');
cmap=flipud(jet(ncol));
cmap=rgb2hsv(cmap);
cmap(:,2)=cmap(:,2)*0.5;
cmap=hsv2rgb(cmap);
colormap(cmap);
ytl=get(cb,'YTickLabel');
ytl=ytl(:,2:end);
set(cb,'YTickLabel',ytl);
ytt=get(cb,'Title');
set(ytt,'String','Year BC','FontSize',14,'FontName','Times','FontWeight','normal');

for i=1:length(viscol)
  m_plot(slon(viscol(i)),slat(viscol(i)),'ko','MarkerFaceColor',cmap(iscol(viscol(i)),:));
end

ct=findobj(gcf,'-property','FontName');
set(ct,'FontSize',14,'FontName','Times','FontWeight','normal');


for ir=1:-nhreg  
  m_text(lon(hreg(ir)+1),lat(hreg(ir)+1),letters(ir),'background','w',...
      'Horizontal','center','Vertical','middle');
end
m_coast('color','k');
m_grid('box','fancy','linestyle','none');
plot_multi_format(gcf,strrep(basename,'farming_','timing_'),'pdf');


ct=findobj(gcf,'type','text'); set(ct,'visible','off');
ct=findobj(gcf,'-property','YTickLabel'); set(ct,'YTickLabel',[]);
ct=findobj(gcf,'-property','XTickLabel'); set(ct,'XTickLabel',[]);
set(ytt,'visible','off');

plot_multi_format(gcf,strrep(basename,'farming_','timing_'),'png');

%plot2svg([basename '.svg'],gcf,'png');

%% Plot region network (figure 1)
[data,basename]=clp_nc_neighbour('reg',reg,'marble',2,'transparency',1,'nocolor',0,...
      'showstat',0,'showtime',0,'fontsize',15,'showregion',0,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base','noprint',1,'notitle',1);
  
for ir=1:nhreg  
  t(i)=m_text(lon(hreg(ir)+1),lat(hreg(ir)+1),letters(ir),'background','y',...
      'Horizontal','center','Vertical','middle');
end
m_coast('color','k','linestyle','none');
m_grid('box','fancy','linestyle','none');

plot_multi_format(gcf,'region_map_rgb','tif');
%% black and white version
for ir=1:nhreg  
  set(t(i),'background',repmat(0.9,3,1));
end

plot_multi_format(gcf,'region_map_bw','tif');


return
clp_nc_variable('var','farming','threshold',0.5,'reg',reg,'marble',2,'transparency',1,'nocolor',0,...
      'showstat',0,'timelim',timelim,'showtime',0,'flip',1,'showvalue',1,...
      'file','../../eurolbk_nospread.nc','figoffset',2,'sce','nospread')


% Only for informational purpose, not in paper (which is without climate)
%clp_nc_variable('var','farming','threshold',0.5,'reg',reg,'marble',2,'transparency',1,'nocolor',0,...
%      'showstat',0,'timelim',timelim,'showtime',0,'flip',1,'showvalue',1,...
%      'file','../../eurolbk_events.nc','figoffset',1,'sce','events')

%  return
%% Plot wave of advance for selected regions
hreg=[271 255  211 183 178 170 146 142 122 123];
lc='mkcrbmkcrb';
ls='--------------------';
nhreg=length(hreg);
timelim=[-8000 -2000];

[d,b]=clp_nc_trajectory('reg',hreg+1,'var','farming','timelim',timelim,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base');
%%
dd=diff(d');
ntime=size(dd,1);
dtime=(timelim(2)-timelim(1))/(ntime-1);
time=timelim(1):dtime:timelim(2);
clf reset;
for i=1:nhreg
  p(i)=plot(dd(:,i),time,'k-','color',lc(i),'LineStyle',ls(i));
  hold on;
end
set(gca,'YAxisLocation','right','Ylim',[timelim(1),-3000],'XTick',[]);
%legend(num2str(hreg'));
plot_multi_format(gcf,[b '_diff']);

  
%return  
%% Define region to lbk
reg='lbk';
time=-7500:100:-3000;
ntime=length(time);

%% plot farming advance
for it=1:ntime
  clp_nc_variable('var','farming','reg',reg,'marble',2,'transparency',1,'nocolor',0,...
      'showstat',0,'lim',[0 1],'timelim',time(it),...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base');
end
% Command line postprocessing
% for F in farming_lbk_66_base_*png ; do ln -s $F `echo $F | awk -F'_' '{print $1 "_" $2 "_" $3 "_" $4 "_" 10000+$5 "_" $5 }'` ; done

%return
%% Create lbk_background.png
reg='lbk';
[r,nreg,lonlim,latlim]=find_region_numbers(reg);
figure(1); clf reset;
axes('color','w','box','off');
m_proj('equidistant','lat',latlim,'lon',lonlim);

c0=100;
c1=230;
m_grid('XTick',[],'Ytick',[],'box','off');
cmap=gray(256);
hold on;
%set(gca,'XTick',[],'Ytick',[],'box','off');

%m_gshhs('ib','color',cmap(230,:));

[elev,lon,lat]=M_TBASE([lonlim(1) lonlim(2) latlim(1) latlim(2)]);
elev(elev<0)=NaN;
glat=latlim(2)+0.5/12-[1:size(elev,1)]/12.0;
glon=lonlim(1)-0.5/12+[1:size(elev,2)]/12.0;
m_pcolor(glon,glat,double(elev));
shading interp;
cmap=colormap(gray(256));
colormap(flipud(cmap(100:230,:)));
%m_gshhs('fc','color',cmap(c1,:));
%print('-dpng','-r600','lbk_background');



r=clp_nc_variable('var','region','showvalue',1,'reg',reg,'marble',2,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base');

ti=clp_nc_trajectory('var','technology_spread_by_information','reg',reg,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base');
tp=clp_nc_trajectory('var','technology_spread_by_people','reg',reg,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base');
ei=clp_nc_trajectory('var','economies_spread_by_information','reg',reg,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base');
ep=clp_nc_trajectory('var','economies_spread_by_people','reg',reg,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base');
qi=clp_nc_trajectory('var','farming_spread_by_people','reg',reg,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base');
pp=clp_nc_trajectory('var','migration_density','reg',reg,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base');
t=clp_nc_trajectory('var','technology','reg',reg,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base');
f=clp_nc_trajectory('var','farming','reg',reg,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base');
e=clp_nc_trajectory('var','economies','reg',reg,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base');
p=clp_nc_trajectory('var','population_density','reg',reg,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base');

reg=[271 278 255 242 253 211 216 235 252 183 184 210 198 178 170 147 146 142 177 156 123 122];

% Show trajectories for special regions, show "wave" of advance
for i=1:length(reg)
  j=find(r.value==reg(i));
  figure(reg(i)); 
  clf reset; 
  plot(ti(j,:),'r-'); 
  hold on; 
  plot(tp(j,:),'b-'); 
  plot(t(j,:)/1000,'g--'); 
  plot(q(j,:)/100,'m--'); 
  plot(qp(j,:),'m-');  
end



if ~exist('ex','var') ex=load('eurolbk_base'); end
tex=ex.d(:,1)-2*ex.d(1,1);
ti=ex.d(:,2);
te=ex.d(:,3);


for ir=1:10
figure(ir); clf reset;
r=hreg(ir);
ii=find(ti==r & tex<-4000);
ie=find(te==r & tex<-4000);

plot(tex(ii),ex.d(ii,5),'r.');
hold on;
plot(tex(ie),-ex.d(ie,5),'b.');

xlabel('Calendar year');
ylabel('Technology exchange by people');
title(['Region ' num2str(hreg(ir))]);

figure(ir+10); clf reset;
plot(tex(ii),ex.d(ii,4),'r.');
hold on;
plot(tex(ie),-ex.d(ie,4),'b.');

xlabel('Calendar year');
ylabel('Technology exchange by information');
title(['Region ' num2str(hreg(ir))]);

fprintf('Sum in region %d: %f by people, %f by info\n',...
    r,sum(ex.d(ii,5))-sum(ex.d(ie,5)),sum(ex.d(ii,4))-sum(ex.d(ie,4)));
%    r,sum(ex.d(ii,5)),sum(ex.d(ii,4)));
end

return
iit=(tex(ii)+9500)/5+1;
iet=(tex(ie)+9500)/5+1;
%iit=find(tex(ti==r));
%iet=find(tex(te==r));
[uiit,uii,uij]=unique(iit);
for i=1:length(uiit)
  iii=find(uiit(i)==iit);
  ui(i)=sum(ex.d(ii(iii),5));
end
ut=(uiit-1)*5-9500;

plot(ut,ui,'m-');

% Todo: make network plot (who is connected to whom)