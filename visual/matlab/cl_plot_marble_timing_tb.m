function cl_plot_marble_timing_tb(varargin)

cl_register_function();

global ivar nvar figoffset

nreg=685;
showsites=1;

[d,f]=get_files;
retdata=NaN;

load(['regionpath_' num2str(nreg)]);

% Choose 'emea' or 'China' or 'World'
[regs,nreg,lonlim,latlim]=find_region_numbers('emea');

if ~exist('region','var')
    region.path=regionpath;
end

region.path(:,:,1)=region.path(:,:,1)+0.5;
region.path(:,:,2)=region.path(:,:,2)+1.0;

figoffset=0;
        
vars={'Farming'}
%vars={'Technology','Farming','Climate'};

%vars={'Density'};
%vars={'Migration','Agricultures','CivStart','Climate'};
%vars={'Agricultures','Migration'};
mode='absolute';
resultfilename='result_iiasaclimber_ref_all';
resultfilename='results';

  for iarg=1:nargin 
    if all(isletter(varargin{iarg}))
    switch lower(varargin{iarg}(1:3))
      case 'reg' 
        regs=varargin{iarg+1};
      case 'var'
        vars=varargin{iarg+1};
      case 'tim'
        timelim=varargin{iarg+1};
        case 'fig'
            figoffset=varargin{iarg+1};
        case 'mod'
            mode=vararbin{iarg+1};
        case 'res'
             resultfilename=varargin{iarg+1};
        case 'lat'
             latlim=varargin{iarg+1};
        case 'lon'
             lonlim=varargin{iarg+1};
        case 'yli'
             ylim=varargin{iarg+1};
        case 'sce'
            scenario=varargin{iarg+1};
     end
    iarg=iarg+2;
     end
  end
  
if ~exist('lonlim','var') lonlim=[-15,42]; end
if ~exist('latlim','var') latlim=[27,55]; end
if ~exist('timelim','var') timelim=[11000,5000]; end;
if ~exist('timeunit','var') timeunit='BP'; end;
if exist('scenario','var')
    resultfilename=[resultfilename '_' scenario];
end



latrange=abs(latlim(2)-latlim(1));
lonrange=abs(lonlim(2)-lonlim(1));
  
if exist([resultfilename '.mat'],'file') load(resultfilename); else 
    fprintf('Cannot find file %s\n',resultfilename);
    warning('No result file read')
    return; 
end

infix=strrep(resultfilename,'result','');
if length(infix)>0
  while infix(1)=='_' infix=infix(2:end); end
end

if iscell(vars) 
    nvar=length(vars);
for ivar=1:nvar
    
    
    m=strmatch(vars{ivar},r.variables,'exact');
    if isempty(m)
        switch(vars{ivar})
            case 'Methane'
          dovar(ivar)=length(r.variables)+1;
          r.variables{dovar(ivar)}='Methane'
          people=r.Density.*repmat(region.area',1,ntime);
          farmers=people.*r.Farming;
          r.Methane=methane_emission(farmers)/1E4;
            case 'Cropfraction'
               dovar(ivar)=length(r.variables)+1;
           r.variables{dovar(ivar)}='Cropfraction';
           load('region_hyde_685.mat');
           r.Cropfraction=climate.crop;
       
            case 'HydePopulationDensity'
               dovar(ivar)=length(r.variables)+1;
           r.variables{dovar(ivar)}='HydePopulationDensity';
           load('region_hyde_685.mat');
           r.HydePopulationDensity=climate.popd;
       
            case 'HydePopulationCount'
               dovar(ivar)=length(r.variables)+1;
           r.variables{dovar(ivar)}='HydePopulationCount';
           load('region_hyde_685.mat');
           r.HydePopulationCount=climate.popc;
 
            case 'GluesRemainingForest'
              dovar(ivar)=length(r.variables)+1;
           r.variables{dovar(ivar)}='GluesRemainingForest';
           load('hyde_glues_cropfraction.mat');
           r.GluesRemainingForest=remainingforest;

            case 'GluesCropfraction'
              dovar(ivar)=length(r.variables)+1;
           r.variables{dovar(ivar)}='GluesCropfraction';
           load('hyde_glues_cropfraction.mat');
           r.GluesCropfraction=cropfraction;
          
           case 'GluesNaturalForest'
              dovar(ivar)=length(r.variables)+1;
           r.variables{dovar(ivar)}='GluesNaturalForest';
           load('hyde_glues_cropfraction.mat');
           r.GluesNaturalForest=naturalforest;
           case 'GluesDeforestation'
              dovar(ivar)=length(r.variables)+1;
           r.variables{dovar(ivar)}='GluesDeforestation';
           load('hyde_glues_cropfraction.mat');
           r.GluesDeforestation=deforestation/10E9;
             otherwise 
              warning('Variable "%s" not found in result file. Skipped',vars{ivar});
        end
        
    else dovar(ivar)=m;
    end
end
else nvar=1; 
    m=strmatch(vars,r.variables,'exact');
    if isempty(m)
        warning('Variable "%s" not found in result file. Skipped',vars);
    else dovar=m;
    end
end

 
if ~exist('dovar','var') return; end;

dovar=dovar(find(dovar>0));
nvar=length(dovar);

isbp=1;
if all(r.time>=0)
  toffset=500;
  tstart=min([r.tend+toffset,timelim(1)]);
  tend=max([r.tstart+toffset,timelim(2)]);
  r.time=r.time+toffset;
else
  tstart=max([r.tstart,2000-timelim(1)]);
  tend=min([r.tend,2000-timelim(2)]);
  timeunit='AD';
  isbp=0;
end


 time=r.time;
    
[tmax,itend]=min(abs(time-tend));
[tmin,itstart]=min(abs(time-tstart));

ntime=itend-itstart+1;

retdata=zeros(nvar,ntime,length(regs))+NaN;

for idovar=1:nvar
    
    ivar=dovar(idovar);

    
   data=eval(['r.' r.variables{ivar}]);

   retdata(idovar,:,:)=data(squeeze(regs),itstart:itend)';
    
   switch mode
      case 'absolute', ;
      otherwise ;
   end 
  
   minmax=[min(min(min(data(regs,itstart:itend)))),max(max(max(data(regs,itstart:itend))))];
   if exist('ylim','var') minmax=ylim; end
   
  cmap=colormap('hotcold');
  
  
  resvar=round(((data-minmax(1)))./(minmax(2)-minmax(1))*(length(cmap)-1))+1;
  resvar(resvar>length(cmap))=length(cmap);

  
  % Plot timeseries
  figure(ivar+nvar+figoffset); 
  clf reset;
   
  hold on;
  if isbp set(gca,'XDir','reverse'); end
  set(gca,'YLim',minmax);
  threshold=0.5; %.33333;

  for ireg=1:length(regs)
    reg=regs(ireg);
    plot(r.time(itstart:itend),squeeze(data(reg,itstart:itend)),'k-','color',cmap(resvar(reg,itend),:));
    ftime=find(data(reg,itstart:itend)>=threshold);
    if isempty(ftime) timing(ireg)=NaN; else timing(ireg)=r.time(min(ftime)); end
  end
  
  p1=plot(r.time(itstart:itend),squeeze(data(regs(1),itstart:itend)));
  set(p1,'Tag','timeseries','LineWidth',4);
 % title(sprint('%s (sum %f.1)',vars{ivar},sum(sum(data(regs,itend)))));
  hold off;
 
   
  % plot map
  figure(ivar+figoffset); 
  clf reset;
  %set(ivar,'PaperOrientation','landscape');
  set(ivar,'PaperType','A4');
  %set(ivar,'Position',[442   188  607  442]);
  
  fd=fullfile(d.plot,'variable');
  if  ~exist(fd,'file')
      mkdir(fd);
  end
  
  fd=fullfile(fd,strrep(r.variables{ivar},' ',''));
   if  ~exist(fd,'file')
      mkdir(fd);
  end
 
  pathlen=sum(region.path(:,:,1)>-999,2);

  color_sea=0.7*ones(1,3);
  color_land=0.8*ones(1,3);
    
  clf;
  
  m_proj('equidistant','lon',lonlim,'lat',latlim);
  m_grid;%('backcolor',color_sea);
   %m_coast;
   hold on;
  pm=cl_plot_marble(lonlim,latlim,'TrueMarble.8km.5400x2700.tif');
  %pm=cl_plot_marble(lonlim,latlim,'visual_earth_8192.tiff');
  
  if pm>0 alpha(pm,1.0); end
   
  
  titletext=r.variables{ivar};
  if length(infix)>0 titletext=[titletext '(' infix ')']; end
  
  %ht=title('Timing of transition to farming up to 3000 BC','interpreter','none');
  set(gcf,'Userdata',titletext);
  
  
  t=time(itend);
  if ~isbp
    if (t==0) t=1; end
    if (t<0)
        timeunit='BC';
        t=abs(t);
    else
        timeunit='AD';
    end
  end
    
  pos=[0.08 0.0 0.83 0.91];
  
  %hbt=m_text(lonlim(1)+0.02*lonrange,latlim(2)-0.2*latrange,[num2str(t) ' ' timeunit],'backgroundColor','y','EdgeColor','k');
  hbt=m_text(lonlim(1)+0.02*lonrange,latlim(2)-0.2*latrange,[num2str(t) ' ' timeunit],...
      'color','y','FontWeight','bold','backgroundColor','none','EdgeColor','none','Visible','off');
       
  if exist('ylim','var') minmax=ylim; end
  set(gca,'Position',pos,'box','off');

  cc='b' ; % base color for alpha fading
  cchigh='b' ; % base color for highlighting

  
  
    
load('neolithicsites');
plat=Forenbaher.Latitude;
plon=Forenbaher.Long;
ptime=1950-Forenbaher.Median_age;    

ishow=find(plat<latlim(2) & plat>latlim(1) & plon<lonlim(2) & plon>lonlim(1) ...
    & ptime<-4000);

for i=1:length(ishow)
pt(i)=m_plot(plon(ishow(i)),plat(ishow(i)),'wo');
end

i5=find(ptime(ishow)<-5000); set(pt(ishow(i5)),'color',[1 1 0]);
i6=find(ptime(ishow)<-6000); set(pt(ishow(i6)),'color',[1 0.5 0]);
i7=find(ptime(ishow)<-7000); set(pt(ishow(i7)),'color',[1 0 0]);

  
  
 for ireg=1:length(regs)
      reg=regs(ireg);
      hp(ireg)=m_patch(region.path(reg,1:pathlen(reg),1),region.path(reg,1:pathlen(reg),2),cc,'EdgeColor','none');
      h=hp(ireg);
      if (h<=0) continue; end
      alpha(h,resvar(reg,itend)./64/2.5);
 end
   
if (0) % plot the colorbar
cbw=0.4;  %  (relative width of colorbar)
cbxo=0.15; %(x-offset of colorbar)
cbyo=0.04;
cbh=0.03;
cby=latlim(1)+(cbyo+[0,0,cbh,cbh])*(latlim(2)-latlim(1));
cbx=lonlim(1)+(cbxo+[0,cbw,cbw,0])*(lonlim(2)-lonlim(1));

m_patch(cbx,cby,'w');
for i=1:64
  cba(i)=m_patch(lonlim(1)+(cbxo+cbw/64*(i-1)+[0,cbw/64,cbw/64,0])*(lonlim(2)-lonlim(1)),cby,cc,'EdgeColor','none');
  alpha(cba(i),i/64.0/1.6);
end

cbtv=scale_precision(minmax(1):(minmax(2)-minmax(1))/4.0:minmax(2),2);
j=0;
for i=0:16:64
    j=j+1;
    m_text(lonlim(1)+(cbxo+cbw/64*i)*(lonlim(2)-lonlim(1)),cby(end),num2str(cbtv(j)),...
        'horiz','center','vertical','bottom');
end

end

if ~exist('regioncenter','var') regioncenter=region.center; end

ishow=find(regioncenter(regs,2)>lonlim(1) & regioncenter(regs,2)<lonlim(2) ...
    & regioncenter(regs,1)>latlim(1) & regioncenter(regs,1)<latlim(2) ...
   & isfinite(timing') & hp'>0);

tt=m_text(regioncenter(regs(ishow),2),regioncenter(regs(ishow),1),num2str(-timing(ishow)'),...
    'HorizontalAlignment','center','backgroundcolor','w');

i5=find(timing(ishow)<-5000); set(tt(i5),'backgroundcolor',[1 1 0]);
i6=find(timing(ishow)<-6000); set(tt(i6),'backgroundcolor',[1 0.5 0]);
i7=find(timing(ishow)<-7000); set(tt(i7),'backgroundcolor',[1 0 0]);
%i4=find(timing(ishow)<-7000); set(tt(i4),'backgroundcolor',[1 1 1]);


    set(hp(find(hp>0)),'FaceColor','none','FaceAlpha',0.0);
    set(hp(ishow),'FaceColor',[1 1 1],'FaceAlpha',0.0);
    set(hp(ishow(i5)),'FaceColor',[1 1 0],'FaceAlpha',0.35);
    set(hp(ishow(i6)),'FaceColor',[1 0.5 0],'FaceAlpha',0.35);
    set(hp(ishow(i7)),'FaceColor',[1 0 0],'FaceAlpha',0.35);
%set(hp(find(hp>0)),'EdgeColor',[0.2 0.2 0.2]);


    plotname=fullfile(fd,['marble_timing_tb_' strrep(r.variables{ivar},' ','')]);
    if length(infix)>0 plotname=[plotname '_' infix]; end
    plot_multi_format(gcf,plotname);



end
return;
end

