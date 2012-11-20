function phdl=cl_patchbar(xdata,ydata,xwidth)
% phdl=cl_patchbar(xdata,ydata,xwidth)

% Check x dimensions and transpose if necessary
sx=size(xdata);
nx=length(xdata);
if nx==sx(2)
  xdata=xdata';
  ydata=ydata';
end

xdiff=abs(xdata(2:end)-xdata(1:end-1));
xmin=min(xdiff);

if ~exist('xwidth','var') xwidth=xmin*0.9; end
if length(xwidth)>1
  wdim=find(length(xwidth)==nx);
  if isempty(wdim)
    error('x and width dimensions mismatch');
  end
else
  xwidth=repmat(xwidth,size(xdata));
end

phdl=zeros(size(ydata));
lhdl=phdl;
cmap=gray(size(ydata,2));
if ~ishold hold on; end

for i=1:nx
  xi=xdata(i)+0.5*[-1 1]*xwidth(i);
  for j=1:size(ydata,2)
    if ydata(i,j)==0 continue; end
    if j<2 yi=[0 ydata(i,1)];
    else yi=[sum(ydata(i,1:j-1)) sum(ydata(i,1:j))];
    end
    xline=[xi(1) xi(1) xi(2) xi(2) xi(1)];
    yline=[yi(1) yi(2) yi(2) yi(1) yi(1)];
    phdl(i,j)=patch(xline,yline,'k','facecolor',cmap(j,:),'edgecolor','k');
  end
end
  

end