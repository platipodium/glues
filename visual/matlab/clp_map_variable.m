function retdata=clp_map_variable(varargin)

global ivar nvar figoffset;

arguments = {...
  {'latlim',[27 55]},...
  {'lonlim',[-15 42]},...
  {'timelim',[5000,5000]},...
  {'reg','all'},...
  {'vars','Density'},...
  {'scale','absolute'},...
  {'figoffset',0},...
  {'zlim',},...
  {'timeunit','BP'},...
  {'marble',0},...
  {'seacolor',0.7*ones(1,3)},...
  {'landcolor',.8*ones(1,3)},...
  {'showsites',0}
};


cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

[d,f]=get_files;

% Choose 'emea' or 'China' or 'World'
%[regs,nreg,lonlim,latlim]=find_region_numbers(reg);
[regs,nreg,~,~]=find_region_numbers(reg);


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

infix=strrep(resultfilename,'result','');
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
    
   switch scale
      case 'absolute', ;
      otherwise ;
   end 
  
   minmax=[min(min(min(data(regs,itstart:itend)))),max(max(max(data(regs,itstart:itend))))];
   if exist('zlim','var') minmax=zlim; end
   
  cmap=colormap('hotcold');
  
  
  resvar=round(((data-minmax(1)))./(minmax(2)-minmax(1))*(length(cmap)-1))+1;
  resvar(resvar>length(cmap))=length(cmap);

  
  % Plot timeseries
  figure(ivar+nvar+figoffset); 
  clf reset;
   
  hold on;
  if isbp set(gca,'XDir','reverse'); end
  set(gca,'YLim',minmax);

  for ireg=1:length(regs)
    reg=regs(ireg);
    plot(r.time(itstart:itend),squeeze(data(reg,itstart:itend)),'k-','color',cmap(resvar(reg,itstart),:));
  end
  p1=plot(r.time(itstart:itend),squeeze(data(regs(1),itstart:itend)));
  set(p1,'Tag','timeseries','LineWidth',4);
 % title(sprint('%s (sum %f.1)',vars{ivar},sum(sum(data(regs,itend)))));
  hold off;
 
  
  fd=fullfile(d.plot,'variable');
  if  ~exist(fd,'file')
      mkdir(fd);
  end
  
  fd=fullfile(fd,strrep(r.variables{ivar},' ',''));
   if  ~exist(fd,'file')
      mkdir(fd);
  end
  
  
  aviname=fullfile(fd,['variable_' strrep(r.variables{ivar},' ','')]);
  if length(infix)>0 aviname=[aviname '_' infix]; end
  aviname=[aviname '.avi'];
  mov=avifile(aviname);
 
  pathlen=sum(region.path(:,:,1)>-999,2);

  seacolor=0.7*ones(1,3);
  landcolor=0.8*ones(1,3);
    
   
  % plot map
  figure(ivar+figoffset); 
  clf reset;
  set(ivar,'DoubleBuffer','on');    
  set(ivar,'PaperType','A4');
  hold on;
  pb=clp_basemap('lon',lonlim,'lat',latlim);
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
  
    
  titletext=r.variables{ivar};
  if length(infix)>0 titletext=[titletext '(' infix ')']; end
  ht=title(titletext,'interpreter','none');
 
  
  t=time(itstart);
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
      'color','y','FontWeight','bold','backgroundColor','none','EdgeColor','none');
       
  if exist('ylim','var') minmax=ylim; end
  set(gca,'Position',pos,'box','off');

  cc='b' ; % base color for alpha fading
  cchigh='b' ; % base color for highlighting

  threshold=0.1;
  
  hp=clp_regionpath('lat',latlim,'lon',lonlim,'draw','patch','col',cc);
  
  ival=find(hp>0);
  alpha(hp(ival),resvar(regs(ival),itstart)./64/1.6);
  for i=1:length(ival)
      
      set(hp(ival(i)),'ButtonDownFcn',@onclick,'UserData',squeeze(data(regs(ival(i)),itstart:itend)));
      ftime=find(data(regs(ival(i)),itstart:itend)>=threshold);
      if isempty(ftime) timing(ival(i))=NaN; else timing(ival(i))=r.time(min(ftime)); end
 
 end
 
if ~exist('regioncenter','var') regioncenter=region.center; end 
 
%ishow=find(regioncenter(regs,2)>lonlim(1) & regioncenter(regs,2)<lonlim(2) ...
%    & regioncenter(regs,1)>latlim(1) & regioncenter(regs,1)<latlim(2) ...
%   & isfinite(timing'));
 
%i5=find(timing(ishow)<-5000); 
%i6=find(timing(ishow)<-6000); 
%i7=find(timing(ishow)<-7000); 
%i4=find(timing(ishow)<-7000); set(tt(i4),'backgroundcolor',[1 1 1]);

 %&   set(hp(ishow),'FaceColor',[1 1 1],'FaceAlpha',0.1);
  %  set(hp(ishow(i5)),'FaceColor',[1 1 0],'FaceAlpha',0.25);
  %  set(hp(ishow(i6)),'FaceColor',[1 0.5 0],'FaceAlpha',0.25);
  %  set(hp(ishow(i7)),'FaceColor',[1 0 0],'FaceAlpha',0.25);

if (0) % colorbar
     
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

  ntime=itend-itstart+1;

  for it=itstart:1:itend
    t=time(it);
    if ~isbp
      if (t==0) t=1; end
      if (t<0)
          timeunit='BC';
          t=abs(t);
      else
        timeunit='AD';
      end
    end
    
     set(hbt,'String',[num2str(t) ' ' timeunit]);
  
     itprior=max(it-1,itstart);
     ichanged=find(resvar(regs,it)~=resvar(regs,itprior));
     for ir=1:length(ichanged)
      ireg=ichanged(ir);
      reg=regs(ireg);
      if hp(ireg)==0 continue; end
      if (resvar(reg,it)>1)
        h=hp(ireg);
        greyval=0.15+0.35*sqrt(resvar(reg,it)./64);
       alpha(h,greyval);
      
      if (abs(greyval-0.4)<0.1)
        set(hp(ireg),'FaceColor',cchigh);
      else  
       set(hp(ireg),'FaceColor',cc);
      end
      end
      %m_patch(region.path(reg,1:pathlen(reg),1),region.path(reg,1:pathlen(reg),2),cmap(resvar(reg,it),:));
     end
     
 showsites=1
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
    
    plotname=fullfile(fd,['marble_variable_' strrep(r.variables{ivar},' ','') '_']);
    if length(infix)>0 plotname=[plotname infix '_']; end
    plotname=[plotname sprintf('%05d_%d',12000-t,t)];
   
    
    if mod(t,100)==0
    %mod(it,4)==1
    %plot_multi_format(gcf,plotname);
    end
    
    f=getframe(gcf);
     %if (abs(tend-tstart)>10*r.tstep) mov=addframe(mov,f); end;
    mov=addframe(mov,f);
    fprintf('.');
    if mod(it,80)==0 fprintf('\n'); end
    %it=it+1;
  end
  %if (tend-tstart>10*r.tstep) 
  mov=close(mov); 
  %end;
  
end
return;
end


function offclick(gcbo,eventdata,handles)
set(gcbo,'ButtonDownFcn',@onclick);
set(gcbo,'EdgeColor','k');
set(gcbo,'LineWidth',0.5);
return;
end

function onclick(gcbo,eventdata,handles)
global ivar nvar figoffset;
uf=gcf;
ud=get(gcbo,'UserData');
set(gcbo,'EdgeColor','y');
set(gcbo,'LineWidth',4);

figure(ivar+nvar+figoffset);
children=get(gca,'Children');
c=get(children,'Tag');
ic=strmatch('timeseries',c);
pr=children(ic);
set(pr,'YData',ud,'LineWidth',4,'Color','y');
set(gcbo,'ButtonDownFcn',@offclick);
figure(uf);
return;
end