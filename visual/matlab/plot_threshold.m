function plot_threshold(varargin)

cl_register_function();

load('regionpath');

regs=find_region_numbers('emea');
thresh=[2.5,3.0,0.1,1];

if nargin==1
  if all(isletter(varargin{1})) var=varargin{1};
  else regs=varargin{1};
  end
elseif nargin>1
  for iarg=1:nargin 
    switch lower(varargin{iarg}(1:3))
      case 'reg' 
        regs=varargin{iarg+1};
      case 'var'
        var=varargin{iarg+1};
      case 'thr'
        thresh=varargin{iarg+1};
    end
    iarg=iarg+2;
  end
end

if ~exist('result.mat','file') read_result; end
load('result');

time=12000-[tstart:tstep:tend];

nvar=4; %TODO
for ivar=3
  figure(ivar); 
  clf reset;
  cmap=colormap('jet');
  above=(squeeze(result(regs,ivar,:))>=thresh(ivar));
  for i=1:length(regs)  
    f=find(above(i,:));
    if ~isempty(f) threshtime(i)=tstart+min(f)*tstep;
    else threshtime(i)=tend;
    end
  end
 
  %threshtime(find(threshtime>tend-2000))=tend-2000; 
  threshtime=min([threshtime;ones(1,length(threshtime))*(tend-2000+toffset)]);
  
  threshtime=tend-threshtime+toffset;
  threshmin=min(threshtime);
  threshmax=tend-2000+toffset;%max(threshtime);
  if threshmax<=threshmin continue; end
  
  ctime=64-round((threshtime-threshmin)./(threshmax-threshmin)*(length(cmap)-1));
  xtickgap=round((threshmax-threshmin)/10);
  xtickvalues=[threshmax:-xtickgap:threshmin];
  
  pathlen=sum(regionpath(regs,:,1)>-999,2);

  m_proj('mercator','lon',[-15,42],'lat',[27,55]);
  m_grid; 
  title(vars{ivar});
  m_patch([-14,-3,-3,-14],[44,44,46,46],'y');
  m_text(-13.5,45,['Threshold ' num2str(thresh(ivar))]);
    
  for ireg=1:length(regs)
    reg=regs(ireg);
    m_patch(regionpath(regs(ireg),1:pathlen(ireg),1),regionpath(regs(ireg),1:pathlen(ireg),2),cmap(ctime(ireg),:));
  end
  
  hc=colorbar('horiz');
  set(hc,'Xticklabel',xtickvalues);
  set(hc,'Position',[0.1300    0.110    0.7750    0.0611]);
  set(hc,'XAxisLocation','bottom');  
  plot_multi_format(gcf,['../plots/threshold_' vars{ivar} '_' num2str(thresh(ivar)) ]);
  
end

return
