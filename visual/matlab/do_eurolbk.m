% Run script for eurolbk paper about spread and migration in Europe
% 
% 0.0000002 0.08
% 0.0000002 0.16
% 0.0000002 0.3
% 0.0000002 0.6
% 0.0000020 0.19999997
% 0.0000039 0.19999997
% 0.0000078 0.2
% 0.0000156 0.2
% 0.0000313 0.2
% 0.0000625 0.2
% 0.000125 0.2
% 0.00025 0.2
% 0.0005 0.2
% 0.0005 0.8
% 0.001 0.2
% 0.001 0.4
% 0.002 0.05
% 0.002 0.1
% 0.002 0.2
% 0.002 0.4
% 0.002 0.8
% 0.004 0.1
% 0.004 0.2
% 0.008 0
% 0.008 0.05
% 0.008 0.2
% 




%% Define region to lbk
reg='lbk'; [ireg,nreg,loli,lali]=find_region_numbers(reg);
lonlim=loli; latlim=lali;

%% define region to austria
%lonlim=[9 17]; latlim=[46 49];  [ireg,nreg,loli,lali]=find_region_numbers('lat',latlim,'lon',lonlim);
%reg=ireg;

timelim=[-8000 -3500];
hreg=[271 255  211 183 178 170 146 142 123 122];
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
varid=netcdf.inqVarID(ncid,'farming');
farming=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'farming_spread_by_people');
farmingspread=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'latitude');
lat=double(netcdf.getVar(ncid,varid));
varid=netcdf.inqVarID(ncid,'longitude');
lon=double(netcdf.getVar(ncid,varid));
varid=netcdf.inqVarID(ncid,'area');
area=double(netcdf.getVar(ncid,varid));
netcdf.close(ncid);
nreg=length(region);

if (0==1)
  cumspread=cumsum(farmingspread,2);
  threshold=0.9;
  ivalid=(farming>threshold);
  timing=repmat(time',nreg,1).*ivalid;
  timing(timing==0)=inf;
  [mtiming,itiming]=min(timing,[],2);
  ivalid=find(isfinite(mtiming));
  cumrel=cumspread;%./farming;
  relimmi90=cumspread(ivalid,:);
  relimmi90=diag(relimmi90(:,itiming(ivalid)));
  relim(1:nreg)=NaN;
  relim(ivalid)=relimmi90;
  ncid=netcdf.open(file,'WRITE');
  regid=netcdf.inqDimID(ncid,'region');
  timid=netcdf.inqDimID(ncid,'time');
  try
    varid=netcdf.inqVarID(ncid,'fraction_of_farming_immigrants_at_90');
  catch
    netcdf.reDef(ncid);
    varid=netcdf.defVar(ncid,'fraction_of_farming_immigrants_at_90','NC_FLOAT',regid);
    netcdf.endDef(ncid);
  end
  netcdf.putVar(ncid,varid,relim);

  try
    varid=netcdf.inqVarID(ncid,'cumulative_fraction_of_farming_immigrants');
  catch
    netcdf.reDef(ncid);
    varid=netcdf.defVar(ncid,'cumulative_fraction_of_farming_immigrants','NC_FLOAT',[regid,timid]);
    netcdf.endDef(ncid);
  end
  netcdf.putVar(ncid,varid,cumrel);
  netcdf.close(ncid);

 [d,b]=clp_nc_variable('var','fraction_of_farming_immigrants_at_90','reg',reg,'marble',2,'transparency',1,'nocolor',0,...
      'showstat',0,'lim',[0 0.25],'showtime',0,...
      'file',file,'figoffset',0,'sce','demic','noprint',1,'cmap','jet','fig',2);
  m_coast('color','k');
  m_grid('box','fancy','linestyle','none');
  title('Fraction of immigrant agropastoralists after transition');
  cb=findobj(gcf,'tag','colorbar')
  ytl=get(cb,'YTickLabel');
  ytl=num2str(round(100*str2num(ytl)));
  set(cb,'YTickLabel',ytl);
  title(cb,'%');
  cl_print('name',b,'ext','png','res',[300,600]);

 [d,b]=clp_nc_variable('var','cumulative_fraction_of_farming_immigrants','reg',reg,'marble',2,'transparency',1,'nocolor',0,...
      'showstat',0,'lim',[0 1],'showtime',1,'timelim',timelim(2),...
      'file',file,'figoffset',0,'sce','demic','noprint',1,'cmap','jet','fig',2);
  m_coast('color','k');
  m_grid('box','fancy','linestyle','none');
  title('Fraction of immigrant agropastoralists after transition');
  cb=findobj(gcf,'tag','colorbar')
  ytl=get(cb,'YTickLabel');
  ytl=num2str(round(100*str2num(ytl)));
  set(cb,'YTickLabel',ytl);
  title(cb,'%');
  cl_print('name',b,'ext','png','res',[300,600]);
  
end


time=time(itime);


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


% For Turney and Brown do this
if (1==0)
  load('neolithicsites');
  slat=Forenbaher.Latitude';
  slon=Forenbaher.Long';
  period=Forenbaher.Period';
  site=Forenbaher.Site_name';
  sage=Forenbaher.Median_age';
  sage_upper=Forenbaher.Upper_cal_';
  sage_lower=Forenbaher.Lower_cal';
else
  % For Pinhasi
  load('../../data/Pinhasi2005_etal_plosbio_som1.mat');
  slat=Pinhasi.latitude;
  slon=Pinhasi.longitude;
  period=Pinhasi.period;
  site=Pinhasi.site;
  sage=Pinhasi.age_cal_bp;
  sage_upper=sage+Pinhasi.age_cal_bp_s;
  sage_lower=sage-Pinhasi.age_cal_bp_s;
end


stime=1950-sage;
sutime=stime+(sage_lower-sage);
sltime=stime+(sage_upper-sage);

is=find(slat>=latlim(1) & slat<=latlim(2) & slon>=lonlim(1) & slon<=lonlim(2) ...
    & sltime>=timelim(1) & sutime<=timelim(2));

slon=slon(is);
slat=slat(is);
period=period(is);
site=site(is);
sltime=sltime(is);
sutime=sutime(is);
srange=sltime-sutime;
stime=stime(is);

ns=length(slon);
dlat=[slat repmat(lat(272),ns,1)];
dlat=reshape(dlat',2*ns,1);
dlon=[slon repmat(lon(272),ns,1)];
dlon=reshape(dlon',2*ns,1);
sdists=m_lldist(dlon,dlat);
sdists=sdists(1:2:end);

ifound=ireg;nfound=nreg;lonlim=loli; latlim=lali;

ncol=19;
cmap=flipud(jet(ncol));
iscol=floor((stime-min(timelim))./(timelim(2)-timelim(1))*ncol)+1;
iscol(iscol<1)=1;
viscol=find(iscol<=ncol);


if (9==0)
%% Plot small maps with region highlighted (part of figures 4/6)
  for ir=1:nhreg
    figure(ir+40); clf reset; 
    clp_basemap('lon',lonlim,'lat',latlim);
    hdl=clp_regionpath('reg',hreg(ir)+1);
    set(hdl,'FaceColor','g','EdgeColor','k');

    % Remove connecting lines
    hdl=findobj(gcf,'LineStyle',':');
    delete(hdl);
    m_grid('box','fancy','linestyle','none');
    pname=sprintf('region_map_highlight_%s',letters(ir));
    cl_print('name',pname,'ext','pdf');
  end

end


if (9==0)
%% Plot small maps with region highlighted (part of figures 4/6)
    figure(40); clf reset; 
    clp_basemap('lon',lonlim,'lat',latlim,'nocoast',1);
    hdl=findobj('EdgeColor','k');
    set(hdl,'EdgeColor','none');
    m_coast('patch',0.9*[1 1 1]);
    
    hdl=clp_regionpath('reg',hreg+1);
    
    set(hdl,'FaceColor',0.7*[1 1 1],'EdgeColor',0.3*[1 1 1]);

    % Remove connecting lines
    hdl=findobj(gcf,'LineStyle',':');
    delete(hdl);
    m_grid('box','on','linestyle','none');
    pname=sprintf('region_map_highlight');
    cl_print('name',pname,'ext','pdf');
end


if (8==0)
   pc=0.9;
%% Plot map with spread mechanism for base simulation
  figure(8); clf reset; hold on;
  spread=load('spread_mechanism_all_eurolbk_base');
  nhhreg=length(spread.hreg);
  timing=zeros(nhhreg,1)+Inf;
  reldQp=zeros(nhhreg,1)+NaN;
  clp_basemap('lon',lonlim,'lat',latlim);
  %m_coast('line','color','k');
  for i=1:length(spread.hreg) 
     hdl(i)=clp_regionpath('reg',spread.hreg(i)+1);
     if hdl(i)<=0 continue; end
     set(hdl(i),'FaceColor',0.8*[1 1 1]','EdgeColor','k');
     itiming=min(find(spread.farming(i,:)>=pc));
     if ~isempty(itiming)
       timing(i)=spread.rtime(itiming);
       reldQp(i)=spread.reldQp(i,itiming);
       %m_text(lon(spread.hreg(i)+1),lat(spread.hreg(i)+1),num2str(reldQp(i)));
     end     
  end
  maxreldQp=1; max(reldQp(isfinite(reldQp)));
  qncol=10;
  %cmap=colormap(hotcold(2*qncol)); cmap=cmap(qncol+1:end,:);
  cmap=(greenred(qncol+qncol/2)); 
  cmap=cmap([1:2:qncol, qncol+1:1:end],:); cmap(3,3)=0.35; cmap(5,3)=0.2;
  colormap(cmap);
  qcol=round(reldQp/maxreldQp*qncol+1);
  qcol(qcol>qncol)=qncol;
  for i=1:nhhreg
    if hdl(i)>0 && isfinite(qcol(i))
      set(hdl(i),'FaceColor',cmap(qcol(i),:),'EdgeColor','k');
    end
  end
  hdlg=findobj(gcf,'LineStyle',':');
  delete(hdlg);
  m_grid('box','fancy','linestyle','none');
  colorbar;
  cl_print('name','demic_spread_map','ext','pdf','res',[150,600]);

end


if (1==0)
%% Plot region network (figure 1)
[data,basename]=clp_nc_neighbour('reg',reg,'marble',2,'transparency',1,'nocolor',0,...
      'showstat',0,'showtime',0,'fontsize',15,'showregion',0,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base','noprint',1,'notitle',1);

% Remove connecting lines
hdl=findobj(gcf,'LineStyle',':');
delete(hdl);
 
% increase visibility of region borders
hdl=findobj('-property','edgecolor','-and','LineStyle','-','-and','edgecolor','k');
set(hdl,'edgecolor','k','LineWidth',2,'EdgeAlpha',0.6);
 
hold on;
sp=m_plot(slon,slat,'k^');
set(sp,'MarkerFacecolor','k','MarkerSize',2);

for ir=1:-nhreg  
  t(ir)=m_text(lon(hreg(ir)+1),lat(hreg(ir)+1),letters(ir),'background','k','color','w',...
      'Horizontal','center','Vertical','middle','visible','on','fontsize',16,'fontweight','bold','Margin',2);
  %e=get(t(ir),'Extent');
  %pt(ir)=patch(e(1)+[0 e(3) e(3) 0 0],e(2)+[0 0 e(4) e(4) 0],'w','EdgeColor','none','FaceAlpha',0.5);
end
gray=repmat(0.4,1,3);
%m_coast('color',gray);
m_grid('box','fancy','linestyle','none');
%,'XTick',[],'YTick',[]);

cl_print('name','region_map','ext','png','res',[150,600]);
end

%------------------------------------------------------------------------------
movtime=-7500:500:-3500;
nmovtime=length(movtime);

%% plot farming advance (Figure 2)
if (2==0) for it=1:nmovtime
  [d,b]=clp_nc_variable('var','farming','reg',reg,'marble',2,'transparency',1,'nocolor',0,...
      'showstat',0,'lim',[0 1],'timelim',movtime(it),'showtime',0,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce',['base_' sprintf('%05d',movtime(it))],'noprint',1);
  m_coast('color','k');
  m_grid('box','fancy','linestyle','none');
  title('GLUES agropastoral activity');
  cb=findobj(gcf,'tag','colorbar')
  ytl=get(cb,'YTickLabel');
  ytl=num2str(round(100*str2num(ytl)));
  set(cb,'YTickLabel',ytl);
  title(cb,'%');
  cl_print('name',b,'ext','png','res',[300,600]);
 end,end

%% plot farming advance (as Figure 2, movie)
movtime=-7500:50:-3500;
nmovtime=length(movtime);
if (2==0) for it=1:nmovtime
  [d,b]=clp_nc_variable('var','farming','reg',reg,'marble',2,'transparency',1,'nocolor',0,...
      'showstat',0,'lim',[0 1],'timelim',movtime(it),...
      'file','../../eurolbk_base.nc','figoffset',0,'sce',['base_' sprintf('%03d_%05d',it,movtime(it))],'noprint',1);
  m_coast('color','k');
  m_grid('box','fancy','linestyle','none');
  title('GLUES agropastoral activity');
  cb=findobj(gcf,'tag','colorbar')
  ytl=get(cb,'YTickLabel');
  ytl=num2str(round(100*str2num(ytl)));
  set(cb,'YTickLabel',ytl);
  title(cb,'%');
  cm=get(cb,'Children');
  cmap=get(cm,'CData');
  
  cl_print('name',b,'ext','png','res',100);
 end,end


% Command line postprocessing
%mencoder mf://farming_lbk_66_base_???_*_150.png  -mf w=800:h=600:fps=5:type=png -ovc lavc -lavcopts vcodec=mpeg4:mbd=2:trell -oac copy -o output.avi



if (3==0)
%% plot farming timing (figure 3)
ncol=8;

[data,basename]=clp_nc_variable('var','farming','threshold',0.5,'reg',reg,'marble',2,'transparency',1,'nocolor',0,...
      'showstat',0,'timelim',[-7500 -3500],'showtime',0,'flip',1,'showvalue',0,...
      'file','../../eurolbk_base.nc','figoffset',0,'sce','base',...
      'noprint',1,'notitle',1,'ncol',ncol,'cmap','clc_eurolbk');
  
%set(gcf,'Units','centimeters','Position',[0 0 18 18]);

hdf=findobj(gcf,'-property','EdgeColor');
set(hdf,'Edgecolor','none')
cm=get(gcf,'colormap');

cb=findobj('tag','colorbar');
cbc=get(cb,'Children');
if iscell(cbc)
  set(cbc{1},'AlphaData',0.5);
  set(cbc{2},'AlphaData',0.5);
else
  set(cbc,'AlphaData',0.5);
end
set(cb,'Ticklength',[0 0],'box','off');
pos=get(cb,'Position');
%set(cb,'Position',pos.*[1+pos(3) 1 2.0 1]
ytl=get(cb,'YTickLabel');
if iscell(ytl) ytl=char(ytl{1}); end
ytl(:,1)=' ';
set(cb,'YTickLabel',ytl);
ytt=get(cb,'Title');
if iscell(ytt) ytt=ytt{1}; end
set(ytt,'String','Year BC','FontSize',14,'FontName','Times','FontWeight','normal');

cb2=copyobj(cb,gcf);
set(get(cb2,'Children'),'AlphaData',1);
ytt=get(cb2,'Title');
if iscell(ytt) ytt=ytt{1}; end
set(ytt,'String','');
pos=get(cb,'Position');
set(cb2,'Position',pos.*[1 1 0.5 1],'YTick',[],'box','off');


for i=1:length(viscol)
  mcolor=cmap(iscol(viscol(i)),:);
  ps(i)=m_plot(slon(viscol(i)),slat(viscol(i)),'k^','MarkerFaceColor',mcolor,...
      'MarkerEdgeColor',cmap(iscol(viscol(i)),:),'MarkerSize',4);
end

ct=findobj(gcf,'-property','FontName');
set(ct,'FontSize',14,'FontName','Times','FontWeight','normal');


for ir=1:-nhreg  
  m_text(lon(hreg(ir)+1),lat(hreg(ir)+1),letters(ir),'background','w',...
      'Horizontal','center','Vertical','middle');
end
m_coast('color','k');
m_grid('box','fancy','linestyle','none');
cl_print('name',strrep(basename,'farming_','timing_'),'ext','png','res',[150,600]);


%ct=findobj(gcf,'type','text'); set(ct,'visible','off');
%ct=findobj(gcf,'-property','YTickLabel'); set(ct,'YTickLabel',[]);
%ct=findobj(gcf,'-property','XTickLabel'); set(ct,'XTickLabel',[]);
%set(ytt,'visible','off');

%plot_multi_format(gcf,strrep(basename,'farming_','timing_'),'png');

    
    
end




if (7==0)
%% plot farming timing for nospread(figure )
ncol=8;

[data,basename]=clp_nc_variable('var','farming','threshold',0.5,'reg',reg,'marble',2,'transparency',1,'nocolor',0,...
      'showstat',0,'timelim',[-7500 -3500],'showtime',0,'flip',1,'showvalue',0,...
      'file','../../eurolbk_nospread.nc','figoffset',0,'sce','nospread',...
      'noprint',1,'notitle',1,'ncol',ncol,'cmap','clc_eurolbk');
  
%set(gcf,'Units','centimeters','Position',[0 0 18 18]);

hdf=findobj(gcf,'-property','EdgeColor');
set(hdf,'Edgecolor','none')

cb=findobj('tag','colorbar');
ytl=get(cb,'YTickLabel');
ytl=ytl(:,2:end);
set(cb,'YTickLabel',ytl);

%for i=1:length(viscol)
%  m_plot(slon(viscol(i)),slat(viscol(i)),'ko','MarkerFaceColor',cmap(iscol(viscol(i)),:));
%end

ct=findobj(gcf,'-property','FontName');
set(ct,'FontSize',14,'FontName','Times','FontWeight','normal');


for ir=1:-nhreg  
  m_text(lon(hreg(ir)+1),lat(hreg(ir)+1),letters(ir),'background','w',...
      'Horizontal','center','Vertical','middle');
end
m_coast('color','k');
m_grid('box','fancy','linestyle','none');
cl_print('name',strrep(basename,'farming_','timing_'),'ext','png','res',[150,600]);

   
end


%% Do pdf plot for highlighted regions

rmin=250;
%[d,b]=clp_nc_trajectory('reg',hreg+1,'var','farming','timelim',timelim,...
%      'file','../../eurolbk_base.nc','figoffset',0,'sce','base','noprint',1);
%%
dd=diff(farming');
ntime=size(dd,1);
dtime=(timelim(2)-timelim(1))/(ntime-1);
rtime=timelim(1):dtime:timelim(2);
clf reset;

dedges=200;
edges=[-inf -8000+dedges/2.0:dedges:-3400-dedges/2.0 inf];
centers=[edges(2:end-1)-dedges/2.0 edges(end-1)+dedges/2.0];
collbk=[1 1 0]; % 'y'
coltrb=[1 0 0]; %'r';
colppn=[0 1 0]; %'g';
colkor=[0 1 1]; %'c';

spreadv=0.02*1.0E7;
radius=sqrt(area/pi);
rsigma=2*dedges*radius.*radius/spreadv;

if (4==0)
for i=1:nhreg
  
  
  
    
  figure(i); clf reset; hold on;
  pos=get(gcf,'position');
  set(gcf,'Position',[pos(1:2) 500 90]);
  %pb(i)=bar(rtime,dd(:,i)/max(dd(:,i)),'k','edgecolor','k');
  %set(pb(i),'FaceColor','k','LineStyle','none');
  %ymax=max(dd(:,i)/sum(dd(:,i))*length(dd(:,i))*0.5)*1.1;
  set(gca,'Xlim',[-8100,-3300],'YTick',[0 0.2 1],'Ylim',[-0.2 1.2],'color','none','box','off');
  
  r=radius(hreg(i)+1);
  if r<rmin r=rmin; end
  
  % calculate exchange coeff
  sigma=rsigma(hreg(i)+1);
  ddreg=dd(:,hreg(i)+1);
  [maxdd,imax]=max(ddreg);
  g=normpdf(rtime,rtime(imax),sigma)';
  %figure(20); clf reset; hold on;
  %plot(rtime,ddreg,'b-');
  %plot(rtime,g,'r-');
  ddconv=conv(ddreg,g,'full');
  [maxddconv,iddconv]=max(ddconv);
  offset=int16(iddconv-imax);
  ddconv=ddconv(offset+1:offset+ntime)/0.008;
  %plot(rtime,ddconv,'m-');
  
  
  
  rlat=lat(hreg(i)+1);  rlon=lon(hreg(i)+1);
  dlat=[slat repmat(rlat,ns,1)];
  dlat=reshape(dlat',2*ns,1);
  dlon=[slon repmat(rlon,ns,1)];
  dlon=reshape(dlon',2*ns,1);
  dists=m_lldist(dlon,dlat);
  dists=dists(1:2:end);  
  ir=find(dists<=r);
%   [hir,hirt]=hist(stime(ir),length(ir)/4.0);
%   [whir,whirt]=hist([stime(ir) sutime(ir) sltime(ir)],length(3*ir)/4.0);
%   bar(whirt,whir/sum(whir)*length(whir),.7,'r','edgecolor','none');
%   bar(hirt,hir/sum(hir)*length(hir),0.4,'c','edgecolor','none');
 
  
  a1=normpdf(0,0,1);
  a2=normpdf(1,0,1);
  a3=sum(a1+2*a2);

  hir=histc(stime(ir),edges);
  whir=(a1*histc(stime(ir),edges)+a2*histc(sutime(ir),edges)+a2*histc(sltime(ir),edges))/a3;  
  
  thresh=0.01;
  idata=find(ddconv(itime)>thresh);
  xdata=time(idata)';
  ndata=length(xdata);
  ydata=zeros(1,ndata);
  cdata=double(ddconv(itime(idata)))';
  
  lightgray=repmat(0.70,3,1);
  darkgray=repmat(0.3,3,1);
  pp(i)=patch([xdata fliplr(xdata)]',[cdata cdata*0],'k-');
  set(pp(i),'FaceColor',lightgray,'edgeColor','none');
  plot(xdata,cdata,'k-','LineWidth',2.5);
 
  
  %pp=patch([xdata fliplr(xdata)]',[ydata ydata+1]',[cdata fliplr(cdata)]');
  
  %cmap=1-0.3*((repmat(cdata',1,3)));
  %colormap(cmap);
  %caxis([0 1]);
 
   
  irp=strmatch('PPN',period(ir)); pir=ir(irp);
  phir=(a1*histc(stime(pir),edges)+a2*histc(sutime(pir),edges)+a2*histc(sltime(pir),edges))/a3;  
  if (size(phir,1)<size(phir,2)) phir=phir'; end
  nhir=phir(1:end-2)/5.0;
  irp=strmatch('Körös',period(ir)); pir=ir(irp);
  phir=(a1*histc(stime(pir),edges)+a2*histc(sutime(pir),edges)+a2*histc(sltime(pir),edges))/a3;  
  if (size(phir,1)<size(phir,2)) phir=phir'; end
  khir=phir(1:end-2)/5.0;
  irp=strmatch('LBK',period(ir)); pir=ir(irp);
  phir=(a1*histc(stime(pir),edges)+a2*histc(sutime(pir),edges)+a2*histc(sltime(pir),edges))/a3;  
  if (size(phir,1)<size(phir,2)) phir=phir'; end
  lhir=phir(1:end-2)/5.0;
  irp=strmatch('TRB',period(ir)); pir=ir(irp);
  phir=(a1*histc(stime(pir),edges)+a2*histc(sutime(pir),edges)+a2*histc(sltime(pir),edges))/a3;  
  if (size(phir,1)<size(phir,2)) phir=phir'; end
  thir=phir(1:end-2)/5.0;
  stackedhir=[nhir khir lhir thir];
  
  
  pbar=bar(centers(1:end-1),whir(1:end-2)/5,0.6,'k','edgecolor',darkgray,'LineWidth',1.6,'ShowBaseLine','off');
  set(pbar,'FaceColor','w');
  sb=bar(centers(1:end-1),stackedhir,'stacked','edgecolor','none','barwidth',0.4,'ShowBaseLine','off');
  set(sb(1),'Facecolor',colppn);
  set(sb(2),'FaceColor',colkor);
  set(sb(3),'FaceColor',collbk);
  set(sb(4),'Facecolor',coltrb);
  set(gca,'XDir','reverse');
  
  %plot(xdata,cdata,'k-','LineWidth',2.5);
 
  plot_multi_format(gcf,['timing_histogram_' letters(i)]);
  
  per=period(ir);
  [up,ua,ub]=unique(per);
  sb=hist(ub,length(ua));
  [sbm,sbmi]=sort(sb);
  sbmi=fliplr(sbmi); sbm=fliplr(sbm);
  
  np=length(up);
  ptext=sprintf('%s (%d) n=%d r=%04d:',letters(i),hreg(i),length(ir),r);
  for ip=1:np 
    ptext=[ptext sprintf(' %s (%d)',up{sbmi(ip)},sbm(ip)) ];
  end
  
  fprintf('%s\n',ptext);
 end

  figure(nhreg+1); clf reset; hold on;
  pos=get(gcf,'position');
  set(gcf,'Position',[pos(1:2) 500 90]);
  set(gca,'Xlim',[-8100,-3300],'YTick',[],'Ylim',[-0.2 1.2],'color','none');
  
  ir=strmatch('LBK',period);
  [mu,sigma]=normfit(stime(ir));
  lbknorm=normpdf(time,mu,sigma)*length(ir);
  
  ir=strmatch('Körös',period);
  [mu,sigma]=normfit(stime(ir));
  korosnorm=normpdf(time,mu,sigma)*length(ir);
  
  ir=strmatch('TRB',period);
  [mu,sigma]=normfit(stime(ir));
  trbnorm=normpdf(time,mu,sigma)*length(ir);
  
  ir=strmatch('PPN',period);
  [mu,sigma]=normfit(stime(ir));
  ppnnorm=normpdf(time,mu,sigma)*length(ir);
  
  ir=strmatch('Neolithic',period);
  [mu,sigma]=normfit(stime(ir));
  neonorm=normpdf(time,mu,sigma)*length(ir);
  
  mnorm=max([ppnnorm;trbnorm;lbknorm;korosnorm]);
  
  %pneo=patch([time; flipud(time)],[neonorm/mnorm; time*0],'k-');
  
  pppn=patch([time; flipud(time)],[ppnnorm/mnorm; time*0],colppn);
  ptrb=patch([time; flipud(time)],[trbnorm/mnorm; time*0],coltrb);
  plbk=patch([time; flipud(time)],[lbknorm/mnorm; time*0],collbk);
  
  ltnorm=(trbnorm<lbknorm).*trbnorm+(lbknorm<trbnorm).*lbknorm;
  plt=patch([time; flipud(time)],[ltnorm/mnorm; time*0],[1 0.75 0.5]); 
   pkoros=patch([time; flipud(time)],[korosnorm/mnorm; time*0],colkor);
  
  %lknorm=(korosnorm<lbknorm).*korosnorm+(lbknorm<korosnorm).*lbknorm;
  %plk=patch([time; flipud(time)],[lknorm/mnorm; time*0],[0.75 0.75 0.75]); 
  
  
  cl_print('name','timing_histogram_','ext','pdf');
  
end


%% Calculate distance matrix
nfound=length(ifound);
distfile=['distmatrix_' num2str(nfound) '_' num2str(ns) '.mat'];
if ~exist(distfile,'file')
  distmatrix=zeros(length(ifound),ns)+Inf;
  for i=1:length(ifound)
    rlat=lat(ifound(i));  rlon=lon(ifound(i));
    dlat=[slat repmat(rlat,ns,1)];
    dlat=reshape(dlat',2*ns,1);
    dlon=[slon repmat(rlon,ns,1)];
    dlon=reshape(dlon',2*ns,1);
    dists=m_lldist(dlon,dlat);
    dists=dists(1:2:end);  
    distmatrix(i,:)=dists;
  end
  save('distfile','distmatrix');
else
  load('distfile');    
end

if (5==5)
%% Do Ammerman plot (figure 5)
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
it=(farming(ifound,itime)>=threshold).*repmat(1:length(itime),nfound,1);
it(it==0)=inf;
it=min(it,[],2);
itv=isfinite(it);
onset=zeros(nfound,1)+inf;
onset(itv)=time(min(it(itv),[],2));

gtime=timelim(1):200:timelim(2);

figure(1); clf reset; hold on;
set(gcf,'Units','centimeters','Position',[0 0 18 18]);
set(gca,'color','w','FontSize',14,'FontName','Times');

irppn=strmatch('PPN',period);
irkor=strmatch('Körös',period);
irlbk=strmatch('LBK',period);
irtrb=strmatch('TRB',period);

[mulbkt,siglbkt]=normfit(-stime(irlbk));
[mulbkd,siglbkd]=normfit(sdists(irlbk));
[mutrbt,sigtrbt]=normfit(-stime(irtrb));
[mutrbd,sigtrbd]=normfit(sdists(irtrb));
[mukort,sigkort]=normfit(-stime(irkor));
[mukord,sigkord]=normfit(sdists(irkor));
[muppnt,sigppnt]=normfit(-stime(irppn));
[muppnd,sigppnd]=normfit(sdists(irppn));

collbk=[1 1 0.9]; % 'y'
  coltrb=[1 .95 .95]; %'r';
  colppn=[.95 1 .95]; %'g';
  colkor=[.9 1 1]; %'c';

%plbk=cl_ellipse(mulbkt,mulbkd,2*siglbkt,2*siglbkd,'k-','edgecolor','none','FaceColor',collbk,'FaceAlpha',1);
%ptrb=cl_ellipse(mutrbt,mutrbd,2*sigtrbt,2*sigtrbd,'k-','edgecolor','none','FaceColor',coltrb,'FaceAlpha',1);
%pkor=cl_ellipse(mukort,mukord,2*sigkort,2*sigkord,'k-','edgecolor','none','FaceColor',colkor,'FaceAlpha',1);
%pppn=cl_ellipse(muppnt,muppnd,2*sigppnt,2*sigppnd,'k-','edgecolor','none','FaceColor',colppn,'FaceAlpha',1);

simfcolor=[1 0 0];%[1 .9 .8];
simecolor='none';%[1 .65 .4];
for ir=1:nfound
  if ~isfinite(onset(ir)) continue; end
  cl_ellipse(-onset(ir),dists(ir),radius(ifound(ir)),radius(ifound(ir)),...
      'k-','edgecolor',simecolor,'FaceColor',simfcolor,'FaceAlpha',0.1);
end
p3=plot(-onset,dists,'rs','MarkerFaceColor',simecolor,'MarkerSize',2,...
    'MarkerEdgeColor',simecolor,'visible','off');
p1=plot(-stime,sdists,'bd','MarkerFaceColor','b','MarkerSize',2);
ylabel('Distance from Levante (km)');
xlabel('Time (year BC)'); 
%set(gca,'Xlim',-fliplr([timelim]));
set(gca,'Xlim',[3100 8400],'YLim',[-400 4400]);
set(gca,'XDir','reverse');
%p2=plot(-onset,dists,'rd','MarkerFaceColor','r','MarkerSize',1);
%plot(7500:-200:3500,0:200:4000,'k--');

pf1=polyfit(-onset(itv),dists(itv),1);
p4=plot(-gtime,-gtime*pf1(1)+pf1(2),'r--','LineWidth',4);
pf2=polyfit(-stime,sdists,1);
p5=plot(-gtime,-gtime*pf2(1)+pf2(2),'b--','LineWidth',4);


ikor=find(any(distmatrix(:,irkor)-repmat(radius(ifound),1,length(irkor))<=0,2));
ilbk=find(any(distmatrix(:,irlbk)-repmat(radius(ifound),1,length(irlbk))<=0,2));
itrb=find(any(distmatrix(:,irtrb)-repmat(radius(ifound),1,length(irtrb))<=0,2));
ippn=find(any(distmatrix(:,irppn)-repmat(radius(ifound),1,length(irppn))<=0,2));
%pippn=plot(-onset(ippn),dists(ippn),'rd','MarkerFaceColor',colppn,'MarkerSize',10);
%pilbk=plot(-onset(ilbk),dists(ilbk),'ro','MarkerFaceColor',collbk,'MarkerSize',10);
%pikor=plot(-onset(ikor),dists(ikor),'rd','MarkerFaceColor',colkor,'MarkerSize',6);
%pitrb=plot(-onset(itrb),dists(itrb),'rs','MarkerFaceColor',coltrb,'MarkerSize',4);

pos=get(gca,'position');
set(gca,'position',pos.*[1 1 1.1 1]);

diffedge=500;
edge=0:diffedge:4500;
nedge=length(edge);
pcvals=[0.05 0.5 0.95];

for ip=1:3
  pcval=pcvals(ip);
  pcd=[];

  for iedge=2:nedge
    ibin=find(sdists>=edge(iedge-1) & sdists<=edge(iedge));
    pcd(iedge)=cl_quantile(stime(ibin),pcval);
  end
  pedge=reshape(repmat(edge,2,1),1,2*nedge);
  pcd=reshape(repmat(pcd,2,1),1,2*nedge);

  pcd=pcd(3:end);
  pedge=pedge(2:end-1);
  pc1(ip)=plot(-pcd,pedge,'b-','LineWidth',5,'visible','on');
end

for ip=1:3
  pcr=[];
  pcval=pcvals(ip);

  for iedge=2:nedge
    ibin=find(dists>=edge(iedge-1) & dists<=edge(iedge) & isfinite(onset));
    pcr(iedge)=cl_quantile(onset(ibin),pcval);
  end
  pedge=reshape(repmat(edge,2,1),1,2*nedge);
  pcr=reshape(repmat(pcr,2,1),1,2*nedge);

  pcr=pcr(3:end);
  pedge=pedge(2:end-1);
  pc3(ip)=plot(-pcr+20,pedge+20,'r-','LineWidth',5,'visible','on');
end

set([pc1([2,3]),pc3([2,3])],'visible','off');

% 
% mhstime=zeros(nedge,1)-NaN;
% mhsdist=mhstime;
% [shistc,shistb]=histc(stime,edge);
% for i=1:nedge
%    mhstime(i)=mean(stime(shistb==i));
%    mhsdist(i)=mean(sdists(shistb==i));
% end


%if isnan(mhstime(nedge)) mhstime(nedge)=timelim(2); end
%if isnan(mhsdist(nedge)) mhsdist(nedge)=mhsdist(nedge-1); end

% pstairs=stairs(-mhstime+diffedge/2.0,mhsdist+diffedge/2.0,'b-','LineWidth',4);
% 
% mhtime=zeros(nedge,1)-NaN;
% mhdist=mhtime;
% [rhistc,rhistb]=histc(onset,edge);
% for i=1:nedge
%    if rhistc(i)==0; continue; end
%    mhtime(i)=mean(onset(rhistb==i));
%    mhdist(i)=mean(dists(rhistb==i));
% end
% pstairr=stairs(-mhtime+diffedge/2.0,mhdist+diffedge/2.0,'r-','LineWidth',4);


%pirppn=plot(-stime(irppn),sdists(irppn),'bs','MarkerFaceColor',colppn,'MarkerSize',4);
%pirkor=plot(-stime(irkor),sdists(irkor),'bs','MarkerFaceColor',colkor,'MarkerSize',4);
%pirtrb=plot(-stime(irtrb),sdists(irtrb),'bs','MarkerFaceColor',coltrb,'MarkerSize',4);
%pirlbk=plot(-stime(irlbk),sdists(irlbk),'bs','MarkerFaceColor',collbk,'MarkerSize',4);
 
%    'LBK sites','TRB sites','LBK regions','Site regression','Simulation regression',...
%    'Site histogram','Simulation histogram');
l=legend([p1,p3,p4,p5,pc1,pc3],'Radiocarbon sites','Simulation regions','Site regression','Simulation regression',...
    'Site staircase fit','Simulation staircase fit');
set(l,'location','Northwest','visible','off');

[cr1,cp1]=corrcoef(onset(itv),dists(itv));
[cr2,cp2]=corrcoef(stime,sdists);
%set(gca,'YLim',[0 4000]);

%ytl=get(gca,'YTickLabel');
%ytl(1,:)=' ';
%set(gca,'YTickLabel',ytl);

%l=legend([p1,p2],sprintf('Site data (n=%d, r^2=%.2f, v=%.2f km a^{-1})',length(viscol),cr2(2).^2,-pf2(1)),...
%    sprintf('Simulation (n=%d, r^2=%.2f, v=%.2f km a^{-1})',length(itv),cr1(2).^2,-pf1(1)),...
%    'location','NorthWest','FontSize',7);
%l=legend([p1,p2,p3],'Radiocarbon dated sites','Simulation regions','Focus regions');
%set(l,'location','NorthWest','FontSize',13);


fprintf('Site data (n=%d, r^2=%.2f, v=%.2f km a^{-1})',length(stime),cr2(2).^2,-pf2(1));
fprintf('Simulation (n=%d, r^2=%.2f, v=%.2f km a^{-1})',length(itv),cr1(2).^2,-pf1(1));

%set(l,'color','none');

%offsets=100*[0 1 -1 1 -1 0 0 0 0 0];
%for i=1:nhreg
 % t1(i)=text(-onset(ihreg(i)),-200+offsets(i),letters(i),'Horizontal','center','FontName','Times','FontSize',14);
%e%nd

cl_print('name','ammerman_rgb','ext','png','res',[300,600]);
cl_print('name','ammerman_rgb','ext','pdf');


%% Do black and white version
%set(p3,'MarkerFaceColor',repmat(0.5,3,1),'Color',repmat(0.5,3,1));
%set([p2,p1,p4],'Color',repmat(0,3,1));
%set(p2,'MarkerFaceColor',repmat(0,3,1));
%plot_multi_format(1,'ammerman_bw','pdf');

end



if (0==6)
  %clp_spread_mechanism('file','../../../../Downloads/eurolbk_0.0020000_0000100.10_000.200000_.log');
  %clp_spread_mechanism('file','../../../../Downloads/eurolbk_0.0000002_1638400.16_000.327680_.log');
  %clp_spread_mechanism('file','../../../../Downloads/eurolbk_0.0080000_0000000.00_000.000000_.log');
  clp_spread_mechanism('file','../../eurolbk_base.log');
  clp_spread_mechanism('file','../../eurolbk_cultural.log');
  clp_spread_mechanism('file','../../eurolbk_demic.log');
  
end


return

%% Do non-uniform spread
%movdists=movavg(onset(itv),dists(itv),500,1);
%[sorton,isorton]=sort(onset(itv));
%figure(2); clf reset;
%plot(sorton,movdists(isorton),'r-');
%pf3=polyfit(-onset(itv),dists(itv),3);
%p5=plot(-gtime,(-gtime).^3*pf3(1)+(-gtime).^2*pf3(2)+-gtime*pf3(3)+pf3(4),'r-','LineWidth',2);






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



