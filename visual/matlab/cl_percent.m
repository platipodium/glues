function cl_percent(ax,location)
% Corrects an axis tick labels to percent

cl_register_function;
if ~exist('ax','var') ax=gca; end
if ~exist('location','var') location='y'; end

for il=1:length(location)
  ts=[location(il) 'tick'];
  tsl=[ts 'label'];
  t =get(ax,ts);
  tl=get(ax,tsl);
  
  tl=num2str(scale_precision(100*t',4));
  set(ax,tsl,tl);
end

return;
end