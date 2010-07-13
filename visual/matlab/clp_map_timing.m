function rdata=clp_map_timing(varargin)

global ivar nvar figoffset;

arguments = {...
  {'latlim',[-Inf,Inf]},...
  {'lonlim',[Inf,Inf]},...
  {'timelim',[12000,500]},...
  {'reg','all'},...
  {'vars','Farming'},...
  {'threshold',0.5},...
  {'scale','absolute'},...
  {'figoffset',0},...
  {'ylimit',[-Inf,Inf]},...
  {'timeunit','BP'},...
  {'timestep',1},...
  {'marble',0},...
  {'seacolor',0.7*ones(1,3)},...
  {'landcolor',.8*ones(1,3)},...
  {'transparency',1},...
  {'snapyear',1000},...
  {'movie',1},...
  {'cmap',0},...
  {'projection','miller'},...
  {'showsites',0},...
  {'notitle',0}...
  {'nocbar',0},...
  {'ncol',19};
};

% For Europe:
%  {'latlim',[27 55]},...
%  {'lonlim',[-15 42]},...


cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

[d,f]=get_files;

% Choose 'emea' or 'China' or 'World'
%[regs,nreg,lonlim,latlim]=find_region_numbers(reg);
[regs,nreg,loli,lali]=find_region_numbers(reg);
loli(isfinite(lonlim))=lonlim(isfinite(lonlim));
lali(isfinite(latlim))=latlim(isfinite(latlim));
latlim=lali;
lonlim=loli;


% Get region path
load('regionpath_685');
if ~exist('region','var')
    region.path=regionpath;
end
region.path(:,:,1)=region.path(:,:,1)+0.5;
region.path(:,:,2)=region.path(:,:,2)+1.0;

% Todo: make this dynamic
resultfilename='results';

% Todo: add scenario argument
%if exist('scenario','var')
%    resultfilename=[resultfilename '_' scenario];
%end

latrange=abs(latlim(2)-latlim(1));
lonrange=abs(lonlim(2)-lonlim(1));
  
if exist([resultfilename '.mat'],'file') load(resultfilename); else 
    fprintf('Cannot find file %s\n',resultfilename);
    error('No result file read')
    return; 
end

infix=strrep(resultfilename,'results','');
if length(infix)>0
  while infix(1)=='_' infix=infix(2:end); end
end

load('neolithicsites');
slat=Forenbaher.Latitude;
slon=Forenbaher.Long;
sage=Forenbaher.Median_age;
n=length(slat);
ntime=size(r.Density,2);
 

%load('Pinhasi-sites');
%slat=sites.Latitude;
%slon=sites.Longitude;
%sage=1950-sites.CALC14BP;

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

if length(timelim)==1 timelim(2)=timelim(1); end

isbp=1;
if all(r.time>=0)
  toffset=500;
  tstart=min([r.tend+toffset,timelim(1)]);
  tend=max([r.tstart+toffset,timelim(2)]);
  r.time=r.time+toffset;
else
  tstart=max([r.tstart,timelim(1)]);
  tend=min([r.tend,timelim(2)]);
  timeunit='AD';
  isbp=0;
end


time=r.time;
    
[tmax,itend]=min(abs(time-tend));
[tmin,itstart]=min(abs(time-tstart));

timespan=abs(time(itstart)-time(itend));
if timespan>0
  ntime=ceil(timespan/timestep);
  itime=itstart:ceil((itend-itstart)/ntime):itend;
else 
  ntime=1;
  itime=itstart;
end
  
if isempty(itime) error('No timing found in specified interval'); end

if itime(end)~=itend itime=[itime itend]; end
time=time(itime);

retdata=zeros(nvar,itend-itstart+1,length(regs))+NaN;

if numel(cmap)<3 cmap=colormap(jet(ncol)); end
cmap=flipud(cmap);
ncol=length(cmap(:,1));


for idovar=1:nvar
    
  ivar=dovar(idovar);
  data=eval(['r.' r.variables{ivar}]);
  retdata(idovar,:,:)=data(squeeze(regs),itstart:itend)';
      
 
%% Make directory for plots and prepare files  
  
  fd=fullfile(d.plot,'variable');
  if ~exist(fd,'file') mkdir(fd); end
  
  fd=fullfile(fd,'timing');
  if ~exist(fd,'file') mkdir(fd); end
  
 
%% Plot base map  
  pathlen=sum(region.path(:,:,1)>-999,2);

  seacolor=0.7*ones(1,3);
  landcolor=0.8*ones(1,3);  
   
  figure(ivar+figoffset); 
  clf reset;
  set(ivar,'DoubleBuffer','on','ActivePositionProperty','outerposition');    
  set(ivar,'PaperType','A4');
  hold on;
  pb=clp_basemap('lon',lonlim,'lat',latlim,'projection',projection);
  if (marble>0)
    pm=clp_marble('lon',lonlim,'lat',latlim);
    if pm>0 alpha(pm,marble); end
  
  else
    m_coast('patch',landcolor);
    % only needed for empty (non-marble background) to get rid of lakes
    c=get(gca,'Children');
    ipatch=find(strcmp(get(c(:),'Type'),'patch'));
    npatch=length(ipatch);
    if npatch>0
      iwhite=find(sum(cell2mat(get(c(ipatch),'FaceColor')),2)==3);
      if ~isempty(iwhite) set(c(ipatch(iwhite)),'FaceColor',seacolor);
      end
    end
  
  end
  
  %% Add title and determine time units
  titletext=['Time of ' r.variables{ivar} ' > ' num2str(threshold) ];
  if length(infix)>0 titletext=[titletext '(' infix ')']; end
  if ~notitle ht=title(titletext,'interpreter','none'); end
 
  
  t=r.time(itstart);
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
        
  
  set(gca,'Position',pos,'box','off');
  
  %% Invisible plotting of all regions
  hp=clp_regionpath('lat',latlim,'lon',lonlim,'draw','patch','col',landcolor,'reg',reg);  
  ival=find(hp>0);
  alpha(hp(ival),0);
  
  for i=1:length(ival)
    ireg=regs(ival(i));
    if (hp(ival(i))==0) continue; end
    ftime=find(data(ireg,itstart:itend)>=threshold);
    if isempty(ftime) timing(ireg)=NaN; else timing(ireg)=time(min(ftime)); end
  end
 
  minmax=[min(timing),max(timing)];
  
  ylimit(~isfinite(ylimit))=minmax(~isfinite(ylimit));

  resvar=round(((timing-ylimit(1)))./(ylimit(2)-ylimit(1))*(ncol-1))+1;
  resvar(resvar>length(cmap))=length(cmap);
  resvar(resvar<1)=1;
  
 
  if ~exist('regioncenter','var') regioncenter=region.center; end 
 
if (nocbar == 0) % colorbar
     
cbw=0.4;  %  (relative width of colorbar)
cbxo=0.07; %(x-offset of colorbar)
cbyo=0.95;
cbh=0.05;
cby=latlim(1)+(cbyo+[0,0,cbh,cbh])*(latlim(2)-latlim(1));
cbx=lonlim(1)+(cbxo+[0,cbw,cbw,0])*(lonlim(2)-lonlim(1));
cbyw=latlim(1)+(cbyo+[-2.2*cbh,-2.2*cbh,cbh,cbh])*(latlim(2)-latlim(1));
cbxw=lonlim(1)+(cbxo+[-cbxo,cbw+cbxo,cbw+cbxo,-cbxo])*(lonlim(2)-lonlim(1));


m_patch(cbxw,cbyw,'w');
m_patch(cbx,cby,'w','EdgeColor','none');
for i=1:ncol
  cba(i)=m_patch(lonlim(1)+(cbxo+cbw/ncol*(i-1)+[0,cbw/ncol,cbw/ncol,0])*(lonlim(2)-lonlim(1)),cby,cmap(i,:),'EdgeColor','none');
  greyval=0.15+0.35*sqrt(i./ncol);
  %greyval=0.15+0.65*sqrt(i./ncol);
  %if (abs(greyval-0.4)>0.1) set(cba(i),'FaceColor',cchigh); end
  
  alpha(cba(i),greyval);
end

cbtv=scale_precision(ylimit(1):(ylimit(2)-ylimit(1))/4.0:ylimit(2),2);
j=0;
for i=0:ncol/4:ncol
    j=j+1;
    cbt(j)=m_text(lonlim(1)+(cbxo+cbw/ncol*i)*(lonlim(2)-lonlim(1)),cby(1)-5*cbh,num2str(cbtv(j)),...
        'horiz','center','vertical','top');
end

cbt(j+1)=m_text(0.5*(cbx(1)+cbx(2)),0.92*cby(1),'Calendar year','horiz','center','vertical','top');
end




%% Correct the size/position of the figure when axis labels are off screen

set(gca,'outerposition',[0 0 1 1]);

for ireg=1:nreg
   if hp(ireg)==0 continue; end
   h=hp(ireg);
   greyval=0.15+0.35*sqrt(resvar(regs(ireg))./ncol);
   if isnan(greyval) continue; end
   alpha(h,greyval);
      
    set(hp(ireg),'FaceColor',cmap(resvar(regs(ireg)),:));
      %m_patch(region.path(reg,1:pathlen(reg),1),region.path(reg,1:pathlen(reg),2),cmap(resvar(reg,it),:)); end
end    
     
     
  if showsites 
     isite=find(sage<time(it) & slat>latlim(1) & slat<latlim(2) & slon>lonlim(1) & slon<lonlim(2));
     if ~isempty(isite)
      m_line(slon(isite),slat(isite),'MarkerEdgeColor','k','MarkerFaceColor','w','LineStyle','none','Marker','o','MarkerSize',4.0);
     end
     isite=find(abs(sage-time(it))<101 & slat>latlim(1) & slat<latlim(2) & slon>lonlim(1) & slon<lonlim(2));
     if ~isempty(isite)
      m_line(slon(isite),slat(isite),'MarkerEdgeColor','k','MarkerFaceColor','y','LineStyle','none','Marker','o','MarkerSize',4.0);
     end
       
  end

  obj=findall(gcf,'-property','FontSize');
  set(obj,'FontSize',15);
  
  set(cbt,'FontSize',11);

  %%
  
  plotname=fullfile(fd,['map_timing_' strrep(r.variables{ivar},' ','') '_']);
  plotname=[plotname sprintf('%03d_%03d_',latlim(1),latlim(2))];
  if length(infix)>0 plotname=[plotname infix '_']; end
    
  plot_multi_format(gcf,plotname);
  
  if 1==0
  figure(ivar*2+figoffset)
  ivalid=find(timing~=0 & isfinite(timing));
  edges=[-3500:500:1500];
  [n,bin]=histc(timing(ivalid),edges);
  bar(edges,n,'histc');
  end    
  
end % of for loop for idovar

hold off;

if nargout>0 
  rdata=retdata;
end

return;
end

