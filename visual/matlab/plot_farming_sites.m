function plot_farming_sites(varargin)

cl_register_function();

[d,f]=get_files;

pathfile='regionpath_685.mat';

if ~exist(pathfile,'file')
    fprintf('Required file regionpath.mat not found, please run calc_regionmap_outline.\n');
    return
end

load(pathfile);
if ~exist('region','var')
    region.path=regionpath;
end

if ~exist('neolithicsites.mat','file')
    fprintf('Required file neolithicsites.mat not found, please contact distributor.\n');
    return
end

vars={'Farming'};

load('neolithicsites');

lat=Forenbaher.Latitude;
lon=Forenbaher.Long;
period=Forenbaher.Period;
site=Forenbaher.Site_name;
age=Forenbaher.Median_age;
n=length(lat);

regs=find_region_numbers('med','fil',pathfile);
thresh=0.3;
resultfilename='result_iiasaclimber_ref_all.mat';
resultfilename='results.mat';

if nargin==1
  if all(isletter(varargin{1})) var=varargin{1};
  else regs=varargin{1};
  end
elseif nargin>1
  for iarg=1:2:nargin
    switch lower(varargin{iarg}(1:3))
      case 'reg' 
        regs=varargin{iarg+1};
      case 'thr'
        thresh=varargin{iarg+1};
      case 'res'
        resultfilename=varargin{iarg+1};    
      case 'var'
        vars=varargin{iarg+1};    
    end
  end
end


if ~exist(resultfilename,'file')
    error('Result file does not exist. Please create first with read_result');
    return
end

if findstr(resultfilename,'nofluc') infix='_nofluc';
elseif findstr(resultfilename,'_fluc') infix='_fluc';
else infix='';
end

if findstr(resultfilename,'nospread') infix=[infix '_nospread'];
elseif findstr(resultfilename,'_spread') infix=[infix '_spread'];
end

load(resultfilename);

nvar=length(vars);
for ivar=1:nvar
    m=strmatch(vars{ivar},r.variables,'exact');
    if isempty(m)
        warning('Variable "%s" not found in result file. Skipped',vars{ivar});
    else dovar(ivar)=m;
    end
end

dovar=dovar(find(dovar>0));
nvar=length(dovar);


farm=[1:n];
nfarm=length(farm);

time=12000-[r.tstart:r.tstep:r.tend];
toffset=500;

for ivar=dovar
  figure(ivar);
  set(gcf,'PaperOrientation','landscape');
  clf reset;
  %cmap=colormap(rainbow(64));
  
  cmap=colormap('hot');
  data=eval(['r.' r.variables{ivar}]);

  above=(squeeze(data(regs,:))>=thresh);
  for i=1:length(regs)  
    f=find(above(i,:));
    if ~isempty(f) threshtime(i)=r.tstart+min(f)*r.tstep;
    else threshtime(i)=r.tend;
    end
  end
 
  
  threshtime(threshtime>r.tend-3500)=r.tend-3500; 
  threshtime=r.tend-threshtime+toffset;
  threshmin=min(threshtime);
  threshmax=10000;%max(threshtime);
  if threshmax<=threshmin continue; end
  
  %cmap=round(cmap*2)./2.;
  ctime=64-round(((threshtime-threshmin)./(threshmax-threshmin)*(length(cmap)-1)));
  xtickgap=round((threshmax-threshmin)/5);
  xtickvalues=[threshmax:-xtickgap:threshmin];
  clear regioncenter;
  
  m_proj('Miller','lon',[-15,42],'lat',[27,55]);
  m_grid; 
  %m_names;
  for ireg=1:length(regs)
    reg=regs(ireg);
    valid=find(isfinite(region.path(regs(ireg),:,1)) & region.path(regs(ireg),:,1)>-199);
    regioncenter(ireg,1:2)=mean([region.path(regs(ireg),valid,1)+0.5;region.path(regs(ireg),valid,2)+1]',1);
    hdl(i)=m_patch(region.path(regs(ireg),valid,1)+0.5,region.path(regs(ireg),valid,2)+1,cmap(ctime(ireg),:));
    h=hdl(i);
    set(h,'ButtonDownFcn',@onclick,'UserData',squeeze(data(reg,:)));
  end
  
  ftime=length(cmap)-round((age-threshmin)./(threshmax-threshmin)*(length(cmap)-1));
%  m_line(lon(farm),lat(farm),'MarkerEdgeColor','k','MarkerFaceColor','none','Marker','o','LineStyle','none'); 

  for isite=1:nfarm
    site=farm(isite);
    %if ftime(site)<1; continue; end
    distlons=reshape([repmat(lon(site),nfarm,1),lon']',2*nfarm,1);
    distlats=reshape([repmat(lat(site),nfarm,1),lat']',2*nfarm,1);
    dist=m_lldist(distlons,distlats);
    inear=find(dist(1:2:end)<100);
    earliest(isite)=max(age(inear));
  end

  earliest(find(earliest>threshmax))=threshmax;
  etime=length(cmap)-round((earliest-threshmin)./(threshmax-threshmin)*(length(cmap)-1));
  
  for isite=1:nfarm
    site=farm(isite);
    %if etime(site)<1; continue; end
    m_line(lon(site),lat(site),'MarkerEdgeColor','k','MarkerFaceColor',cmap(etime(site),:),'LineStyle','none','Marker','o');
    distlons=reshape([repmat(lon(site),length(regs),1),regioncenter(:,1)]',2*length(regs),1);
    distlats=reshape([repmat(lat(site),length(regs),1),regioncenter(:,2)]',2*length(regs),1);
    dist=m_lldist(distlons,distlats);
    dist(find(dist>1000))=10000;
    distweight=exp(-dist(1:2:end)/500);
    disttime=age(site)-threshtime';
    timeerror_s(isite)=sum(disttime.*distweight)/sum(distweight);
    distetime=earliest(isite)-threshtime';
    timeerror_e(isite)=sum(distetime.*distweight)/sum(distweight);
  end
    
   fprintf('Site error: mean %4d / abs mean %4d years\n',round(mean(timeerror_s)),round(mean(abs(timeerror_s))));
   fprintf('Early error: mean %4d / abs mean %4d years\n',round(mean(timeerror_e)),round(mean(abs(timeerror_e))));
   
   for ireg=1:length(regs)
    distlons=reshape([repmat(regioncenter(ireg,1),nfarm,1),lon'],2*nfarm,1);
    distlats=reshape([repmat(regioncenter(ireg,2),nfarm,1),lat'],2*nfarm,1);
    dist=m_lldist(distlons,distlats);
    dist(find(dist>1000))=10000;
    distweight=exp(-dist(1:2:end)/500);
    disttime=age'-threshtime(ireg);
    timeerror(ireg)=sum(disttime.*distweight)/sum(distweight);
  end
    
   fprintf('Sim  error: mean %4d / abs mean %4d years\n',round(mean(timeerror)),round(mean(abs(timeerror))));
     
  
   
   p=patch([0.2,0.48,0.48,0.2],[1.034,1.034,1.133,1.133],'w');
   if length(infix)>0 headl=text(0.01,1.12,['Onset of farming (' strrep(infix,'_','\_') ')']);
   else headl=text(0.206,1.12,'Onset of farming');
   end
   set(headl,'FontSize',12,'FontWeight','bold','Color','k');
   text(0.206,1.08,['at ' num2str(thresh*100) '% level'],'FontSize',8);
   text(0.206,1.05,'model (area) + data (dots)','FontSize',8);
 

  hc=colorbar('horiz');
  set(hc,'Xticklabel',xtickvalues);
  set(hc,'Position',[0.1300    0.1800    0.560    0.025]);
  hcti=get(hc,'title');
  set(hcti,'String','years before present','Position',[1.2 -1 2]);
 %m_coast;
  set(hc,'XAxisLocation','bottom');
  hold off;
  
  
  plot_multi_format(gcf,fullfile(d.plot,['farming_sites' infix '_' num2str(thresh) ]));
  %legend
  
  figure(4); clf reset;
   
  hold on;
  set(gca,'XDir','reverse');
  set(gca,'YLim',[0 1]);
  plot(time,thresh,'k--');

  for ireg=1:length(regs)
    reg=regs(ireg);
    plot(time,squeeze(data(reg,:)),'k-','color',cmap(ctime(ireg),:));
  end
    p1=plot(time,squeeze(data(regs(1),:)));
  set(p1,'Tag','timeseries','LineWidth',4);
  hold off;
  
  figure(5); clf reset;
  hold on;
  m_proj('Miller','lon',[-15,42],'lat',[27,55]);
  m_grid; 
  timeerrormax=max(abs(timeerror));
  ctimeerror=64-round(((timeerror-(-timeerrormax))./(2*timeerrormax)*(length(cmap)-1)));
  ctimeerror(find(ctimeerror==0))=1;
 for ireg=1:length(regs)
    reg=regs(ireg);
    valid=find(isfinite(region.path(regs(ireg),:,1)) & region.path(regs(ireg),:,1)>-199);
    m_patch(region.path(regs(ireg),valid,1)+0.5,region.path(regs(ireg),valid,2)+1,cmap(ctimeerror(ireg),:));
 end
  colorbar;
hold off;  

end


return

function offclick(gcbo,eventdata,handles)
set(gcbo,'ButtonDownFcn',@onclick);
return;

function onclick(gcbo,eventdata,handles)
uf=gcf;
ud=get(gcbo,'UserData');
figure(4);
children=get(gca,'Children');
c=get(children,'Tag');
ic=strmatch('timeseries',c);
pr=children(ic);
set(pr,'YData',ud);
set(gcbo,'ButtonDownFcn',@offclick);
figure(uf);
return;
