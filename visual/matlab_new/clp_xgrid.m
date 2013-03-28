function hdl=clp_xgrid(varargin)

offset=0;
if nargin<1 ax=gca; xticks=get(gca,'XTick');
else
  if ishandle(varargin{1}) 
      offset=offset+1;
      ax=varargin{1};
      if nargin>1 
        xticks=varargin{2}; 
        offset=offset+1;
      else xticks=get(gca,'XTick'); 
      end
  else ax=gca; xticks=varargin{1}
  end
end 
  
yl=get(ax,'Ylim');
n=length(xticks);
x=repmat(xticks,3,1);
x(3,:)=NaN;
x=reshape(x,n*3,1);
y=x;
y(1:3:n*3)=yl(1);
y(2:3:n*3)=yl(2);

hdl=plot(x,y,varargin{offset+1:end});
uistack(hdl,'bottom');
return
end