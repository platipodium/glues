%% User section, please adjust
% Run script for euroclim papers about sensitivity of transition to climate events in Europe
% Carsten Lemmen 2012-02-20

% What Neolithic site dataset to use
datastrings={'Pinhasi','Turney','Vanderlinden','Fepre'};
datastring=datastrings{1};

% What proxy file to use
proxyfile='proxydescription_265_134.csv';

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
if ~exist(matfile,'file');
  evinfo=read_textcsv(proxyfile);
else
  load(matfile); % into struct evinfo
end

% Load events in region
evregionfile=sprintf('EventInReg_134_685.tsv');
evinreg=load(evregionfile,'-ascii');

load('RegionEventTimes_134_685_07.mat');


%% Print latex table of Regions
%% Table S2 SOM
if (1==-1)
  for ireg=1:size(evinreg,1)
      fprintf('%d &',ireg);
      evids=evinreg(ireg,:);
      evtimes=1950-regionevents(ireg,:)*1000;
      evtimes=evtimes(evtimes<0);
      if isempty(evtimes)
        fprintf('none');
      else
        fprintf('%d',abs(round(evtimes(1))));
      end
      if length(evtimes)>1 fprintf('/%d',abs(round(evtimes(2:end)))); end

      fprintf('& ');
      fprintf('%d',evids(1));
      fprintf(',%d',evids(2:end));
   if mod(ireg,2)==0
      fprintf('\\\\ \n');
   else
       fprintf(' & ');
   end
  end  
end




evinreg=evinreg(ireg,:);
[ev,ievs]=unique(evinreg);
nev=length(ev);


evseriesfile=sprintf('EventSeries_134.tsv');
evseries=load(evseriesfile,'-ascii');

revt=load('../../RegionEventTimes.tsv','-ascii'); 


%% Print latex table of Events affecting certain regions
if (1==-1)
  c=0;
  for iev=1:nev
    evtimes=1050-evseries(ev(iev),:)*1000;
    j=find(evtimes>=-9500 & evtimes<=timelim(2));
    evtimes=round(abs(evtimes));
    if any(evinfo.No(ev(iev))==[80]); continue; end
    fprintf('%d & %s & %s &',evinfo.No(ev(iev)),evinfo.Plotname{ev(iev)},evinfo.Proxy{ev(iev)});
    if isempty(j) fprintf(' none '); else
    fprintf(' %d',evtimes(j(end)));
    if length(j)>1 fprintf('/%d',fliplr(evtimes(j(1:end-1)))); end
    end
    fprintf(' & \\citealt{%s}',evinfo.Source{ev(iev)});
    c=c+1;
    if mod(c,2)==0 fprintf('\\\\ \n');  
    else
      fprintf(' & '); 
      if (iev==nev) fprintf(' & & & &\\\\ \n'); 
      end
    end
  end  
  
  for iev=1:nev
     fprintf('%s,',evinfo.Source{ev(iev)});
  end
 
end



%% Print latex table of Events affecting certain regions
if (1==-1)
  c=0;
  for iev=1:nev
    evtimes=1050-evseries(ev(iev),:)*1000;
    j=find(evtimes>=-9500 & evtimes<=timelim(2));
    evtimes=round(abs(evtimes));
    if any(evinfo.No(ev(iev))==[80]); continue; end
    fprintf('%d & %s & %s &',evinfo.No(ev(iev)),evinfo.Plotname{ev(iev)},evinfo.Proxy{ev(iev)});
    if isempty(j) fprintf(' none '); else
    fprintf(' %d',evtimes(j(end)));
    if length(j)>1 fprintf('/%d',fliplr(evtimes(j(1:end-1)))); end
    end
    fprintf(' & \\citealt{%s}',evinfo.Source{ev(iev)});
    c=c+1;
    if mod(c,2)==0 fprintf('\\\\ \n');  
    else
      fprintf(' & '); 
      if (iev==nev) fprintf(' & & & &\\\\ \n'); 
      end
    end
  end  
  
  for iev=1:nev
     fprintf('%s,',evinfo.Source{ev(iev)});
  end
 
end


%% Print latex table of Regions
if (1==-11)
  for ireg=1:size(evinreg,2)

    for iev=1:length(evinfo.No)
      evtimes=1050-evseries(iev,1:end-2)*1000;
      j=find(evtimes>=-9500 & evtimes<=timelim(2));
      evtimes=round(abs(evtimes));
      if any(evinfo.No(iev)==[80]); continue; end
      fprintf('%d & %s & %s &',evinfo.No(iev),evinfo.Plotname{iev},strrep(evinfo.Proxy{iev},' ','\,'));
      if isempty(j) fprintf(' none '); else
        fprintf(' %d',evtimes(j(end)));
        if length(j)>1 fprintf('/%d',fliplr(evtimes(j(1:end-1)))); end
      end
      fprintf(' & \\citealt{%s}',evinfo.Source{iev});
      c=c+1;
      if mod(c,2)==0 fprintf('\\\\ \n');  
      else
        fprintf(' & '); 
        if (iev==nev) fprintf(' & & & &\\\\ \n'); end
      end
    end
  end  
end



lg=repmat(0.8,1,3);
mg=repmat(0.55,1,3);
dg=repmat(0.3,1,3);

%---------------------------------------------------------------------
% Decide which plots to make
% 1: proxy location, region, and sites map
doplots=[5];

%---------------------------------------------------------------------
%% Figure 1: map of regions and Proxy locations and Neolithic sites
if any(doplots==1)

 % lali=cl_minmax(evinfo.Latitude(ev))+[-1 1];
 % loli=cl_minmax(evinfo.Longitude(ev))+[-1 1];
  %loli=loli+5*[-1 1];
  %lali=lali+2*[-1 1];
 
  [data,basename]=clp_nc_variable('lat',lali,'lon',loli,'var','region','marble',0,'transparency',1,'nocolor',0,...
      'showstat',0,'showtime',0,'fontsize',15,'showregion',0,...
      'file',fullfile(predir,sprintf('%s_%.1f.nc',basename,sces(1))),'figoffset',0,'noprint',1,'notitle',1);

 %m_grid;
  valid=find(data.handle>0);
  set(data.handle(valid),'FaceColor',lg,'EdgeColor',mg,'EdgeAlpha',1,'FaceAlpha',0.3);

  hold on;
  pl=m_plot(lonlim([1 2 2 1 1]),latlim([1 1 2 2 1]),'k--');
  set(pl,'LineWidth',4,'Color',mg,'visible','off');
  
  ps=m_plot(sites.longitude,sites.latitude,'ko','MarkerFaceColor',mg,'MarkerEdgeColor','none');
  set(ps,'MarkerSize',3);

  for i=1:nev
    plon=evinfo.Longitude(ev(i));
    plat=evinfo.Latitude(ev(i));
    [plon plat]=distribute_around(plon,plat,2,1.2);
    switch(ev(i))
        case {57,69,79}, plon=plon-2.5;
        case {89,49,81,61}, plon=plon+2.5;
      otherwise;
    end
    pp(i)=m_plot(plon(1),plat(1),'kv','MarkerSize',7,'MarkerFacecolor',dg);
    pt(i)=m_text(plon(2),plat(2),num2str(evinfo.No(ev(i))),'Vertical','middle',...
        'horizontal','center');
  end
  cb=findobj(gcf,'-property','Location');
  delete(cb);
  uistack(ps,'top');
  %uistack(pt,'top');
  set(pt,'visible','off');
  cl=legend([ps pp],'Neolithic site','Proxy location','Location','NorthEastOutside');
  %clpos=get(cl,'Position');
  %[x y]=m_ll2xy(lonlim,latlim);
  %set(cl,'Position',clpos + [0.31+x(2)-clpos(1) 0 0 0]);
  
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
  sce='0.3';
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
  
    cl_print('name',b,'ext',{'png','pdf'},'res',300);
  end
end
if any(doplots==33) 
  movtime=-8500:10:-2500;
  movtime=-7500:10:-3000;
  nmovtime=length(movtime);
  sce='0.3';
  for it=1:nmovtime
    [d,b]=clp_nc_variable('var','farming','reg','lbk','marble',3,'transparency',1,'nocolor',0,...
      'showstat',0,'lim',[0 1],'timelim',movtime(it),'nocbar',1,...
      'file',['../../euroclim_' sce '.nc'],'figoffset',0,'sce',[sce '_' sprintf('%03d_%05d',it,movtime(it))],'noprint',1);
    m_coast('color','k');
    m_grid('box','fancy','linestyle','none');
    peaki=find(abs(peakinfo(:,1)-movtime(it))<=175);
    for j=1:length(peaki)
      strength=exp(-abs(peakinfo(peaki(j),1)-movtime(it))/20);
      rings=90:60:500*strength;
      if 500*strength<90 continue; end
      rings=rings+(peakinfo(peaki(j),1)-movtime(it))/5;
      clp_pulse(peakinfo(peaki(j),3),peakinfo(peaki(j),4),...
          'rings',rings,'col','k','MarkerSize',10); 
    end

    sitei=find(sites.time<movtime(it));
    if ~isempty(sitei) 
      m_plot(sites.longitude(sitei),sites.latitude(sitei),'k^');
    end

     title('GLUES agropastoral activity');
%     cb=findobj(gcf,'tag','colorbar');
%     ytl=get(cb,'YTickLabel');
%     ytl=num2str(round(100*str2num(ytl)));
%     set(cb,'YTickLabel',ytl);
%     title(cb,'%');
%     cm=get(cb,'Children');
%     cm=findobj(cm,'-property','CData');
%     cmap=get(cm,'CData');
%   
    cl_print('name',b,'ext','png','res',100);
  end
  % Command line postprocessing
  %mencoder mf://farming_lbk_66_0.3_*.png  -mf w=800:h=600:fps=5:type=png -ovc lavc -lavcopts vcodec=mpeg4:mbd=2:trell -oac copy -o output.avi
end




% Read default scenario
file=fullfile(predir,['euroclim' '_0.3.nc']);
if ~exist(file,'file'); error('File does not exist'); end
ncid=netcdf.open(file,'NOWRITE');
  varid=netcdf.inqVarID(ncid,'region');
  id=netcdf.getVar(ncid,varid);
  varid=netcdf.inqVarID(ncid,'time');
  time=netcdf.getVar(ncid,varid)/360+2000;
  if (any(round(time)-time>0)) error('Got mixed up with years/days'); end
  itime=find(time>=timelim(1) & time<=timelim(2));
  varid=netcdf.inqVarID(ncid,'farming');
  farming=netcdf.getVar(ncid,varid);
  varid=netcdf.inqVarID(ncid,'latitude');
lat=double(netcdf.getVar(ncid,varid)); % need to be corrected
  varid=netcdf.inqVarID(ncid,'longitude');
lon=double(netcdf.getVar(ncid,varid)); % need to be corrected
  varid=netcdf.inqVarID(ncid,'area');
  area=double(netcdf.getVar(ncid,varid));
  varid=netcdf.inqVarID(ncid,'region_neighbour');
  neigh=netcdf.getVar(ncid,varid);
  netcdf.close(ncid);
  
 timing=cl_nc_timing('file',file,'threshold',0.5,'timelim',timelim);
 
 oldnreg=nreg;
load('regionpath_685');
lat=regionlat;
lon=regionlon;
nreg=oldnreg;

%% New figure 5: map with arrows of both scenarios and 
if any(doplots==5)
  
   [d1,basename]=clp_nc_variable('var','region','reg','lbk','marble',0,'transparency',0,...
       'nocolor',0,...
      'showstat',0,'timelim',[-7500 -3500],'showtime',0,'flip',1,'showvalue',0,...
      'file',file,'figoffset',4,'sce',sce,'nocbar',1,...
      'noprint',1,'notitle',1,'ncol',5);
%'noprint',1,'notitle',1,'ncol',ncol,'cmap','clc_eurolbk');
    t1=cl_nc_timing('file',file,'threshold',0.5,'timelim',timelim);
    t0=cl_nc_timing('file',strrep(file,'0.3','0.0'),'threshold',0.5,'timelim',timelim);
 
    h=d1.handle;
    set(h(h>0),'FaceColor','none','EdgeColor',mg);
    
    % Add here info on stagnation periods 
    for i=1:length(ireg)
      ir=ireg(i);
      for in=1:length(find(neigh(ir,:)>0))
         jr=neigh(ir,in)+1;
         if ~any(jr==ireg) continue; end
         if t0(ir)<t0(jr)
             rlo=regioncenter([ir,jr],2)+0.5;
             rla=regioncenter([ir,jr],1)+0.5;
         else
             rlo=regioncenter([jr,ir],2)+0.5;
             rla=regioncenter([jr,ir],1)+0.5;
         end    
         [xlo,xla]=m_ll2xy(rlo,rla);
         dist=m_lldist(rlo,rla);
         %hl=m_plot(rlo,rla,'k-','LineWidth',1);
         [gd glon glat]=m_geodesic(rlo(1),rla(1),rlo(2),rla(2),round(200*exp(-dist/1000)));
         id=find(glon>min(rlo) & glon<max(rlo) & glat>min(rla) & glat<max(rla));
         id0=id(1:2:end);
         id1=id(2:2:end);
         lw0=700/max([abs(t0(ir)-t0(jr)), 50]);
         lw1=700/max([abs(t1(ir)-t1(jr)), 50]);
         h0=m_plot(glon(id0),glat(id0),'r.','MarkerSize',lw0);
         h1=m_plot(glon(id1),glat(id1),'b.','MarkerSize',lw1);
         continue
         
         w=atand(xla./xlo);
         wh=w(1)+(w(2)-w(1))/2;
         xslo=(xlo(1)+0.5*(xlo(2)-xlo(1)));
         xsla=xslo*tand(wh);
         [slo,sla]=m_xy2ll(xslo,xsla);
         
%          [xlolim,xlalim]=m_ll2xy(lonlim,latlim);
%          nxlo=(xlo-xlolim(1))./(xlolim(2)-xlolim(1));
%          nxla=(xla-xlalim(1))./(xlalim(2)-xlalim(1));
%          
%          
%          m_plot(slo,sla,'rd','MarkerSize',10);
%          
%          ar=annotation('rectangle',[0 0 1 1],'color','r');
%          ar=annotation('arrow',nxlo,nxla);
%          
%          x0=0.77; y0=0.7; dy=0.1;
%          ar=annotation('arrow',[x0 x0],[y0-dy*0.12 y0-1.65*dy]);
%          set(ar,'LineWidth',4,'HeadWidth',12,'Color',grc(1,:));

         
         % Kreisgleichung
         % r^2 = (x-a)^2 + (y-b)^2;
         radius=dist*2;
         
         
         %hv=m_vec(0.15,rlo(1),rla(1),(xlo(2)-xlo(1)),(xla(2)-xla(1)));
         %set(hv,'EdgeColor','r','LineWidth',2)
            % r1=m_range_ring(rlo(1),rla(1),1000);
            % r2=m_range_ring(rlo(2),rla(2),1000);
            % diff=(get(r1,'XData')-get(r2,'XData')).^2 + ...
            %     (get(r1,'YData')-get(r2,'YData')).^2
        
      end
    end
end



% Nice pastel maps of farming timing
if any(doplots==4)
  %% plot farming timing for all scenarios 
  ncol=8;
  cmap=flipud(vivid(ncol));
  iscol=floor((sites.time-min(timelim))./(timelim(2)-timelim(1))*ncol)+1;
  iscol(iscol<1)=1;
  viscol=find(iscol<=ncol);

  for s=[0.0 0.3 0.4]
    figure(2); clf;
    sce=sprintf('%3.1f',s);
    file=['../../euroclim_' sce '.nc'];
    [data,basename]=clp_nc_variable('var','farming','threshold',0.5,'reg','lbk','marble',0,'transparency',1,'nocolor',0,...
      'showstat',0,'timelim',[-7500 -3500],'showtime',0,'flip',1,'showvalue',0,...
      'file',file,'figoffset',0,'sce',sce,...
      'noprint',1,'notitle',1,'ncol',ncol,'cmap','vivid');
%'noprint',1,'notitle',1,'ncol',ncol,'cmap','clc_eurolbk');
    timing=cl_nc_timing('file',file,'threshold',0.5,'timelim',timelim);
 

    hdf=findobj(gcf,'-property','EdgeColor','-and','-property','FaceColor');
    hdf=findobj(hdf,'-not','FaceColor','none');
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
    cbc=findobj(cbc,'-property','AlphaData');
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
    cc=findobj(cc,'-property','AlphaData');
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
    
    % Add here info on stagnation periods 
    for i=1:length(ireg)
      ir=ireg(i);
      for in=1:length(find(neigh(ir,:)>0))
         jr=neigh(ir,in)+1;
         if ~any(jr==ireg) continue; end
         if timing(ir)-timing(jr)>=450
             rlo=regioncenter([ir,jr],2);
             rla=regioncenter([ir,jr],1);
             m_plot(rlo,rla,'k-','LineWidth',4);
            % r1=m_range_ring(rlo(1),rla(1),1000);
            % r2=m_range_ring(rlo(2),rla(2),1000);
            % diff=(get(r1,'XData')-get(r2,'XData')).^2 + ...
            %     (get(r1,'YData')-get(r2,'YData')).^2
         end
      end
    end
    
    
    
    cl_print('name',strrep(basename,'farming_','timing_'),'ext','png','res',[150,600]);
  end % of for loop
end



  





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
  
  idist=ceil(nreg*(rdists-min(rdists))/cl_range(rdists));
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
   cl_nc_timing('file','../../euroclim_0.0.nc');
   cl_nc_timing('file','../../euroclim_0.3.nc');
   %file='../../euroclim_diff.nc';

   
   %system('/opt/local/bin/ncdiff -O -v farming_timing ../../euroclim_0.3.nc ../../euroclim_0.0.nc ../../euroclim_diff.nc && /opt/local/bin/ncks -A -v latitude,longitude ../../euroclim_0.3.nc ../../euroclim_diff.nc');
   
   %[data,basename]=clp_nc_variable('var','farming_timing','reg',reg,'marble',0,'transparency',0,'nocolor',0,...
   %   'showstat',0,'lim',[-500 500],'showtime',0,'flip',1,'showvalue',0,...
   %   'file',file,'figoffset',0,'sce',sce,...
   %   'noprint',1,'notitle',1,'ncol',11,'cmap','hotcold');
  % cl_print('name','euroclim_diff','ext','pdf');
   
end

eventregtime=load('../../eventregtime.tsv','-ascii');
eventregtime(eventregtime<0)=NaN;


if any(doplots==6) 
    
    hreg=243;
    ir=find(ireg==hreg);
    
    isce=4;
    file=fullfile(predir,sprintf('%s_%.1f.nc','euroclim',sces(isce)));
 
    clp_nc_trajectory('var','farming','file',file,'timelim',timelim,'reg',ireg(ir),...
        'nosum',1,'noprint',1);
    ylimit=get(gca,'YLim');
    plot(1950-eventregtime(ireg(ir),:),0.9*ylimit(2),'kv','MarkerSize',10,'MarkerFaceColor','r');
    
    
    set(gca,'YScale','log');
    
    figure(6); clf; hold on;
   n=0;
   for ir=1:nreg
      itrans=find(farming(ireg(ir),:)>0.041 & farming(ireg(ir),:)<0.99);
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
        pause(0.0);
        n=n+1;
        transreg(n)=ireg(ir);
        itransreg(n)=ir;
        cl_print('name',sprintf('transition_with_event_%03d',ireg(ir)),'ext','pdf');
      end
   end
      
    
     save('event_in_transition','transreg','itransreg');
    % in 26 regions this occurs
   % [data,basename]=clp_nc_variable('var','farming_timing','reg',reg,'marble',0,'transparency',0,'nocolor',0,...
    %  'showstat',0,'lim',[0 1000],'showtime',0,'flip',1,'showvalue',0,...
     % 'file',strrep(file,'0.3','diff'),'figoffset',0,'sce','diff',...
      %'noprint',1,'notitle',1,'ncol',11,'cmap','hotcold');
  
    ;
  
  
    %hdl=data.handle;
    %hdl=hdl(hdl>0);
    %mg=repmat(0.5,1,3);
    %set(hdl,'EdgeColor',mg,'EdgeAlpha',1);
  
    %hdl=data.handle(itransreg);
   % hdl=hdl(hdl>0);
   % set(hdl,'EdgeColor','k','EdgeAlpha',1,'LineWidth',6);

    
end



if any(doplots==-7)
   

    plotvars={'farming','population_density','migration_density','technology'};
    plotsces=[1 4];
    
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
  
   figure(3); clf reset;

  scecolors=jet(11);
  
    transtime=zeros(nreg,11)+inf;
    stranstime=transtime;
    timing=zeros(nreg,11)+inf;
   for isce=[1 4 5] %length(sces):-1:1
    file=fullfile(predir,sprintf('euroclim_%.1f.nc',sces(isce)));
    if ~exist(file,'file'); continue; end
    
    ncid=netcdf.open(file,'NOWRITE');
    varid=netcdf.inqVarID(ncid,'farming');
    farming=netcdf.getVar(ncid,varid);
    varid=netcdf.inqVarID(ncid,'farming_timing');
    timeunit=netcdf.getAtt(ncid,varid,'units');
    thistiming=netcdf.getVar(ncid,varid);
    thistiming=cl_time2yearAD(thistiming,timeunit);  
    netcdf.close(ncid);
   
    timing(:,isce)=thistiming(ireg);
    
    sdist=[];
    stiming=timing(1,:)'+inf;
     for ir=1:nreg
      sw(ir) = sum(nw(ir,1:ns(ir)),2);
      stiming(ir)=sum(nw(ir,1:ns(ir)).*sites.time(nn(ir,1:ns(ir)))')./sw(ir);
      sdist(ir)=sum(nw(ir,1:ns(ir)).*nd(ir,1:ns(ir)));
      itrans=min(find(farming(ireg(ir),:)>0.041)):min(find(farming(ireg(ir),:)>=0.95));
      
      
      if max(farming(ireg(ir),:))<0.5 | isempty(itrans)
          transtime(ir,isce)=inf;  
      else
           transtime(ir,isce)=cl_range(time(itrans));
      end
      if ns(ir)<10 % was 9
        stranstime(ir,isce)=inf;
      else
      stranstime(ir,isce)=std(sites.time(nn(ir,1:ns(ir))));
      end
    end
  
    if isce==4;
      figure(2); clf; hold on
      set(gca,'FontSize',15,'FontName','times');
      xlabel('Model: simulated duration (years)');
      ylabel('Data: Reconstructed duration (years)');
      limit=[100 1400];
      valid1=find(isfinite(stranstime(:,1)) & isfinite(transtime(:,1)));
      valid5=find(isfinite(stranstime(:,4)) & isfinite(transtime(:,4)));
      limit1=cl_minmax(transtime(valid1,1));
      limit5=cl_minmax(transtime(valid5,4));
      p2(1)=plot(limit,limit,'k--','color',lg,'LineWidth',2,'visible','on');
      p2(2)=plot(transtime(valid1,1),stranstime(valid1,1),'ko','MarkerFaceColor',mg,'Color',mg);
      p2(3)=plot(transtime(valid5,4),stranstime(valid5,4),'ko','MarkerFaceColor','k');
      
      b1=polyfit(transtime(valid1,1),stranstime(valid1,1),1);
      b2=polyfit(transtime(valid5,4),stranstime(valid5,4),1);
      
      p2(4)=plot(limit1,limit5*b1(1)+b1(2),'k-','linewidth',3,'visible','on','color',mg);
      p2(5)=plot(limit5,limit5*b2(1)+b2(2),'k-','color','k','visible','on','lineWidth',4);
 
      
      uistack(p2([2,3]),'top');
      
      [r,p]=corrcoef(transtime(valid1,1),stranstime(valid1,1));
      fprintf('Duration 1 R^2=%.2f n=%d p=%.3f',r(2,1).^2,length(valid1),p(2,1));
      [r,p]=corrcoef(transtime(valid5,4),stranstime(valid5,4));
      fprintf('Duration 5 R^2=%.2f n=%d p=%.3f',r(2,1).^2,length(valid5),p(2,1));
      
      %ilev1=find(isfinite(stranstime(:,1)) & isfinite(transtime(:,1)) & stiming<-7000);
      %ilev5=find(isfinite(stranstime(:,5)) & isfinite(transtime(:,5)) & stiming<-7000);
      
      %p2(2)=plot(transtime(ilev1,1),stranstime(ilev1,1),'ko','MarkerFaceColor',mg,'Color',mg);
      %p2(3)=plot(transtime(ilev5,5),stranstime(ilev5,5),'ko','MarkerFaceColor','r');
 
      
      
      axis square;
      set(gca,'Xlim',[150 1250],'Ylim',[150 1250]);
     
      
      legend([p2(3) p2(2) p2(5)],'with events','without','lin. regression','location','northeastoutside');
      cl_print('name','transition_duration','ext','pdf');
    end
    
    
    
    timelim=[-8000 3500]
    dt=2*radius;
   %ivalid=find(isfinite(stiming) & stiming<timelim(2)+dt & stiming>timelim(1)-dt...
   %    & timing < timelim(2)+dt & timing >timelim(1)-dt   ... %;%...       
   %    & (lon(ireg)<32 | lat(ireg)>38 ) );
    ivalid=find(isfinite(stiming) & isfinite(timing(:,isce)));% & timing<timelim(2)+dt ...
        % &  (lon(ireg)'<30 | lat(ireg)'>38 ) );
        
    [b]=polyfit(timing(ivalid,isce),stiming(ivalid),1);
    
    figure(2+isce); clf;
    hold on;
    p1=plot(timing(ivalid,isce),timing(ivalid,isce),'k-');
    p1a=plot(timing(ivalid,isce),timing(ivalid,isce)*b(1)+b(2),'r-');
    p2=plot(timing(ivalid,isce),stiming(ivalid),'ks');
    %ivalid=isfinite(timing) & isfinite(stiming);
    
    [r,p]=corrcoef(timing(ivalid,isce),stiming(ivalid));
    rpmatrix(isce,1:2)=[r(2,1) p(2,1)];
    
    for ir=1:nreg
       if isempty(find(ir==ivalid)) continue; end
       p3(ir)=plot(repmat(timing(ir,isce),1,2),repmat(stiming(ir),1,2)+0.1*[-1 1].*repmat(sdist(ir),1,2),'k-','color',repmat(0.8,1,3));
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
    
    if isce==4
      figure(4); clf; hold on;
      set(gca,'FontSize',15,'FontName','times');
      xlabel('Model: simulated onset (cal BC)');
      ylabel('Data: reconstructed onset (cal BC)');
      limit=[-8500 -3500];
      valid1=find(isfinite(timing(:,1)) & isfinite(stiming));
      valid5=find(isfinite(timing(:,4)) & isfinite(stiming));
      limit1=cl_minmax(timing(valid1,1));
      limit5=cl_minmax(timing(valid5,4));
      p2(1)=plot(limit,limit,'k--','color',lg,'LineWidth',2,'visible','on');
      p2(2)=plot(timing(valid1,1),stiming(valid1),'ko','MarkerFaceColor',mg,'Color',mg);
      p2(3)=plot(timing(valid5,4),stiming(valid5),'ko','MarkerFaceColor','k');
      
      b1=polyfit(timing(valid1,1),stiming(valid1),1);
      b2=polyfit(timing(valid5,4),stiming(valid5),1);
      
      p2(4)=plot(limit1,limit5*b1(1)+b1(2),'k-','linewidth',3,'visible','on','color',mg);
      p2(5)=plot(limit5,limit5*b2(1)+b2(2),'k-','color','k','visible','on','lineWidth',4);
 
      [r,p]=corrcoef(timing(valid1,1),stiming(valid1));
      fprintf('Onset 1 R^2=%.2f n=%d p=%.3f',r(2,1).^2,length(valid1),p(2,1));
      [r,p]=corrcoef(timing(valid5,4),stiming(valid5));
      fprintf('Onset 5 R^2=%.2f n=%d p=%.3f',r(2,1).^2,length(valid5),p(2,1));
      
      
      valid=find(isfinite(timing(:,4)) & isfinite(stiming) & isfinite(transtime(:,4))...
          & isfinite(stranstime(:,4)));
      valid=valid5;
      for iv=1:-length(valid)
        ir=valid(iv);
        plot(repmat(timing(ir,4),1,2),stiming(ir)+0.5*stranstime(ir,5)*[-1 1],'k-');
        plot(timing(ir,4)+0.5*transtime(ir,5)*[-1 1],repmat(stiming(ir),1,2),'k-');
      end
        
      ilev=find(stiming(valid5)<-7000);
      p2(6)=plot(timing(valid5(ilev),4),stiming(valid5(ilev)),'ko','MarkerFaceColor','r','visible','off');
      uistack(p2([2 3]),'top');
      
      
      axis square;
      set(gca,'Xlim',[-7400 -3900],'Ylim',[-8500 -3500]);
      cl=legend([p2(3) p2(2) p2(5) p2(1)],'with events','without','lin. regression','1:1','location','northeastoutside');
      pos=get(gca,'Position');
      set(cl,'Location','SouthEast');
      set(gca,'Position',pos);
      pos=get(cl,'Position');
      set(cl,'Position',pos+[0 0.1 0 0]);
      
      ytl=get(gca,'YTickLabel');
      ytl=ytl(:,2:end);
      set(gca,'YTickLabel',ytl);
      xtl=get(gca,'XTickLabel');
      xtl=xtl(:,2:end);
      set(gca,'XTickLabel',xtl);

      cl_print('name','onset','ext','pdf');

      
      
      
    end
    
    
 end

 save('transition_duration','timing','stiming','stranstime','transtime');
end






if any(doplots==9)
  load('transition_duration');
  load('event_in_transition');
  run('../../eventmodel.m');
  
  
  dtranstime=transtime(:,5)-transtime(:,1);
  dtiming=timing(:,5)-timing(:,1);
  
  a=[dtranstime dtiming timing(:,5) timing(:,1) ireg];
  %fprintf('%4d %4d %5d %5d %3d\n',a(itransreg,:)');
  
  hreg=278;
  
  farm1=100*clp_nc_trajectory('file','../../euroclim_0.0.nc','timelim',[-inf inf],'reg',hreg,'var','farming');
  farm5=100*clp_nc_trajectory('file','../../euroclim_0.3.nc','timelim',[-inf inf],'reg',hreg,'var','farming');
  
  
  
  figure(9); clf; 
  limit=[-8500 -3100];
  
  ax1=subplot(2,1,1); hold on;
  set(gca,'FontSize',15,'FontName','times');
  ev=revt(hreg,:); ev=1950-ev(ev>0); nev=length(ev);
     
  evalue=time*0;
  p9(1)=plot(time,100-evalue,'k--','color',mg,'LineWidth',3);
  for ie=1:nev;
    evalue=evalue+exp(-0.5*(ev(ie)-time).^2/flucperiod.^2);
  end
  evalue=evalue/max(evalue)*0.3;

  p9(2)=plot(time,100*(1-evalue),'k--','color','k','LineWidth',3);
  ylabel('Relative resources')
  
  set(gca,'XLim',limit,'YLim',[35 110]);
  xtl=get(gca,'XTickLabel');
  xtl=' ';
  set(gca,'XTickLabel',xtl);

  

  %----------------------
  ax2=subplot(2,1,2,'align'); cla; hold on;
    set(gca,'FontSize',15,'FontName','times');

  plot(time,farm1,'r-','color',mg,'LineWidth',3);
  plot(time,farm5,'b-','color','k','LineWidth',3);
  
  set(gca,'Yscale','log','Ylim',[0.3 130]);
    
  ir=find(hreg==ireg);
  plot(timing(ir,[1 5]),50,'k*','visible','off');
  set(gca,'Xlim',limit,'YMinorTick','on');

  i1=find(farm1>4.1 & farm1<=95);
  i5=find(farm5>4.1 & farm5<=95);
  
  p9(3)=plot(time(i1),repmat(2,numel(i1),1),'r-','color',mg,'LineWidth',5);
  p9(4)=plot(time(i5),repmat(1,numel(i5),1),'r-','color','k','LineWidth',5);
  
  text(-5815,0.9,'Transition duration','FontSize',9,'Horizontalalignment',...
      'center','vertical','top','fontName','Times');
  
  xlabel('Time (cal BC)');
  ylabel('Farmer share');
  %pos1=get(ax1,'Position');
  %pos2=get(ax2,'Position');
  %set(ax2,'Position',pos2+[0 pos1(2)-pos2(2)-pos2(4)-0.01 0 0]);
  
  legend([p9(4) p9(3)],'with events','without','location','east');
  
  
  ytl=get(gca,'YTickLabel');
  ytl='     ';
  set(gca,'YTickLabel',ytl);
    
  xtl=get(gca,'XTickLabel');
  xtl=xtl(:,2:end);
  set(gca,'XTickLabel',xtl);
    

  cl_print('name',sprintf('event_and_trajectory_%03d',hreg),'ext','pdf');

  % For pangaea
  cl_glues2grid('variables',{'farming_timing','region','technology','farming','population_density'},'file','../../euroclim_0.3.nc')  
  
end


if (10==10)
  for i=1:10:length(time(itime))
    url=sprintf('http://ncwms.hzg.de/ncWMS/wms?LAYERS=17%%2Fpopulation_density&ELEVATION=0&TIME=%5d-1-1T00%%3A00%%3A00.000Z&TRANSPARENT=true&STYLES=boxfill%%2Frainbow&CRS=EPSG%%3A4326&COLORSCALERANGE=0%%2C12&NUMCOLORBANDS=254&LOGSCALE=false&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&EXCEPTIONS=XML&FORMAT=application/vnd.google-earth.kmz&BBOX=-9.75,31.25,41.75,56.75&WIDTH=512&HEIGHT=400',time(itime(i)));
    filename=sprintf('euroclim_0.3_ncWMS_population_density_%05d.kmz',time(itime(i)));
    if ~exist(filename,'file')
      urlwrite(url,filename);
    end
  end
end





