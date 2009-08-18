function plot_migration_sum(varargin)

cl_register_function();

[d,f]=get_files;

load('regionpath');

regs=find_region_numbers('emea');

if (nargin==1)
  if all(isletter(varargin{1})) 
      var=varargin{1};
  else regs=varargin{1};
  end
elseif nargin>1
  for iarg=1:nargin 
    switch lower(varargin{iarg}(1:3))
      case 'reg' 
        regs=varargin{iarg+1};
    end
    iarg=iarg+2;
  end
end

if exist('result.mat','file') 
    load('result');
else
    fprintf('Please create result.mat first with read_result.m\n');
    return;
end

time=r.time+500;

n=length(regs);

figure;
clf reset;
cmap=colormap('rainbow');

ivar=strmatch('Migration',r.variables)


rg=load('../../examples/setup/686/region_geography.tsv');
area=repmat(rg(regs,4),1,288);


migration=abs(squeeze(r.Migration(regs,:)));
density=squeeze(r.Density(regs,:));

above=migration.*area/1E3;

total=max(above,[],2);
total=sum(above,2);
total=log10(total);

totalmax=max(total);
totalmin=min(total);
       
csum=round(((max([total-totalmin,zeros(n,1)],[],2))/(totalmax-totalmin)*63))+1;

pathlen=sum(regionpath(regs,:,1)>-999,2);

  m_proj('mercator','lon',[-15,42],'lat',[27,55]);
  m_grid; 
  title('Migration activity (log10 Ind)');
    
  for ireg=1:length(regs)
    reg=regs(ireg);
    m_patch(regionpath(regs(ireg),1:pathlen(ireg),1),regionpath(regs(ireg),1:pathlen(ireg),2),cmap(csum(ireg),:));
  end
  
%  xtickvalues=['low' ' ' 'moderate' ' ' ' ' 'high ' ' ' ' ' ' ' 'very high'];
  xtickvalues={'low','','','','moderate','','','high','','','very high'};
  hc=colorbar;
  yt=get(hc,'Ytick');
  ytl=str2num(get(hc,'YTicklabel'))*(totalmax-totalmin)+totalmin;
  ytl=scale_precision(ytl,1);
  
  set(hc,'Yticklabel',num2str(ytl));
  %set(hc,'Position',[0.1300    0.1500    0.7750    0.0611]);
  hold off;
  plot_multi_format(gcf,fullfile(d.plot,'migration_sum'));
 
return
