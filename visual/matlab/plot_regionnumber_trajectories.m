function plot_regionnumber_trajectories(varargin)

cl_register_function();

load('regionpath');

regs=[164,243,171,123];
var=[1:3];

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
    end
    iarg=iarg+2;
  end
end

if ~exist('result.mat','file') read_result; end
load('result');

time=12000-[tstart:tstep:tend];
clf reset;

cmap=colormap(cprism);


n=length(regs);
nvar=length(var); 
names=name_regionnumber(regs);

for ivar=1:nvar
  gca=axes('Position',[0.05 0.05+(0.95/nvar)*(ivar-1) 0.9 0.9*1./nvar],'XDir','reverse');

 % if strcmp(vars{ivar},'Density') | strcmp(vars{ivar},'Migration')
 %   set(gca,'YScale','log'); 
 % end
  
  ymax=max(max(max(result(regs,var(ivar),:))));
  ymin=min(min(min(result(regs,var(ivar),:))));
  yran=(ymax-ymin);
  set(gca,'YLim',[ymin-0.1*yran ymax+0.1*yran]);
  
  xmin=5000;
  xmax=10000;
  xran=xmax-xmin;
  set(gca,'XLim',[xmin,xmax]);
  hold on;
  
  for ireg=1:n
    hdl_p=plot(time,squeeze(result(regs(ireg),var(ivar),:)),'color',cmap(ireg,:),'LineWidth',2.5);
  end
  text(xmax-0.01*xran,ymin+0.9*yran,vars{ivar},'FontSize',17);
  
  if ivar==1 
    for ireg=1:n
      text(xmax-0.05*xran,ymin+0.9*yran-0.15*yran*ireg,[names{ireg} ' (' num2str(regs(ireg)) ')'],'color',cmap(ireg,:));
    end
  else
    set(gca,'XTickLabel',[])
  end
  
  
end

return
