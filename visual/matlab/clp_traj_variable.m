function rdata=clp_traj_variable(varargin)

%% Process argument list and register function
arguments = {...
  {'timelim',[12000,3000]},...
  {'reg','all'},...
  {'vars','Density'},...
  {'scale','absolute'},...
  {'figoffset',0},...
  {'zlim',},...
  {'timeunit','BP'},...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

%% Read in data from standard paths

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


if exist([resultfilename '.mat'],'file') load(resultfilename); else 
    fprintf('Cannot find file %s\n',resultfilename);
    error('No result file read')
    return; 
end

infix=strrep(resultfilename,'results','');
if length(infix)>0
  while infix(1)=='_' infix=infix(2:end); end
end

%% Process all variables
% TODO: make this a generic subroutine, see more examples in
% clp_map_variable.m

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

%% Process time coordinate
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

ntime=length(time);


%% Preallocate retdata and loop over variables
retdata=zeros(nvar,itend-itstart+1,length(regs))+NaN;

for idovar=1:nvar
    
  ivar=dovar(idovar);
  data=eval(['r.' r.variables{ivar}]);
  retdata(idovar,:,:)=data(squeeze(regs),itstart:itend)';
      
  minmax=[min(min(min(data(regs,itstart:itend)))),max(max(max(data(regs,itstart:itend))))];
  %if exist('zlim','var') minmax=zlim; end
   
  cmap=colormap('hotcold');
  
  resvar=round(((data-minmax(1)))./(minmax(2)-minmax(1))*(length(cmap)-1))+1;
  resvar(resvar>length(cmap))=length(cmap);
  
  % Plot timeseries
  figure(ivar+figoffset); 
  set(ivar,'DoubleBuffer','on');    
  set(ivar,'PaperType','A4');
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
  if ~exist(fd,'file') mkdir(fd); end
  
  fd=fullfile(fd,strrep(r.variables{ivar},' ',''));
  if ~exist(fd,'file') mkdir(fd); end
  
  pathlen=sum(region.path(:,:,1)>-999,2);

  titletext=r.variables{ivar};
  if length(infix)>0 titletext=[titletext '(' infix ')']; end
  ht=title(titletext,'interpreter','none');
   
  if exist('ylim','var') minmax=ylim; end

  if ~exist('regioncenter','var') regioncenter=region.center; end 
 

  plotname=fullfile(fd,['traj_variable_' strrep(r.variables{ivar},' ','') '_']);
  if length(infix)>0 plotname=[plotname infix '_']; end
  plot_multi_format(gcf,plotname);

end

if nargout>0 
  rdata=retdata;
end

return;
end

