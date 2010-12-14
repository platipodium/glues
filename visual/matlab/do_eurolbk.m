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

ncol=19;
cmap=flipud(jet(ncol));
stime=1950-sage;
iscol=floor((stime-min(timelim))./(timelim(2)-timelim(1))*ncol)+1;
viscol=find(iscol>0 & iscol<=ncol & slat>=latlim(1) & slat<=latlim(2) ...
    & slon>=lonlim(1) & slon<=lonlim(2));
  


%% Do Ammerman plot (figure 4)
figure(1); clf reset; hold on;
plot(-stime,sdists,'bo');
ylabel('Distance from Levante');
xlabel('Time (year BC)'); 
set(gca,'Xlim',-fliplr([timelim]));
set(gca,'XDir','reverse');
plot(8000:-200:4000,0:200:4000,'k--');

dlat=[lat' repmat(lat(272),nreg,1)];
dlat=reshape(lat',2*nreg,1);
dlon=[lon' repmat(lon(272),nreg,1)];
dlon=reshape(dlon',2*nreg,1);
dists=m_lldist(dlon,dlat);
dists=dists(1:2:end);


%% plot farming timing (figure 3)
ncol=19;
[data,basename]=clp_nc_variable('var','farming','threshold',0.5,'reg',reg,'marble',2,'transparency',1,'nocolor',0,...
      'showstat',0,'timelim',timelim,'showtime',0,'flip',1,'showvalue',0,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base','noprint',1,'ncol',ncol);
  
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
set(ytt,'String','Year BC');

for i=1:length(viscol)
  m_plot(slon(viscol(i)),slat(viscol(i)),'ko','MarkerFaceColor',cmap(iscol(viscol(i)),:));
end


for ir=1:-nhreg  
  m_text(lon(hreg(ir)+1),lat(hreg(ir)+1),letters(ir),'background','w',...
      'Horizontal','center','Vertical','middle');
end
m_coast('color','k');
m_grid('box','fancy','linestyle','none');
plot_multi_format(gcf,basename);

  
%% Plot region network (figure 1)
[data,basename]=clp_nc_neighbour('reg',reg,'marble',2,'transparency',1,'nocolor',0,...
      'showstat',0,'showtime',0,'fontsize',10,'showregion',0,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base','noprint',1);
  
for ir=1:nhreg  
  m_text(lon(hreg(ir)+1),lat(hreg(ir)+1),letters(ir),'background','y',...
      'Horizontal','center','Vertical','middle');
end
m_coast('color','k','linestyle','none');
m_grid('box','fancy');

plot_multi_format(gcf,basename);


%return
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