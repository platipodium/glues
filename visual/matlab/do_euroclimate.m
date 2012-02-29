%% User section, please adjust
% Run script for euroclim papers about sensitivity of transition to climate events in Europe
% Carsten Lemmen 2012-02-20

% What Neolithic site dataset to use
datastrings={'Pinhasi','Turney','Vanderlinden','Fepre'};
datastring=datastrings{1};

% What proxy file to use
proxyfile='proxydescription_258_128.csv';

% Define regional and temporal limitation
reg='ecl'; [ireg,nreg,loli,lali]=find_region_numbers(reg);

lonlim=loli; latlim=lali;
timelim=[-7000 -3000];

% Highlight certain regions
hreg=[271 255  211 183 178 170 146 142 123 122];
nhreg=length(hreg);

% Define base directory and scenarios
predir='/Users/lemmen/devel/glues';
basename='euroclim';
sces=0.0:0.1:1.0;

%--------------------------------------------------------------------------------
%% preparatory color, symbol and file handling 

letters='ABCDEFGHIJKLMNOPQRSTUVW';
letters=letters(1:nhreg);

sites=cl_read_neolithic(datastring,[-12000 0],lonlim,latlim);
matfile=strrep(proxyfile,'.csv','.mat');
if ~exist('matfile','file');
  evinfo=read_textcsv(proxyfile);
else
  load(matfile); % into struct evinfo
end

% Load events in region
evregionfile=sprintf('EventInReg_128_685.tsv');
evinreg=load(evregionfile,'-ascii');

evinreg=evinreg(ireg,:);
[ev,ievs]=unique(evinreg);
nev=length(ev);

lg=repmat(0.8,1,3);
mg=repmat(0.55,1,3);
dg=repmat(0.3,1,3);

%---------------------------------------------------------------------
% Decide which plots to make
% 1: proxy location, region, and sites map
doplots=[8];

%---------------------------------------------------------------------
%% Figure 1: map of regions and Proxy locations and Neolithic sites
if any(doplots==1)

 % lali=cl_minmax(evinfo.Latitude(ev))+[-1 1];
 % loli=cl_minmax(evinfo.Longitude(ev))+[-1 1];
  loli=loli+5*[-1 1];
  lali=lali+5*[-1 1];
 
  [data,basename]=clp_nc_variable('lat',lali,'lon',loli,'var','region','marble',2,'transparency',1,'nocolor',0,...
      'showstat',0,'showtime',0,'fontsize',15,'showregion',0,...
      'file',fullfile(predir,sprintf('%s_%.1f.nc',basename,sces(1))),'figoffset',0,'noprint',1,'notitle',1);

  valid=find(data.handle>0);
  set(data.handle(valid),'FaceColor',lg,'EdgeColor',mg,'EdgeAlpha',1,'FaceAlpha',0.3);

  hold on;
  pl=m_plot(lonlim([1 2 2 1 1]),latlim([1 1 2 2 1]),'k--');
  set(pl,'LineWidth',4,'Color',mg);
  
  ps=m_plot(sites.longitude,sites.latitude,'ko','MarkerFaceColor',mg,'MarkerEdgeColor','none');
  set(ps,'MarkerSize',2);

  for i=1:nev
    plon=evinfo.Longitude(ev(i));
    plat=evinfo.Latitude(ev(i));
    [plon plat]=distribute_around(plon,plat,2,1.2);
    switch(ev(i))
        case {57,69,79}, plon=plon-2.5;
        case {89,49,81,61}, plon=plon+2.5;
      otherwise;
    end
    pp(i)=m_plot(plon(1),plat(1),'k^','MarkerSize',7,'MarkerFacecolor',dg);
    pt(i)=m_text(plon(2),plat(2),num2str(evinfo.No(ev(i))),'Vertical','middle',...
        'horizontal','center');
  end
  cb=findobj(gcf,'-property','Location');
  delete(cb);
  uistack(ps,'top');
  uistack(pt,'top');
  cl=legend([pl pp ps],'Focus area','Proxy locations','Neolithic sites');
  set(cl,'Location','East');
  clpos=get(cl,'Position');
  [x y]=m_ll2xy(lonlim,latlim);
  set(cl,'Position',clpos + [0.31+x(2)-clpos(1) 0 0 0]);
  
  cl_print('name','region_map_sites_proxies','ext','pdf');%,'res',[150 300 ]);
end

%--------------------------------------------------------------------------
%% Figure 2 from clP_event and cl_eventdensity.m

% Get all peaks from events
np=length(evinfo.No);
peakinfo=zeros(np*8,4);
off=0;
for ip=1:np
  peakt=1950-1000*evinfo.time{ip}(evinfo.peakindex{ip});
  peakn=length(peakt);
  peakr=1+off:peakn+off;
  peakinfo(peakr,1)=peakt;
  peakinfo(peakr,2)=ip;
  peakinfo(peakr,3)=evinfo.Longitude(ip);
  peakinfo(peakr,4)=evinfo.Latitude(ip);
  off=off+peakn;
end
peakinfo=peakinfo(1:off,:);


%--------------------------------------------------------------------------
%% Figure 3
% maps of farming at different times for scenario X (todo) , also movie
if any(doplots==-3) 
  movtime=-3000:-500:-7500;
  nmovtime=length(movtime);
  sce='0.4';
  for it=1:nmovtime
    [d,b]=clp_nc_variable('var','farming','reg',reg,'marble',2,'transparency',1,'nocolor',0,...
      'showstat',0,'lim',[0 1],'timelim',movtime(it),...
      'file',['../../euroclim_' sce '.nc'],'figoffset',0,'sce',[sce '_' sprintf('%05d',movtime(it))],'noprint',1);
    m_coast('color','k');
    %m_grid('box','off','linestyle','none');
    peaki=find(abs(peakinfo(:,1)-movtime(it))<=175);
    for j=1:length(peaki)
      clp_pulse(peakinfo(peaki(j),3),peakinfo(peaki(j),4)); 
    end
    
    sitei=find(sites.time<movtime(it));
    if ~isempty(sitei) 
      m_plot(sites.longitude(sitei),sites.latitude(sitei),'k^');
    end
    
    title('GLUES agropastoral activity');
    cb=findobj(gcf,'tag','colorbar')
    ytl=get(cb,'YTickLabel');
    ytl=num2str(round(100*str2num(ytl)));
    set(cb,'YTickLabel',ytl);
    title(cb,'%');
    cm=get(cb,'Children');
    cmap=get(cm,'CData');
    ct=findobj(gcf,'-property','FontName');
    set(ct,'Fontname','Times');
  
    cl_print('name',b,'ext',{'png','eps'},'res',300);
  end
end
if any(doplots==33) 
  movtime=-7500:50:-3000;
  nmovtime=length(movtime);
  sce='0.4';
  for it=1:nmovtime
    [d,b]=clp_nc_variable('var','farming','reg',reg,'marble',2,'transparency',1,'nocolor',0,...
      'showstat',0,'lim',[0 1],'timelim',movtime(it),...
      'file',['../../euroclim_' sce '.nc'],'figoffset',0,'sce',[sce '_' sprintf('%03d_%05d',it,movtime(it))],'noprint',1);
    m_coast('color','k');
    m_grid('box','fancy','linestyle','none');
    peaki=find(abs(peakinfo(:,1)-movtime(it))<=25);
    for j=1:length(peaki)
      clp_pulse(peakinfo(peaki(j),3),peakinfo(peaki(j),4)); 
    end

    sitei=find(sites.time<movtime(it));
    if ~isempty(sitei) 
      m_plot(sites.longitude(sitei),sites.latitude(sitei),'k^');
    end

    title('GLUES agropastoral activity');
    cb=findobj(gcf,'tag','colorbar')
    ytl=get(cb,'YTickLabel');
    ytl=num2str(round(100*str2num(ytl)));
    set(cb,'YTickLabel',ytl);
    title(cb,'%');
    cm=get(cb,'Children');
    cmap=get(cm,'CData');
  
    cl_print('name',b,'ext','png','res',100);
  end
  % Command line postprocessing
  %mencoder mf://farming_lbk_66_0.4_*.png  -mf w=800:h=600:fps=5:type=png -ovc lavc -lavcopts vcodec=mpeg4:mbd=2:trell -oac copy -o output.avi
end

% Nice pastel maps of farming timing
if any(doplots==4)
  %% plot farming timing for all scenarios 
  ncol=8;
  cmap=flipud(vivid(ncol));
  iscol=floor((sites.time-min(timelim))./(timelim(2)-timelim(1))*ncol)+1;
  iscol(iscol<1)=1;
  viscol=find(iscol<=ncol);

  for s=0.4:0.4:0.4
    figure(2); clf;
    sce=sprintf('%3.1f',s);
    file=['../../euroclim_' sce '.nc'];
    [data,basename]=clp_nc_variable('var','farming','threshold',0.5,'reg','lbk','marble',2,'transparency',1,'nocolor',0,...
      'showstat',0,'timelim',[-7500 -3500],'showtime',0,'flip',1,'showvalue',0,...
      'file',file,'figoffset',0,'sce',sce,...
      'noprint',1,'notitle',1,'ncol',ncol,'cmap','vivid');
%'noprint',1,'notitle',1,'ncol',ncol,'cmap','clc_eurolbk');

    hdf=findobj(gcf,'-property','EdgeColor','-and','-property','FaceColor');
    nh=length(hdf);
    fcc=get(hdf,'FaceColor');
    fc=zeros(nh,3)*1.0;

    for ih=1:nh
      fc(ih,:)=double(fcc{ih});
    end
    hdf=hdf(find(sum(fc)>0));
    
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
    cc=get(cb2,'Children');
    if iscell(cc) 
      for ic=1:length(cc) 
        set(cc{ic},'AlphaData',1); 
    
      end 
    else    set(cc,'AlphaData',1); end
    ytt=get(cb2,'Title');
    if iscell(ytt) ytt=ytt{1}; end
    set(ytt,'String','');
    pos=get(cb,'Position');
    
    if iscell(pos)
        for ic=1:length(pos) set(cb2,'Position',pos{ic}.*[1 1 0.5 1],'YTick',[],'box','off'); end
    else
       set(cb2,'Position',pos.*[1 1 0.5 1],'YTick',[],'box','off');
    end
    
    ps=0;
    for i=1:length(viscol)
        mcolor=cmap(iscol(viscol(i)),:);
        ps(i)=m_plot(sites.longitude(viscol(i)),sites.latitude(viscol(i)),'k^','MarkerFaceColor',mcolor,...
            'MarkerEdgeColor',cmap(iscol(viscol(i)),:),'MarkerSize',4);
    end
    
    ct=findobj(gcf,'-property','FontName');
    set(ct,'FontSize',14,'FontName','Times','FontWeight','normal');
    
    
    for ir=1:-nhreg
        m_text(lon(hreg(ir)+1),lat(hreg(ir)+1),letters(ir),'background','w',...
            'Horizontal','center','Vertical','middle');
    end
    m_coast('color','k');
    m_grid('box','on','linestyle','none');
    %title(['EuroClim experiment with fluc=' sce ]);
    cl_print('name',strrep(basename,'farming_','timing_'),'ext','png','res',[150,600]);
  end % of for loop
end




% Read default scenario
file=fullfile(predir,['euroclim' '_0.4.nc']);
if ~exist(file,'file'); error('File does not exist'); end
ncid=netcdf.open(file,'NOWRITE');
  varid=netcdf.inqVarID(ncid,'region');
  id=netcdf.getVar(ncid,varid);
  varid=netcdf.inqVarID(ncid,'time');
  time=netcdf.getVar(ncid,varid);
  itime=find(time>=timelim(1) & time<=timelim(2));
  varid=netcdf.inqVarID(ncid,'farming');
  farming=netcdf.getVar(ncid,varid);
  varid=netcdf.inqVarID(ncid,'latitude');
lat=double(netcdf.getVar(ncid,varid)); % need to be corrected
  varid=netcdf.inqVarID(ncid,'longitude');
lon=double(netcdf.getVar(ncid,varid)); % need to be corrected
  varid=netcdf.inqVarID(ncid,'area');
  area=double(netcdf.getVar(ncid,varid));
  netcdf.close(ncid);
  
 timing=cl_nc_timing('file',file,'threshold',0.5,'timelim',timelim);
 
  
oldnreg=nreg;
load('regionpath_685');
lat=regionlat;
lon=regionlon;
nreg=oldnreg;





% difference plot
if any(doplots==5)
  timelim=[-8500,-3500];
  
    nsce=length(sces);

  fluctiming=zeros(685,nsce);
  for isce=1:nsce
    file=fullfile(predir,sprintf('%s_%.1f.nc',basename,sces(isce)));
    if ~exist(file,'file') continue; end
    fluctiming(:,isce)=cl_nc_timing('file',file,'threshold',0.5,'timelim',timelim);
  end
  
  t4=fluctiming(:,5);
  t0=fluctiming(:,1);
  
  load('regionpath_685');
  lat=regionlat;
  lon=regionlon;
  nreg=length(ireg);
  
  rlat=lat(272); rlon=lon(272);
  sdists=cl_distance(sites.longitude,sites.latitude,rlon,rlat);  
  rdists=cl_distance(lon(ireg),lat(ireg),rlon,rlat);
  
  [r0 p0]=corrcoef(rdists,t0(ireg))
  [r4 p4]=corrcoef(rdists,t4(ireg))
  l0=polyfit(t0(ireg),rdists,1)
  l4=polyfit(t4(ireg),rdists,1)
  
  figure(1); clf; hold on;
  
  cmap=jet(nreg);
  ilat=ceil(nreg*(lat(ireg)-latlim(1))/(latlim(2)-latlim(1)));
  ilat(ilat<1)=1;
  ilat(ilat>nreg)=nreg;
  
  idist=ceil(nreg*(rdists-min(rdists))/range(rdists));
  idist(idist<1)=1; idists(idist>nreg)=nreg;
  
  
  plot(t0(ireg),t4(ireg),'k.');
  limits=[ min([t0(ireg) t4(ireg)]) ,max([t0(ireg) t4(ireg)])];
  plot(limits,limits,'k-');
  for ir=1:nreg
    plot(t0(ireg(ir)),t4(ireg(ir)),'r.','color',cmap(idist(ir),:));      
  end
  xlabel('Timing without events');
  ylabel('Timing with events');
  
  
  figure(2); clf; hold on;
  
  cmap=jet(nsce);
  for isce=1:nsce
    %plot(rdists,fluctiming(ireg,isce)-fluctiming(ireg,1),'k.','color',cmap(isce,:));
  end
  
  
  dtiming=fluctiming(ireg,5)-fluctiming(ireg,1);
  plot(rdists,fluctiming(ireg,5)-fluctiming(ireg,1),'k.');

  
  
  nn=zeros(nreg,length(sites.latitude));
  nd=nn;
  for ir=1:nreg
    dists=cl_distance(sites.longitude,sites.latitude,lon(ireg(ir)),lat(ireg(ir)));
    [sdists,isort]=sort(dists);
    nn(ir,:)=isort;
    nd(ir,:)=sdists;
  end
 
  % Calculate neighbour weight
  radius=250;
  nw = exp(-nd/radius);
  nw(nd>2*radius)=0;
  
  stiming=fluctiming(ireg,5)+inf;
    for ir=1:nreg
      ivalid=find(isfinite(sites.time(nn(ir,:))));
      sw(ir) = sum(nw(ir,ivalid),2);
      stiming(ir)=sum(nw(ir,ivalid).*sites.time(nn(ir,ivalid))')./sw(ir);
      sdist(ir)=sum(nw(ir,ivalid).*nd(ir,ivalid));
    end
    
    dt=2*radius;
  figure(3); clf; hold on;
   p1=plot(stiming,stiming,'k-');
   p2=plot(stiming,fluctiming(ireg,1),'ks');
   p3=plot(stiming,fluctiming(ireg,5),'rs');
   ivalid=find(isfinite(fluctiming(ireg,5)) & isfinite(fluctiming(ireg,1)) ...
       & isfinite(stiming) & stiming<timelim(2)+dt & stiming>timelim(1)-dt...
       & fluctiming(ireg,5) < timelim(2)+dt & fluctiming(ireg,5) >timelim(1)-dt ...
       & fluctiming(ireg,1) < timelim(2)+dt & fluctiming(ireg,1) >timelim(1)-dt ...       
       & (lon(ireg)'<32 | lat(ireg)'>38) );
 
    clf;    hold on;
    t4d=abs(stiming(ivalid)-fluctiming(ireg(ivalid),5));
    t0d=abs(stiming(ivalid)-fluctiming(ireg(ivalid),1));
    edges=[0 200 400 600 800 1000 1333 1666 2000 inf]
    [h4,hd4]=hist(t4d,edges);
    [h1,hd0]=hist(t0d,edges);
    ph4=bar(hd4,h4);
    ph1=bar(hd0,h1,'FAcecolor','none','edgecolor','r','linewidth',4);
    median(t4d);
     
     
    m4=median(stiming(ivalid)-fluctiming(ireg(ivalid),5))
    m0=median(stiming(ivalid)-fluctiming(ireg(ivalid),1))
     
    figure(2); clf; hold on
    plot(fluctiming(ireg(ivalid),5),stiming(ivalid),'r.');
    plot(fluctiming(ireg(ivalid),1),stiming(ivalid),'k.');
    limit=timelim+dt*[-1 1];
    set(gca,'xlim',limit,'ylim',limit);
    plot(limit,limit,'k--');
     
    
   [r4,p4]=corrcoef(fluctiming(ireg(ivalid),5),stiming(ivalid))
   [r0,p0]=corrcoef(fluctiming(ireg(ivalid),1),stiming(ivalid))
 
   
   fprintf('Ref %.0f %.0f %.2f\n',m0,median(t0d),r0(2,1));
   fprintf('Sce %.0f %.0f %.2f\n',m4,median(t4d),r4(2,1));
   
   
   system('/opt/local/bin/ncdiff -O -v farming_timing ../../euroclim_0.4.nc ../../euroclim_0.0.nc ../../euroclim_diff.nc && /opt/local/bin/ncks -A -v latitude,longitude ../../euroclim_0.4.nc ../../euroclim_diff.nc');
   
   [data,basename]=clp_nc_variable('var','farming_timing','reg',reg,'marble',0,'transparency',0,'nocolor',0,...
      'showstat',0,'lim',[-500 500],'showtime',0,'flip',1,'showvalue',0,...
      'file',strrep(file,'1.0','diff'),'figoffset',0,'sce',sce,...
      'noprint',1,'notitle',1,'ncol',11,'cmap','hotcold');
  cl_print('name','euroclim_diff','ext','pdf');
   
end

eventregtime=load('../../eventregtime.tsv','-ascii');
eventregtime(eventregtime<0)=NaN;


if any(doplots==6) 
    
    hreg=243;
    ir=find(ireg==hreg);
    
    isce=5;
    file=fullfile(predir,sprintf('%s_%.1f.nc','euroclim',sces(isce)));
 
    clp_nc_trajectory('var','farming','file',file,'timelim',timelim,'reg',ireg(ir),...
        'nosum',1,'noprint',1);
    ylimit=get(gca,'YLim');
    plot(1950-eventregtime(ireg(ir),:),0.9*ylimit(2),'kv','MarkerSize',10,'MarkerFaceColor','r');
    
    
    set(gca,'YScale','log');
    
    figure(6); clf; hold on;
   n=0;
   for ir=1:nreg
      itrans=find(farming(ireg(ir),:)>0.041 & farming(ireg(ir),:)<0.9);
      if isempty(itrans) continue; end
      ttrans=time(itrans);
      ert=1950-eventregtime(ireg(ir),:);
      iin=find(ert>min(ttrans) & ert<max(ttrans));
      if ~isempty(iin)
        clf; hold on;
        set(gca,'YScale','log');
        plot(time,farming(ireg(ir),:),'k:');
        plot(ttrans,farming(ireg(ir),itrans),'r-');
        title(num2str(ireg(ir)));
        plot(ert,0.5,'kv','MarkerSize',10,'MarkerFaceColor','r');
        pause(-1);
        n=n+1;
        transreg(n)=ireg(ir);
        itransreg(n)=ir;
        cl_print('name',sprintf('transition_with_event_%03d',ireg(ir)),'ext','pdf');
      end
    end
      
    % in 26 regions this occurs
    [data,basename]=clp_nc_variable('var','farming_timing','reg',reg,'marble',0,'transparency',0,'nocolor',0,...
      'showstat',0,'lim',[0 1000],'showtime',0,'flip',1,'showvalue',0,...
      'file',strrep(file,'0.4','diff'),'figoffset',0,'sce',sce,...
      'noprint',1,'notitle',1,'ncol',11,'cmap','hotcold');
  
  
  
  
    hdl=data.handle;
    hdl=hdl(hdl>0);
    mg=repmat(0.5,1,3);
    %set(hdl,'EdgeColor',mg,'EdgeAlpha',1);
  
    hdl=data.handle(itransreg);
    hdl=hdl(hdl>0);
    set(hdl,'EdgeColor','k','EdgeAlpha',1,'LineWidth',6);

    
end



if any(doplots==7)
   

    plotvars={'farming','population_density','migration_density','technology'};
    plotsces=[1 5];
    
    for isce=plotsces
      for ivar=1:length(plotvars)
      file=fullfile(predir,sprintf('%s_%.1f.nc','euroclim',sces(isce)));
     
      [d b]=clp_nc_trajectory('var',plotvars{ivar},'file',file,'timelim',timelim,'reg',ireg,...
        'nosum',1,'noprint',0,'timelim',timelim,...
        'sce',sprintf('%.1f',sces(isce)));
  
    end 
    [d b]=clp_nc_trajectory('var','migration_density','file',file,'timelim',timelim,'reg',ireg,...
        'nosum',1,'noprint',0,'timelim',timelim,'div','population_density',...
        'sce',sprintf('%.1f',sces(isce)));
   [d b]=clp_nc_trajectory('var','migration_density','file',file,'timelim',timelim,'reg',ireg,...
        'nosum',1,'noprint',0,'timelim',timelim,'mult','area',...
        'sce',sprintf('%.1f',sces(isce)));
end
   

 
end



%---------------------------------------------------------------------------------

%% Chapter 2: calculate correlation and plot scatter between data and model
if any(doplots==8)

  load('regionpath_685');
  lat=regionlat;
  lon=regionlon;
  nreg=length(ireg);
    
  radius=250;
  nsites=length(sites.lat);
  nn=zeros(nreg,nsites);
  nd=nn;

  if ~exist('distance_matrix.mat','file') 
  for ir=1:nreg
    rlat=lat(ireg(ir)); rlon=lon(ireg(ir));
    esd=cl_esd(regionpath(ireg(ir),:,1),regionpath(ireg(ir),:,2));
    dists=cl_distance(sites.longitude,sites.latitude,rlon,rlat)-esd/2;  
    %dists(dists<0)=0;
    %dists(dists>250)=inf;
    [sdists,isort]=sort(dists);
    nn(ir,:)=isort;
    nd(ir,:)=sdists;
  end
    save('-v6','distance_matrix','nn','nd');
  else
      load('distance_matrix');
  end
  
  % Calculate neighbour weight
  nd(nd<0)=0;
  nd(nd>0)=inf;
  nw = exp(-nd/radius);
  ns=sum(nd<=radius,2);
  
%   figure(1); clf reset;
%   clp_basemap('latlim',latlim,'lonlim',lonlim);
%   m_plot(lon(ireg),lat(ireg),'kd');
%   m_plot(lon(ireg(ns>2)),lat(ireg(ns>2)),'kd','MarkerFaceColor','k');
%   
%   
%   hold on;
%   m_plot(sites.lon,sites.lat,'k.','color',[0.8 0.8 0.8]);
%   m_plot(sites.lon(nn(find(nd<radius))),sites.lat(nn(find(nd<radius))),'ko');
  
  rpmatrix=zeros(length(sces),2)+NaN;
  
  figure(2); clf reset;
  figure(3); clf reset;

  scecolors=jet(11);
  
  for isce=[1 5] %length(sces):-1:1
    file=fullfile(predir,[basename sprintf('_%.1f.nc',sces(isce))]);
    if ~exist(file,'file'); continue; end
    
    ncid=netcdf.open(file,'NOWRITE');
    varid=netcdf.inqVarID(ncid,'farming');
    farming=netcdf.getVar(ncid,varid);
    varid=netcdf.inqVarID(ncid,'farming_timing');
    timing=netcdf.getVar(ncid,varid);
    netcdf.close(ncid);
   
    sdist=[];
    timing=timing(ireg);
    stiming=timing+inf;
    transtime=zeros(nreg,11);
    stranstime=transtime;
    for ir=1:nreg
      sw(ir) = sum(nw(ir,1:ns(ir)),2);
      stiming(ir)=sum(nw(ir,1:ns(ir)).*sites.time(nn(ir,1:ns(ir)))')./sw(ir);
      sdist(ir)=sum(nw(ir,1:ns(ir)).*nd(ir,1:ns(ir)));
      itrans=min(find(farming(ireg(ir),:)>0.041)):min(find(farming(ireg(ir),:)>=0.95));
      
      
      if max(farming(ireg(ir),:))<0.5 | isempty(itrans)
          transtime(ir,isce)=inf;  
      else
           transtime(ir,isce)=range(cl_minmax(time(itrans)));
      end
      if ns(ir)<9
        stranstime(ir,isce)=inf;
      else
      stranstime(ir,isce)=std(sites.time(nn(ir,1:ns(ir))));
      end
    end
  
    
      figure(2); hold on;
      plot(transtime(:,isce),stranstime(:,isce)+isce,'k.','color',scecolors(isce,:));
    xlabel('Simulated transition time');
    ylabel('Observed transition time');
    set(gca,'Xlim',[0 1500],'Ylim',[0 1500]);
    valid=find(transtime(:,isce)<1500 & stranstime(:,isce)<1500);
    b=polyfit(transtime(valid,isce),stranstime(valid,isce),1);
    plot(transtime(valid,isce),transtime(valid,isce)*b(1)+b(2),'m-','color',scecolors(isce,:));
    [r,p]=corrcoef(transtime(valid,isce),stranstime(valid,isce))
    axis square;
    
    
    
    
    timelim=[-8000 3500]
       dt=2*radius;
   %ivalid=find(isfinite(stiming) & stiming<timelim(2)+dt & stiming>timelim(1)-dt...
   %    & timing < timelim(2)+dt & timing >timelim(1)-dt   ... %;%...       
   %    & (lon(ireg)<32 | lat(ireg)>38 ) );
    ivalid=find(isfinite(stiming) & isfinite(timing) & timing<timelim(2)+dt ...
         &  (lon(ireg)'<30 | lat(ireg)'>38 ) );
    
    
    timing=timing;
    stiming=stiming;
    
    
    [b]=polyfit(timing(ivalid),stiming(ivalid),1);
    
    figure(2+isce); clf;
    hold on;
    p1=plot(timing(ivalid),timing(ivalid),'k-');
    p1a=plot(timing(ivalid),timing(ivalid)*b(1)+b(2),'r-');
    p2=plot(timing(ivalid),stiming(ivalid),'ks');
    %ivalid=isfinite(timing) & isfinite(stiming);
    
    [r,p]=corrcoef(timing(ivalid),stiming(ivalid));
    rpmatrix(isce,1:2)=[r(2,1) p(2,1)];
    
    for ir=1:nreg
       if isempty(find(ir==ivalid)) continue; end
       p3(ir)=plot(repmat(timing(ir),1,2),repmat(stiming(ir),1,2)+0.1*[-1 1].*repmat(sdist(ir),1,2),'k-','color',repmat(0.8,1,3));
    end
    
    ltext={sprintf('R=%.2f',rpmatrix(isce,1)),'indicative distance uncertainty'};
    legend(ltext)
    
    xlabel(sprintf('Simulated timing of farming>%.1f',0.5));
    ylabel(sprintf('Radiocarbon dates from %s (cal AD)',datastring));
    title(sprintf('Model-data comparison for fluctuation intensity %.1f',sces(isce)));
    
    
    
    
      pfile=fullfile(predir,[basename strrep(sprintf('_%.1f_correlation_%s',sces(isce),datastring),'.','-')]);
      if exist([pfile '.png'],'file');
        fdir=dir(file);
        pdir=dir([pfile '.png']);
       % if datenum(fdir.date)<datenum(pdir.date) continue; end;
      end
      
      
    cl_print(gcf,'name',pfile,'ext','png');
    
    
end
end

dtranstime=transtime(:,5)-transtime(:,1);
ivalid=find(isfinite(dtranstime));




tlim=clp_nc_trajectory('file','../../test.nc','var','temperature_limitation','reg',ireg(ivalid),'timelim',[-inf inf]);
population=clp_nc_trajectory('file','../../test.nc','var','population_density','reg',ireg(ivalid),'timelim',[-inf inf]);
natfert=clp_nc_trajectory('file','../../test.nc','var','natural_fertility','reg',ireg(ivalid),'timelim',[-inf inf]);
actfert=clp_nc_trajectory('file','../../test.nc','var','actual_fertility','reg',ireg(ivalid),'timelim',[-inf inf]);
si=clp_nc_trajectory('file','../../test.nc','var','subsistence_intensity','reg',ireg(ivalid),'timelim',[-inf inf]);
npp=clp_nc_trajectory('file','../../test.nc','var','npp','reg',ireg(ivalid),'timelim',[-inf inf]);



%% Chapter 3: plot European time series and map with locations
print a
if any(doplots==3)
  load('holodata.mat');
  dirs.total='~/projects/glues/m/holocene/redfit/data/eleven';
  dirs.red='/h/lemmen/projects/glues/m/holocene/redfit/data/output/repl_5.5_0.5_eleven';

  lg=repmat(0.5,1,3);

  ip=find(holodata.Latitude>=latlim(1) & holodata.Latitude<=latlim(2) ...
    & holodata.Longitude>=lonlim(1) & holodata.Longitude<=lonlim(2));
  nip=length(ip);
  plotcolors=jet(nip);
  isort=reshape([1:nip/2 ; nip/2+1:nip],1,nip)
  plotcolors=plotcolors(isort,:);
  
  figure(5); clf reset; hold on;
  set(5,'Position',[124         114        1054         587]);
  clp_basemap('latlim',latlim,'lonlim',lonlim);
  set(gca,'Fontsize',9,'color',lg,'xcolor',lg,'ycolor',lg);
  clp_relief;
  m_plot(holodata.Longitude(ip),holodata.Latitude(ip),'ko','MarkerFaceColor','k');
  m_grid('color',lg,'fontSize',10);
  ax0=gca;
  set(gca,'xcolor',lg,'ycolor',lg,'color',lg,'FontSize',10);
  pos=get(ax0,'Position');
    
  [px,py]=m_ll2xy(holodata.Longitude(ip),holodata.Latitude(ip),'clip','on');
  [lx,ly]=m_ll2xy(lonlim,latlim);
  dlx=lx(2)-lx(1);
  dly=ly(2)-ly(1);
  %m_plot(sites.lon,sites.lat,'k.','color',[0.8 0.8 0.8]);
  %m_plot(sites.lon(nn(find(nd<radius))),sites.lat(nn(find(nd<radius))),'ko');

  
  for ipi=1:nip
    figure(6); clf reset;
    [p,f,e]=fileparts(holodata.Datafile{ip(ipi)});
    tsfile=fullfile(dirs.total,[f e]);
    tlim=abs((fliplr(timelim)-1950)/1000.0);
  
    data=clp_single_timeseries_trend(ip(ipi),'timelim',tlim);
  
    interpret=holodata.Interpret{ip(ipi)};
    yl=sprintf('%s %s',holodata.Proxy{ip(ipi)});
    if ~strmatch(interpret,'?') yl=sprintf('%s (%s)',yl,interpret); end
    ylabel(yl);
    set(gca,'YColor',plotcolors(ipi,:),'color','none','XColor','k');
  
    cl=findobj(gca,'color','r');
    set(cl,'color',plotcolors(ipi,:));
  
    cl=findobj(gcf,'tag','legend')
    %set(cl,'visible','off');

    ct=findobj(gcf,'color','b');
    %set(ct,'visible','off');
  
    cp=findobj(gcf,'Marker','diamond');
    %set(cp,'MarkerFaceColor','y','MarkerEdgeColor','k','visible','off');
  
    set(gca,'Xlim',tlim+0.5*[-1 1],'YAxis','left');
  
    ylim=get(gca,'Ylim');
    %hb=patch([8.350 8.050 8.050 8.350],[ylim(1) ylim(1) ylim(2) ylim(2)],lg);
    %alpha(hb,0.5);
    %set(hb,'EdgeColor','none');
 
  
    %cl_print(6,'name',sprintf('proxy_timeseries_%s',f),'ext','pdf');
    %matlab2tikz(sprintf('proxy_timeseries_%s.tex',f));
  
    
    figure(6);clf;
    fs=20;
    set(gcf,'Position',[ 360   546   518   152]);
    plot(data.ut,cl_normalize(data.m50),'b-','color',plotcolors(ipi,:),'LineWidth',5);
    set(gca,'xcolor',plotcolors(ipi,:),'ycolor',plotcolors(ipi,:),'FontSize',fs);
    set(gca,'box','off','color','none');
    set(gca,'Xlim',tlim+0.3*[-1 1],'YAxis','left');
    ylabel(strrep(holodata.Proxy{ip(ipi)},'$',''));
    
   
    xtl=get(gca,'XTickLabel');
    xl=repmat(' ',size(xtl,1),5);
    xl(:,1:size(xtl,2))=xtl;
    xl(end,:)='ka BP';
    set(gca,'XTickLabel',xl);
    %print('-dpdf',sprintf('proxy_timeseries_%02d_%s',ipi,f));
    cl_print(6,'name',sprintf('proxy_timeseries_%02d_%s',ipi,f),'ext','pdf','noshrink',0);
  
     
    figure(5);
    axes(ax0);
    uistack(ax0,'bottom');

    if ~any([6 7 13 16 17]==ipi) 
      m_plot(holodata.Longitude(ip(ipi)),holodata.Latitude(ip(ipi)),'ko','MarkerFaceColor',plotcolors(ipi,:),'MarkerSize',12);
      mt(ipi)=m_text(holodata.Longitude(ip(ipi)),holodata.Latitude(ip(ipi)),num2str(ipi),'color','y','FontSize',10,'horizontal','center');
      hs=rgb2hsv(plotcolors(ipi,:));
      if hs(1)<0.5 set(mt(ipi),'color','k'); end
    end
    
    ax(ipi)=axes('Position',[pos(1)+(px(ipi)-lx(1))*pos(3)/dlx pos(2)+(py(ipi)-ly(1))*pos(4)/dly 0.15 0.1]);
    plot(ax(ipi),data.ut,cl_normalize(data.m50),'b-','color',plotcolors(ipi,:),'LineWidth',3);
    set(gca,'xcolor',plotcolors(ipi,:),'ycolor',plotcolors(ipi,:));
    set(gca,'box','off','color','none');
    ylabel(holodata.Proxy{ip(ipi)});
    xtl=get(gca,'XTickLabel');
    xl=repmat(' ',size(xtl,1),5);
    xl(:,1:size(xtl,2))=xtl;
    xl(end,:)='ka BP';
    set(gca,'XTickLabel',xl);
    
    switch(ipi)
        case 1,set(ax(ipi),'Position',[0.1018    0.7639    0.1500    0.1000]);
        case 2,set(ax(ipi),'Position',[0.1140    0.2180    0.1500    0.1000]);
        case 3,set(ax(ipi),'Position',[0.1381    0.3512    0.1500    0.1000]);
        case 4,set(ax(ipi),'Position',[0.2654    0.8402    0.1500    0.1000]);
        case 5,set(ax(ipi),'Position',[0.2735    0.5620    0.1500    0.1000]);
        case 6,set(ax(ipi),'Position',[0.1018    0.7639    0.1500    0.1000]); delete(ax(ipi));
        case 7,set(ax(ipi),'Position',[0.1018    0.7639    0.1500    0.1000]); delete(ax(ipi));
        case 8,set(ax(ipi),'Position',[0.3551    0.4044    0.1500    0.1000]);
        case 9,set(ax(ipi),'Position',[0.4936    0.5083    0.1500    0.1000]);
        case 10,set(ax(ipi),'Position',[0.3940    0.6515    0.1500    0.1000]);
        case 11,set(ax(ipi),'Position',[0.6823    0.8130    0.1500    0.1000]);
        case 12,set(ax(ipi),'Position',[0.5505    0.3145    0.1500    0.1000]);
        case 13,set(ax(ipi),'Position',[0.6823    0.8130    0.1500    0.1000]); delete(ax(ipi));
        case 14,set(ax(ipi),'Position',[0.6570    0.5288    0.1500    0.1000]);
        case 15,set(ax(ipi),'Position',[0.7164    0.3649    0.1500    0.1000]);
        case 16,set(ax(ipi),'Position',[0.7164    0.3649    0.1500    0.1000]); delete(ax(ipi));
        case 17,set(ax(ipi),'Position',[0.7164    0.3649    0.1500    0.1000]); delete(ax(ipi));
        case 18,set(ax(ipi),'Position',[0.7189    0.1453    0.1500    0.1000]);
    end
    
    rffile=fullfile(dirs.red,[f '_red.mat']);
    if ~exist(rffile,'file') 
      rffile=fullfile(dirs.red,[f '.red']);
      cl_red2mat(rffile);
      rffile=fullfile(dirs.red,[f '_red.mat']);
    end
    if ~exist(rffile,'file') continue; end
  %figure(7); clf;
  %clp_single_redfit('file',rffile);
  end
  cl_print('name','euroclim_proxytimeseries_on_map','ext','png');
  for ipi=1:nip
    try delete(ax(ipi)); catch end
  end
  cl_print(5,'name','euroclim_proxylocation_on_map','ext','pdf','noshrink',0);
end




%% Part 6: do pdf plot for highlighted regions
if any(doplots==6);

  rmin=250;

  for isce=1:length(sces)
    file=fullfile(predir,[basename sprintf('_%.1f.nc',sces(isce))]);
    if ~exist(file,'file'); continue; end
    
    ncid=netcdf.open(file,'NOWRITE');
    varid=netcdf.inqVarID(ncid,'farming');
    farming=netcdf.getVar(ncid,varid);
    netcdf.close(ncid);
 
  
  
  dd=diff(farming');
  ntime=size(dd,1);
  dtime=(timelim(2)-timelim(1))/(ntime-1);
  rtime=timelim(1):dtime:timelim(2);
 
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
    dists=cl_distance(sites.longitude,sites.latitude,rlon,rlat);  
    ir=find(dists<=r);
    if isempty(ir) continue; end
 
  
  a1=normpdf(0,0,1);
  a2=normpdf(1,0,1);
  a3=sum(a1+2*a2);

  hir=histc(sites.time(ir),edges);
  whir=(a1*histc(sites.time(ir),edges)+a2*histc(sites.time_upper(ir),edges)+a2*histc(sites.time_lower(ir),edges))/a3;  
  maxwhir=max(whir);
  if (maxwhir>0) whir=whir/maxwhir; end
  
  thresh=0.01;
  idata=find(ddconv>thresh);
  if isempty(idata) continue; end
  xdata=time(idata)';
  ndata=length(xdata);
  ydata=zeros(1,ndata);
  cdata=double(ddconv(idata))';
  
  lightgray=repmat(0.70,3,1);
  darkgray=repmat(0.3,3,1);
  pp(i)=patch([xdata fliplr(xdata)]',[cdata cdata*0],'k-');
  set(pp(i),'FaceColor',lightgray,'edgeColor','none');
  plot(xdata,cdata,'k-','LineWidth',2.5);
 
       
  irp=strmatch('PPN',sites.culture(ir)); pir=ir(irp);
  phir=(a1*histc(sites.time(pir),edges)+a2*histc(sites.time_upper(pir),edges)+a2*histc(sites.time_lower(pir),edges))/a3;  
  if (size(phir,1)<size(phir,2)) phir=phir'; end
  nhir=phir(1:end-2)/5.0;
  
  irp=vertcat(strmatch('Körös',sites.culture(ir)),...
      strmatch('Starčevo',sites.culture(ir)));%,...
      %strmatch('Vinča',culture(ir)));
  
  pir=ir(irp);
  phir=(a1*histc(sites.time(pir),edges)+a2*histc(sites.time_upper(pir),edges)+a2*histc(sites.time_lower(pir),edges))/a3;  
  if (size(phir,1)<size(phir,2)) phir=phir'; end
  khir=phir(1:end-2)/5.0;
  irp=strmatch('LBK',sites.culture(ir)); pir=ir(irp);
  phir=(a1*histc(sites.time(pir),edges)+a2*histc(sites.time_upper(pir),edges)+a2*histc(sites.time_lower(pir),edges))/a3;  
  if (size(phir,1)<size(phir,2)) phir=phir'; end
  lhir=phir(1:end-2)/5.0;
  irp=vertcat(strmatch('TRB',sites.culture(ir)),...
      strmatch('Trichterbecher',sites.culture(ir))); 
  pir=ir(irp);
  phir=(a1*histc(sites.time(pir),edges)+a2*histc(sites.time_upper(pir),edges)+a2*histc(sites.time_lower(pir),edges))/a3;  
  if (size(phir,1)<size(phir,2)) phir=phir'; end
  thir=phir(1:end-2)/5.0;
  stackedhir=[nhir khir lhir thir]/maxwhir;
  
  
  pbar=bar(centers(1:end-1),whir(1:end-2),0.6,'k','edgecolor',darkgray,'LineWidth',1.6,'ShowBaseLine','off');
  set(pbar,'FaceColor','w');
  [m,im]=max(hir);
  text(centers(im),0.8,num2str(m),'FontSize',9,'Horizontal','center');
  
  sb=bar(centers(1:end-1),stackedhir,'stacked','edgecolor','none','barwidth',0.4,'ShowBaseLine','off');
  set(sb(1),'Facecolor',colppn);
  set(sb(2),'FaceColor',colkor);
  set(sb(3),'FaceColor',collbk);
  set(sb(4),'Facecolor',coltrb);
  set(gca,'XDir','reverse');
  
  %plot(xdata,cdata,'k-','LineWidth',2.5);
 
  cl_print('name',sprintf('%s_%.1f_timing_histogram_%s_%s',basename,sces(isce),datastring,letters(i)),'ext','pdf','noshrink',1);
  
  
  per=sites.culture(ir);
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
  
  ir=strmatch('LBK',sites.culture);
  [mu,sigma]=normfit(sites.time(ir));
  lbknorm=normpdf(time,mu,sigma)*length(ir);
  
  ir=strmatch('Körös',sites.culture);
  [mu,sigma]=normfit(sites.time(ir));
  korosnorm=normpdf(time,mu,sigma)*length(ir);
  
  ir=strmatch('TRB',sites.culture);
  [mu,sigma]=normfit(sites.time(ir));
  trbnorm=normpdf(time,mu,sigma)*length(ir);
  
  ir=strmatch('PPN',sites.culture);
  [mu,sigma]=normfit(sites.time(ir));
  ppnnorm=normpdf(time,mu,sigma)*length(ir);
  
  ir=strmatch('Neolithic',sites.culture);
  [mu,sigma]=normfit(sites.time(ir));
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
  
  
  %cl_print('name',sprintf('timing_histogram_%s',datastring),'ext','pdf');
  end
  
end % doplots = 6


%% Chapter 7: plot European fluc time series and map with locations
% be consistent with map in chapter 3

if any(doplots==7)
  load('holodata.mat');
  dirs.total='~/projects/glues/m/holocene/redfit/data/eleven';
  dirs.red='/h/lemmen/projects/glues/m/holocene/redfit/data/output/repl_5.5_0.5_eleven';

  lg=repmat(0.5,1,3);

  ip=find(holodata.Latitude>=latlim(1) & holodata.Latitude<=latlim(2) ...
    & holodata.Longitude>=lonlim(1) & holodata.Longitude<=lonlim(2));
  nip=length(ip);
  plotcolors=jet(nip);
  isort=reshape([1:nip/2 ; nip/2+1:nip],1,nip)
  plotcolors=plotcolors(isort,:);
  
  figure(5); clf reset; hold on;
  set(5,'Position',[124         114        1054         587]);
  clp_basemap('latlim',latlim,'lonlim',lonlim);
  clp_relief;
  %m_plot(holodata.Longitude(ip),holodata.Latitude(ip),'ko','MarkerFaceColor','k');
  m_grid('color',lg);
  ax0=gca;
  pos=get(ax0,'Position');
    
  [px,py]=m_ll2xy(holodata.Longitude(ip),holodata.Latitude(ip),'clip','on');
  [lx,ly]=m_ll2xy(lonlim,latlim);
  dlx=lx(2)-lx(1);
  dly=ly(2)-ly(1);
  %m_plot(sites.lon,sites.lat,'k.','color',[0.8 0.8 0.8]);
  %m_plot(sites.lon(nn(find(nd<radius))),sites.lat(nn(find(nd<radius))),'ko');

  
  
  run('../../eventmodel.m');
  ntime=length(time);
  regionfluc=zeros(size(eventregtime,1),ntime);
  eventregtime=1950-eventregtime;
  flucampl=0.4;
  for ir=1:size(regionfluc,1) 
    for ie=1:maxevent
      if isnan(eventregtime(ir,ie)) break; end
      omt=(time-eventregtime(ir,ie))/flucperiod;
      fluc=1-flucampl*exp(-omt.*omt);
      if ie==1 regionfluc(ir,:)=fluc';
      else regionfluc(ir,:)=regionfluc(ir,:).*fluc';
      end
    end
  end
  
  for ipi=1:nip
    if any([6 7 13 16 17]==ipi) continue; end 
    
    %m_plot(holodata.Longitude(ip(ipi)),holodata.Latitude(ip(ipi)),'ko','MarkerFaceColor',plotcolors(ipi,:),'MarkerSize',12);
    %mt(ipi)=m_text(holodata.Longitude(ip(ipi)),holodata.Latitude(ip(ipi)),num2str(ipi),'color','w','FontSize',12,'horizontal','center');
    %hs=rgb2hsv(plotcolors(ipi,:));
    %if hs(1)<0.5 set(mt(ipi),'color','k'); end
    
    dist=cl_distance(lon,lat,holodata.Longitude(ip(ipi)),holodata.Latitude(ip(ipi)));
    [sdist,mindist]=sort(dist);
    ir(ipi)=mindist(1);
    %m_plot([holodata.Longitude(ip(ipi)) lon(ir(ipi))],[holodata.Latitude(ip(ipi)) lat(ir(ipi))],'k-','color',plotcolors(ipi,:));
  end
  
  
  %clp_nc_variable(file,'var','region','showvalue',1,'reg',reg);
  
  ir=[108 142 124 209 198 211 262 215 255 314 315];
  ir=unique(ir);
  ir=ir(ir>0);
  
  [h,llimit,llimit,rlon,rlat]=clp_regionpath('reg',ir+1);
  
  [px,py]=m_ll2xy(rlon,rlat,'clip','on');
  [lx,ly]=m_ll2xy(lonlim,latlim);
  dlx=lx(2)-lx(1);
  dly=ly(2)-ly(1);

  for ipi=1:length(ir)
     set(h(ipi),'FaceColor',plotcolors(ipi,:),'Facealpha',0.7);
     
     ax(ipi)=axes('Position',[-0.1+pos(1)+(px(ipi)-lx(1))*pos(3)/dlx -0.05+pos(2)+(py(ipi)-ly(1))*pos(4)/dly 0.15 0.1]);
     hold on;
     plot(ax(ipi),time,(regionfluc(ir(ipi),:)),'b-','color',plotcolors(ipi,:),'LineWidth',3);
     plot(ax(ipi),time,(regionfluc(ir(ipi),:)),'k-','LineWidth',1.5);
     %set(gca,'xcolor',plotcolors(ipi,:),'ycolor',plotcolors(ipi,:));
     set(gca,'box','off','color','none','xlim',[min(time) max(time)]);
     xtl=get(gca,'XTickLabel');
     xtl(end,:)=' ';
     xtl(end,end-1:end)='AD';
     set(gca,'XTickLabel',xtl);
     axis off;
  end
  
  % Look at event time series

  
  cl_print('name','euroclim_fluctimeseries_on_map','ext','pdf');
end



return




ifound=ireg;nfound=nreg;lonlim=loli; latlim=lali;


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








if (0==5)
%% Do Ammerman plot (figure 5)
% Single column 90 mm 1063 1772 3543 
% 1.5 column 140 mm 1654 2756 5512
% Full width 190 mm 2244 3740 7480

gtime=timelim(1):200:timelim(2);

figure(1); clf reset; hold on;
set(gcf,'Units','centimeters','Position',[0 0 18 18]);
set(gca,'color','none','FontSize',14,'FontName','Times');

irppn=strmatch('PPN',culture);
irkor=strmatch('Körös',culture);
irlbk=strmatch('LBK',culture);
irtrb=strmatch('TRB',culture);

[mulbkt,siglbkt]=normfit(-sites.time(irlbk));
[mulbkd,siglbkd]=normfit(sdists(irlbk));
[mutrbt,sigtrbt]=normfit(-sites.time(irtrb));
[mutrbd,sigtrbd]=normfit(sdists(irtrb));
[mukort,sigkort]=normfit(-sites.time(irkor));
[mukord,sigkord]=normfit(sdists(irkor));
[muppnt,sigppnt]=normfit(-sites.time(irppn));
[muppnd,sigppnd]=normfit(sdists(irppn));

collbk=[1 1 0.9]; % 'y'
  coltrb=[1 .95 .95]; %'r';
  colppn=[.95 1 .95]; %'g';
  colkor=[.9 1 1]; %'c';

simfcolor=[1 .9 .8];
simecolor=[1 .65 .4];
for ir=1:nfound
  if ~isfinite(onset(ir)) continue; end
  cl_ellipse(-onset(ir),dists(ir),radius(ifound(ir)),radius(ifound(ir)),...
      'k-','edgecolor',simecolor,'FaceColor',simfcolor,'FaceAlpha',1);
end
p3=plot(-onset,dists,'rs','MarkerFaceColor',simecolor,'MarkerSize',2,...
    'MarkerEdgeColor',simecolor,'visible','off');
p1=plot(-sites.time,sdists,'bd','MarkerFaceColor','b','MarkerSize',2);
ylabel('Distance from Levante (km)');
xlabel('Time (year BC)'); 
set(gca,'Xlim',-fliplr([timelim]));
set(gca,'XDir','reverse');
%p2=plot(-onset,dists,'rd','MarkerFaceColor','r','MarkerSize',1);
%plot(7500:-200:3500,0:200:4000,'k--');

pf1=polyfit(-onset(itv),dists(itv),1);
p4=plot(-gtime,-gtime*pf1(1)+pf1(2),'r--','LineWidth',1);
pf2=polyfit(-sites.time,sdists,1);
p5=plot(-gtime,-gtime*pf2(1)+pf2(2),'b--','LineWidth',1);


ikor=find(any(distmatrix(:,irkor)-repmat(radius(ifound),1,length(irkor))<=0,2));
ilbk=find(any(distmatrix(:,irlbk)-repmat(radius(ifound),1,length(irlbk))<=0,2));
itrb=find(any(distmatrix(:,irtrb)-repmat(radius(ifound),1,length(irtrb))<=0,2));
ippn=find(any(distmatrix(:,irppn)-repmat(radius(ifound),1,length(irppn))<=0,2));

diffedge=500;
edge=0:diffedge:4500;
nedge=length(edge);
pcvals=[0.05 0.5 0.95];

for ip=1:3
  pcval=pcvals(ip);
  pcd=[];

  for iedge=2:nedge
    ibin=find(sdists>=edge(iedge-1) & sdists<=edge(iedge));
    pcd(iedge)=cl_quantile(sites.time(ibin),pcval);
  end
  pedge=reshape(repmat(edge,2,1),1,2*nedge);
  pcd=reshape(repmat(pcd,2,1),1,2*nedge);

  pcd=pcd(3:end);
  pedge=pedge(2:end-1);
  pc1(ip)=plot(-pcd,pedge,'b-','LineWidth',3,'visible','on');
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
  pc3(ip)=plot(-pcr+20,pedge+20,'r-','LineWidth',3,'visible','on');
end

set([pc1([2,3]),pc3([2,3])],'visible','off');

l=legend([p1,p3,p4,p5,pc1,pc3],'Radiocarbon sites','Simulation regions','Site regression','Simulation regression',...
    'Site staircase fit','Simulation staircase fit');
set(l,'location','Northwest','visible','off');

[cr1,cp1]=corrcoef(onset(itv),dists(itv));
[cr2,cp2]=corrcoef(sites.time,sdists);
set(gca,'YLim',[0 4000]);

ytl=get(gca,'YTickLabel');
ytl(1,:)=' ';
set(gca,'YTickLabel',ytl);


fprintf('Site data (n=%d, r^2=%.2f, v=%.2f km a^{-1})',length(sites.time),cr2(2).^2,-pf2(1));
fprintf('Simulation (n=%d, r^2=%.2f, v=%.2f km a^{-1})',length(itv),cr1(2).^2,-pf1(1));

%set(l,'color','none');

%offsets=100*[0 1 -1 1 -1 0 0 0 0 0];
%for i=1:nhreg
 % t1(i)=text(-onset(ihreg(i)),-200+offsets(i),letters(i),'Horizontal','center','FontName','Times','FontSize',14);
%e%nd

cl_print('name','ammerman_rgb','ext','png','res',[300,600]);
cl_print('name','ammerman_rgb','ext','pdf');


%% Create lbk_background.png
if any(doplots==0)
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

  [elev,lon,lat]=M_TBASE([lonlim(1) lonlim(2) latlim(1) latlim(2)]);
  elev(elev<0)=NaN;
  glat=latlim(2)+0.5/12-[1:size(elev,1)]/12.0;
  glon=lonlim(1)-0.5/12+[1:size(elev,2)]/12.0;
  m_pcolor(glon,glat,double(elev));
  shading interp;
  cmap=colormap(gray(256));
  colormap(flipud(cmap(100:230,:)));
end

return
end


