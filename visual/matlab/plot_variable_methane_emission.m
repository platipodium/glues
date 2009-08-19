function plot_variable_methane_emission(varargin)

nreg=685;
cl_register_function();


[d,f]=get_files;

load(['regionpath_' num2str(nreg)]);

% Chinese rice regions:
latlim=[18,40];
lonlim=[95,120];

% Wolr regions:
latlim=[-60,70]; lonlim=[-180,180];

if nreg==685 
  regs=find_region_numbers('lat',latlim,'lon',lonlim);
elseif nreg==686
  regs=find_region_numbers_686('lat',latlim,'lon',lonlim);
else nreg=1:nreg;
end

%nregs=find_region_numbers('emea');

figoffset=0;
vars={'Methane emission'};
%vars={'Migration','Agricultures','CivStart','Climate'};
%vars={'Agricultures','Migration'};
mode='absolute';
resultfilename='result_plasim_nppl';
resultfilename='result';

  for iarg=1:nargin 
    if all(isletter(varargin{iarg}))
    switch lower(varargin{iarg}(1:3))
      case 'reg' 
        regs=varargin{iarg+1};
      case 'tim'
        timelim=varargin{iarg+1};
        case 'fig'
            figoffset=varargin{iarg+1};
        case 'mod'
            mode=vararbin{iarg+1};
        case 'res'
             resultfilename=varargin{iarg+1};
    end
    iarg=iarg+2;
     end
  end

  
if exist([resultfilename '.mat'],'file') load(resultfilename); else return; end

infix=strrep(resultfilename,'result','');
if length(infix)>0
  while infix(1)=='_' infix=infix(2:end); end
end

 
dovar=vars;
nvar=length(dovar);

toffset=500;

if ~exist('timelim','var') timelim=[10000,3000]; end;
tstart=min([r.tend+toffset,timelim(1)]);
tend=max([r.tstart+toffset,timelim(2)]);
r.time=r.time+toffset;

[tmax,itend]=min(abs(r.time-tend));
[tmin,itstart]=min(abs(r.time-tstart));

ntime=size(r.Density,2);

%data=methane_emission(r.Density.*r.Farming.*repmat(region.area',1,ntime));
people=r.Density.*repmat(region.area',1,ntime);
farmers=people.*r.Farming;
data=methane_emission(farmers)/1E4;
ntime=itend-itstart+1;

  switch mode
      case 'absolute', ;
      otherwise ;
  end 
  
  
   fd=fullfile(d.plot,'variable');
  if  ~exist(fd,'file')
      mkdir(fd);
  end
  
  fd=fullfile(fd,'methane_emission');
   if  ~exist(fd,'file')
      mkdir(fd);
  end
  
  aviname=fullfile(fd,['variable_methane_emission']);
  if length(infix)>0 aviname=[aviname '_' infix]; end
  aviname=[aviname '.avi'];

  %minmax=[min(min(min(data))),max(max(max(data)))];
  minmax=[min(min(min(data(regs,:)))),max(max(max(data(regs,:))))];
  minmax(2)=30;
  
 figure(1);
  clf reset;
   set(gcf,'PaperOrientation','landscape');
  set(gcf,'PaperType','A4');
 titletext='Regional methane emissions';
    if length(infix)>0 titletext=[titletext '(' infix ')']; end
   tt=title(titletext);
   set(tt,'Interpreter','none');
   
   set(gca,'position',[0.1300    0.1100    0.7750    0.7150]);
   hold on;
 
  for ireg=1:length(regs)
      reg=regs(ireg);
      p(ireg)=plot(r.time(itstart:itend),data(reg,itstart:itend),'k-','Color',[0.2 0.2 0.2]+ireg/length(regs)*0.6);
  end
  
  [mdat,mreg]=max(data(regs,itstart+40));
  set(p(mreg),'Color',[0.8 0.8 0.2],'Linewidth',4);
  
  timesum=sum(data(regs,itstart:itend));
  timeaverage=mean(data(regs,itstart:itend));
  
  plot(r.time(itstart:itend),timeaverage,'k:','LineWidth',4);
  %plot(r.time(itstart:itend),timesum,'r-','LineWidth',4);
  
  %plot(r.time(itstart:itend),repmat(20,1,ntime),'m-','LineWidth',3);
  %plot(r.time(itstart:itend),repmat(500,1,ntime),'m--','LineWidth',3);
  
  
  set(gca,'XDir','reverse');%,'YScale','log');
  ylabel('Annual CH_4 emission (1000 t)');
  Xlabel('Time before present (a)');
      plotname=fullfile(fd,['variable_methane_emission_timeline']);
    if length(infix)>0 plotname=[plotname '_' infix]; end
  
  %plot_multi_format(gcf,plotname);
  
  figure(2); 
  clf reset;
  set(gcf,'DoubleBuffer','on');    
  set(gcf,'PaperOrientation','landscape');
  set(gcf,'PaperType','A4');
  %set(ivar,'Position',[442   188  607  442]);
  
  
  cmap=colormap('hotcold');
  resvar=round(((data-minmax(1)))./(minmax(2)-minmax(1))*(length(cmap)-1))+1;
  %if (abs(tend-tstart)>10*r.tstep) 
      mov=avifile(aviname); %end;
 
  pathlen=sum(region.path(:,:,1)>-999,2);

  for it=itstart:itend
      t=r.time(it);
   clf;
    m_proj('mercator','lon',[lonlim(1)-5,lonlim(2)+5],'lat',[latlim(1)-5,latlim(2)+5]);
    m_grid; 
    set(gca,'Color',[0.7 0.7 0.7]);
        
    for ireg=1:length(regs)
      reg=regs(ireg);
      icol=min([64,resvar(reg,it)]);
      m_patch(region.path(reg,1:pathlen(reg),1),region.path(reg,1:pathlen(reg),2),cmap(icol,:));
    end
    
    titletext='Methane emission (1000 t/a)';
    if length(infix)>0 titletext=[titletext '(' infix ')']; end
    tt=title(titletext);
    set(tt,'Interpreter','none');
 
    hdl_t=m_patch([lonlim(1)+1,lonlim(1)+7,lonlim(1)+7,lonlim(1)+1],[latlim(2)-3,latlim(2)-3,latlim(2)-1,latlim(2)-1],'y');
    m_text(lonlim(1)+1.5,latlim(2)-2,[num2str(t) ' BP']);
  
    colormap(cmap); cb=colorbar;
    cbyt=str2num(get(cb,'YTickLabel'));
    cbyt=cbyt*(minmax(2)-minmax(1))+minmax(1);
    cbyt=scale_precision(cbyt,2);
    set(cb,'YTickLAbel',num2str(cbyt));
    %set(cb,'Title','[t/a]');
    %set(gca,'Position',[0.05 0.0 0.83 1]);
    
    plotname=fullfile(fd,['variable_methane_emission_']);
    if length(infix)>0 plotname=[plotname infix '_']; end
    plotname=[plotname sprintf('%05d_%d',12000-t,t)];
   
    
    if mod(it,5)==1 plot_multi_format(gcf,plotname); end
    f=getframe(gcf);
     %if (abs(tend-tstart)>10*r.tstep) mov=addframe(mov,f); end;
     mov=addframe(mov,f);
    fprintf('.');
    if mod(it,80)==0 fprintf('\n'); end
    it=it+1;
  end
  %if (tend-tstart>10*r.tstep) 
  mov=close(mov); 
  %end;
  

return
