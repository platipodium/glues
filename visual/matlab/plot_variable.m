function plot_variable(varargin)

cl_register_function();


global ivar nvar figoffset

nreg=685;
showsites=0;

[d,f]=get_files;

load(['regionpath_' num2str(nreg)]);

%Europe
regs=find_region_numbers('emea');

% Chinese rice regions:
%latlim=[18,40]; lonlim=[95,120];

% Woeks regions:

latlim=[-60,60];lonlim=[-180,180];
regs=1:685

%  regs=find_region_numbers_686('emea');


if ~exist('region','var')
    region.path=regionpath;
end

region.path(:,:,1)=region.path(:,:,1)+0.5;
region.path(:,:,2)=region.path(:,:,2)+1.0;

figoffset=0;
vars={'Density'}
%vars={'Technology','Farming','Density'};
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
     end
    iarg=iarg+2;
     end
  end
  
if ~exist('lonlim','var') lonlim=[-15,42]; end
if ~exist('latlim','var') latlim=[27,55]; end
if ~exist('timelim','var') timelim=[4000,4000]; end;

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

toffset=500;

tstart=min([r.tend+toffset,timelim(1)]);
tend=max([r.tstart+toffset,timelim(2)]);
r.time=r.time+toffset;
         

for idovar=1:nvar
    
    ivar=dovar(idovar);
    
    if isstruct(vars) &  (  strcmp(vars{idovar},'Cropfraction') ... 
        | strcmp(vars{idovar},'Pasturefraction') ... 
        | strcmp(vars{idovar},'HydePopulationCount') ...
            | strcmp(vars{idovar},'HydePopulationDensity') )
        time=2000+[10000:-1000:1000];
    else
        time=r.time
    end
    
[tmax,itend]=min(abs(time-tend));
[tmin,itstart]=min(abs(time-tstart));
    
data=eval(['r.' r.variables{ivar}]);

    
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
  set(gca,'XDir','reverse');
  set(gca,'YLim',minmax);

  for ireg=1:length(regs)
    reg=regs(ireg);
    plot(r.time(itstart:itend),squeeze(data(reg,itstart:itend)),'k-','color',cmap(resvar(reg,itstart),:));
  end
  p1=plot(r.time(itstart:itend),squeeze(data(regs(1),itstart:itend)));
  set(p1,'Tag','timeseries','LineWidth',4);
 % title(sprint('%s (sum %f.1)',vars{ivar},sum(sum(data(regs,itend)))));
  hold off;
 
   
  % plot map
  figure(ivar+figoffset); 
  clf reset;
  set(ivar,'DoubleBuffer','on');    
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
  
  
  aviname=fullfile(fd,['variable_' strrep(r.variables{ivar},' ','')]);
  if length(infix)>0 aviname=[aviname '_' infix]; end
  aviname=[aviname '.avi'];
  mov=avifile(aviname);
 
  pathlen=sum(region.path(:,:,1)>-999,2);

  color_sea=0.7*ones(1,3);
  color_land=0.8*ones(1,3);
    
  clf;
  
  m_proj('equidistant','lon',lonlim,'lat',latlim);
  m_grid;%('backcolor',color_sea);
   %m_coast;
   hold on;
  pm=cl_plot_marble(lonlim,latlim);
  
  alpha(pm,1.0)
  
 % m_coast('patch',color_land);
  
  clf;
%  m_proj('mercator','lon',lonlim,'lat',latlim);
%  m_grid('backcolor',color_sea);
%    m_coast('patch',color_land);

  %set(gca,'Position',[0.06 0.0 0.85 1]);
  % Get rid of white lakes
  
  % only needed for empty (non-marble background)
  if (0)
  c=get(gca,'Children');
  ipatch=find(strcmp(get(c(:),'Type'),'patch'));
  npatch=length(ipatch);
  if npatch>0
    iwhite=find(sum(cell2mat(get(c(ipatch),'FaceColor')),2)==3);
    if ~isempty(iwhite) set(c(ipatch(iwhite)),'FaceColor',color_sea);
    end
  end
  end
   
   
  
  titletext=r.variables{ivar};
  if length(infix)>0 titletext=[titletext '(' infix ')']; end
  %ht=title(titletext); set(ht,'interpreter','none');
 
  
  t=time(itstart);
  
  %hbt=m_text(lonlim(1)+0.02*lonrange,latlim(2)-0.2*latrange,[num2str(t) ' BP'],'backgroundColor','y','EdgeColor','k');
       
  if exist('ylim','var') minmax=ylim; end
      set(gca,'Position',[0.05 0.0 0.83 1]);

 for ireg=1:length(regs)
      reg=regs(ireg);
      hp(ireg)=m_patch(region.path(reg,1:pathlen(reg),1),region.path(reg,1:pathlen(reg),2),'b');
      h=hp(ireg);
      if h==0 continue; end
      alpha(h,resvar(reg,itstart)./64/1.6);
      set(h,'ButtonDownFcn',@onclick,'UserData',squeeze(data(reg,itstart:itend)));
  end
     
   
      % the non-marble version
      if (0)
  for ireg=1:length(regs)
      reg=regs(ireg);
      hp(ireg)=m_patch(region.path(reg,1:pathlen(reg),1),region.path(reg,1:pathlen(reg),2),cmap(resvar(reg,itstart),:));
      h=hp(ireg);
      set(h,'ButtonDownFcn',@onclick,'UserData',squeeze(data(reg,itstart:itend)));
  end

     colormap(cmap); cb=colorbar;
  cbyt=str2num(get(cb,'YTickLabel'));
     cbyt=cbyt*(minmax(2)-minmax(1))+minmax(1);
     cbyt=scale_precision(cbyt,2);
     set(cb,'YTickLAbel',num2str(cbyt));
      end
     
  ntime=itend-itstart+1;

  for it=itstart:itend
      t=time(it);
    
    % set(hbt,'String',[num2str(t) ' BP']);
  
     itprior=max(it-1,itstart);
     ichanged=find(resvar(regs,it)~=resvar(regs,itprior));
     for ir=1:length(ichanged)
      ireg=ichanged(ir);
      reg=regs(ireg);
      if hp(ireg)==0 continue; end
      set(hp(ireg),'FaceColor',cmap(resvar(reg,it),:));
      %m_patch(region.path(reg,1:pathlen(reg),1),region.path(reg,1:pathlen(reg),2),cmap(resvar(reg,it),:));
     end
     
 
    if showsites 
     isite=find(sage>t & slat>latlim(1) & slat<latlim(2) & slon>lonlim(1) & slon<lonlim(2));
     if ~isempty(isite)
      m_line(slon(isite),slat(isite),'MarkerEdgeColor','k','MarkerFaceColor','y','LineStyle','none','Marker','o','MarkerSize',5.0);
     end
    end
    
    plotname=fullfile(fd,['variable_' strrep(r.variables{ivar},' ','') '_']);
    if length(infix)>0 plotname=[plotname infix '_']; end
    plotname=[plotname sprintf('%05d_%d',12000-t,t)];
   
    
    %if mod(it,4)==1
        %plot_multi_format(gcf,plotname);
    %end
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
