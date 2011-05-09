function cl_fixticklabel(ax,location)
% removes tick labels which extend over the x/y limits
% location is one or more of 'tblr' top bottom left right

cl_register_function;
if ~exist('ax','var') ax=gca; end
if ~exist('location','var') location='tblr'; end

if numel(ax)>1
  warning('You can only use one axis at a time');
  return;
end

xt=get(ax,'XTick');
xtl=get(ax,'XTickLabel');
xtlim=get(ax,'XLim');

yt=get(ax,'YTick');
ytl=get(ax,'YTickLabel');
ytlim=get(ax,'YLim');

if any(location=='r') && xt(end)==xtlim(end) xtl(end,:)=' '; end
if any(location=='l') && xt(1)==xtlim(1) xtl(1,:)=' '; end
if any(location=='t') && yt(end)==ytlim(end) ytl(end,:)=' '; end
if any(location=='b') && yt(1)==ytlim(1) ytl(1,:)=' '; end;

set(ax,'XTickLabel',xtl);
set(ax,'YTickLabel',ytl); 
    
return;

end