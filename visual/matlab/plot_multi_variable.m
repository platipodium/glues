function plot_multi_variable(varargin)

cl_register_function();

load('regionpath');

regs=find_region_numbers('emea');

if nargin==1
  if all(isletter(varargin{1})) var=varargin{1};
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

if ~exist('result.mat','file') read_result; end
load('result');

figure(1); 
clf reset;
set(gcf,'DoubleBuffer','on');    
%set(gca,'NextPlot','replace','Visible','off');  
it=1;
ivar=[1,2,4];
cmap=colormap('jet');
resvar=[];
for i=1:3
  minmax=[min(min(min(result(:,ivar(i),:)))),max(max(max(result(:,ivar(i),:))))];
  resvar(:,i,:)=(round(((squeeze(result(regs,ivar(i),:))-minmax(1)))./(minmax(2)-minmax(1))*(length(cmap)-1))+1)/length(cmap);
end
resvar=1-resvar;
mov=avifile(['multi_variable_TechnologyAgriculturesDensity.avi']);
it=1;
m_proj('mercator','lon',[-15,42],'lat',[27,55]);
m_grid; 
pathlen=sum(regionpath(regs,:,1)>-999,2);

for t=tstart:tstep:min(tend,9000)
  clf;
  m_proj('mercator','lon',[-15,42],'lat',[27,55]);
  m_grid; 
  title('Technology/Agricultures/Density');
  hdl_t=m_patch([-12,-4,-4,-12],[44,44,46,46],'y');
  m_text(-11,45,[num2str(round(12000-t)) ' BP'])
  %if it>1 icreg=find(resvar(regs,:,it)~=resvar(regs,:,it-1));
  %else icreg=[1:length(regs)];
  % end
  
%  for ireg=1:length(icreg)
  for ireg=1:length(regs)
    m_patch(regionpath(regs(ireg),1:pathlen(ireg),1),regionpath(regs(ireg),1:pathlen(ireg),2),resvar(ireg,:,it));
  end
  %    disp(resvar(216,it));
  
  f=getframe(gca);
  mov=addframe(mov,f);
  fprintf('.');
  if mod(it,80)==0 fprintf('\n'); end
  it=it+1;
end
mov=close(mov);

return
