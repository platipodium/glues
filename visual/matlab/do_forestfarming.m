%% User section, please adjust
% Run script for forest farming movies
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

% Define base directory and scenarios
predir='/Users/lemmen/devel/glues';
basename='eurolbk2010';
sces=0.4;

cl_nc_deforestation('file','../../euroclim_0.4.nc');


%--------------------------------------------------------------------------------
%% preparatory color, symbol and file handling 

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

evinreg=evinreg(ireg,:);
[ev,ievs]=unique(evinreg);
nev=length(ev);


evseriesfile=sprintf('EventSeries_134.tsv');
evseries=load(evseriesfile,'-ascii');

revt=load('../../RegionEventTimes.tsv','-ascii'); 

lg=repmat(0.8,1,3);
mg=repmat(0.55,1,3);
dg=repmat(0.3,1,3);

%---------------------------------------------------------------------
% Decide which plots to make
doplots=[1:100];


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
% Movie of farming activity
if any(doplots==33) 
  movtime=-7500:10:-3500;
  nmovtime=length(movtime);
  sce='0.3';
  for it=1:nmovtime
    [d,b]=clp_nc_variable('var','farming','reg','lbk','marble',3,'transparency',1,'nocolor',0,...
      'showstat',0,'lim',[0 1],'timelim',movtime(it),'nocbar',1,...
      'file',['../../eurolbk2010_base.nc'],'figoffset',0,'sce',[sce '_' sprintf('%03d_%05d',it,movtime(it))],'noprint',1);
    m_coast('color','k');
    m_grid('box','fancy','linestyle','none');
    peaki=find(abs(peakinfo(:,1)-movtime(it))<=175);
    for j=1:-length(peaki)
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


%--------------------------------------------------------------------------
% Movie of population density 
if any(doplots==34) 
  movtime=-7500:10:-3500;
  nmovtime=length(movtime);
  sce='0.3';
  for it=1:nmovtime
    [d,b]=clp_nc_variable('var','population_density','reg','ecl','marble',3,'transparency',1,'nocolor',0,...
      'showstat',0,'lim',[0 8],'timelim',movtime(it),'nocbar',1,'cmap','jet','ncol',19,...
      'file',['../../eurolbk2010_base.nc'],'figoffset',0,'sce',[sce '_' sprintf('%03d_%05d',it,movtime(it))],'noprint',1);
    m_coast('color','k');
    h=d.handle;
    h=h(h>0);
    m_grid('box','fancy','linestyle','none');
    peaki=find(abs(peakinfo(:,1)-movtime(it))<=175);
    for j=1:-length(peaki)
      strength=exp(-abs(peakinfo(peaki(j),1)-movtime(it))/20);
      rings=90:60:500*strength;
      if 500*strength<90 continue; end
      rings=rings+(peakinfo(peaki(j),1)-movtime(it))/5;
      clp_pulse(peakinfo(peaki(j),3),peakinfo(peaki(j),4),...
          'rings',rings,'col','k','MarkerSize',8); 
    end

    sitei=find(sites.time<movtime(it));
    if ~isempty(sitei) 
      m_plot(sites.longitude(sitei),sites.latitude(sitei),'k^');
    end
    title('GLUES population density');   
    cl_print('name',b,'ext','png','res',100);
  end
end


%--------------------------------------------------------------------------
% Movie of crop fraction 
if any(doplots==35) 
  movtime=-7500:10:-3500;
  %movtime=-4000;
  nmovtime=length(movtime);
  sce='0.3';
  ncol=19;
  for it=1:nmovtime
    [d,b]=clp_nc_variable('var','cropfraction_static','mult',100,'reg','ecl','marble',3,'transparency',1,'nocolor',0,...
      'showstat',0,'lim',[0 15],'timelim',movtime(it),'nocbar',0,'cmap','jet','ncol',ncol,...
      'file',['../../eurolbk2010_base.nc'],'figoffset',0,'sce',[sce '_' sprintf('%03d_%05d',it,movtime(it))],'noprint',1);
    m_coast('color','k');
    h=d.handle;
    h=h(h>0);
    m_grid('box','fancy','linestyle','none');
 
    sitei=find(sites.time<movtime(it));
    if ~isempty(sitei) 
      m_plot(sites.longitude(sitei),sites.latitude(sitei),'k^');
    end
    title('GLUES crop fraction');   
    
    cb=findobj(gcf,'tag','colorbar');
    ytl=get(cb,'YTickLabel');
    ytl=num2str(round(str2num(ytl)));
    set(cb,'YTickLabel',ytl);
    title(cb,'%');
    
    cmap=jet(ncol);
    cbpos=get(cb,'Position');
    ax2=axes('Position',cbpos);
    set(ax2,'xlim',[0.01 1.01],'Ylim',[-0.01 ncol + 0.01],...
        'XTick',[],'YTIck',[]);
    for icol=1:ncol
        patch([0 0 1 1 0],icol - 1 + [0 1 1 0 0],cmap(icol,:));
    end
   cl_print('name',b,'ext','png','res',100);
 
  end
end




%--------------------------------------------------------------------------
% Movie of carbon emission 
if any(doplots==36) 
  movtime=-6500:250:-3000;
  nmovtime=length(movtime);
  sce='0.3';
  ncol=19;
  for it=1:nmovtime
    [d,b]=clp_nc_variable('var','carbon_emission','reg','ecl','div',1E9,'marble',3,'transparency',1,'nocolor',0,...
      'showstat',0,'lim',[0 5],'timelim',movtime(it),'nocbar',0,'cmap','jet','ncol',ncol,...
      'file',['../../eurolbk2010_base.nc'],'figoffset',0,'sce',[sce '_' sprintf('%03d_%05d',it,movtime(it))],'noprint',1);
    m_coast('color','k');
    h=d.handle;
    h=h(h>0);
    m_grid('box','fancy','linestyle','none');
    peaki=find(abs(peakinfo(:,1)-movtime(it))<=175);
    for j=1:-length(peaki)
      strength=exp(-abs(peakinfo(peaki(j),1)-movtime(it))/20);
      rings=90:60:500*strength;
      if 500*strength<90 continue; end
      rings=rings+(peakinfo(peaki(j),1)-movtime(it))/5;
      clp_pulse(peakinfo(peaki(j),3),peakinfo(peaki(j),4),...
          'rings',rings,'col','k','MarkerSize',8); 
    end

    sitei=find(sites.time<movtime(it));
    if ~isempty(sitei) 
      m_plot(sites.longitude(sitei),sites.latitude(sitei),'k^');
    end
    title('GLUES carbon emission');   
    
    cb=findobj(gcf,'tag','colorbar');
    ytl=get(cb,'YTickLabel');
    ytl=num2str(round(str2num(ytl)));
    %set(cb,'YTickLabel',ytl);
    
    cmap=jet(ncol);
    cbpos=get(cb,'Position');
    ax2=axes('Position',cbpos);
    set(ax2,'xlim',[0.01 1.01],'Ylim',[-0.01 ncol + 0.01],...
        'XTick',[],'YTIck',[]);
    for icol=1:ncol
        patch([0 0 1 1 0],icol - 1 + [0 1 1 0 0],cmap(icol,:));
    end
    cl_print('name',b,'ext','png','res',100);
    
  end
end












% Read default scenario
file=fullfile(predir,['euroclim' '_0.3.nc']);
cl_nc_deforestation('file',file);

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

