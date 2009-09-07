function retdata=cl_plot_distance_timing(varargin)

cl_register_function();

[d,f]=get_files;
retdata=NaN;

% Choose 'emea' or 'China' or 'World'
[regs,nreg,lonlim,latlim]=find_region_numbers('EMEA','lon',[0,36]);

regs=regs(find(regs<300 & regs>120 & regs~=204));



figoffset=0;

vars={'Farming'}

mode='absolute';
resultfilename='results';

  for iarg=1:nargin 
    if all(isletter(varargin{iarg}))
    switch lower(varargin{iarg}(1:3))
      case 'var'
        vars=varargin{iarg+1};

        case 'mod'
            mode=vararbin{iarg+1};
        case 'res'
             resultfilename=varargin{iarg+1};
        case 'sce'
            scenario=varargin{iarg+1};
     end
    iarg=iarg+2;
     end
  end
  
  
if ~exist('timelim','var') timelim=[11000,3100]; end;
if ~exist('timeunit','var') timeunit='BP'; end;
if exist('scenario','var')
    resultfilename=[resultfilename '_' scenario];
end


load(['regionpath_' num2str(685)]);
if ~exist('region','var')
    region.path=regionpath;
end



if exist([resultfilename '.mat'],'file') load(resultfilename); else 
    fprintf('Cannot find file %s\n',resultfilename);
    error('No result file read')
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
   
  
  resvar=round(((data-minmax(1)))./(minmax(2)-minmax(1)));
  

  refreg=272;
  irefreg=find(regs==refreg);
  thresh=0.3;
  for ireg=1:length(regs)
      ftime=find(data(regs(ireg),:)>=thresh);
      if isempty(ftime) threshtime(ireg)=NaN; 
      else threshtime(ireg)=time(ftime(1)); end
      
      dist(ireg)=m_lldist([regioncenter(refreg,2),regioncenter(regs(ireg),2)],...
      [regioncenter(refreg,1),regioncenter(regs(ireg),1)]);
      
  
  end
  
  % Plot timeseries
  figure(ivar+nvar+figoffset); 
  clf reset;
   
  hold on;
  
  y=regioncenter(regs,2); % longitude
  y=dist; % distances to refreg
  x=threshtime;
  
  plot(x,y,'r.');
  
  text(x,y,num2str(regs));
  y0=threshtime(irefreg);
  plot(y0:500:y0+4000,0:500:4000,'b-');
  
  
end
return;
end