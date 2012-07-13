function handle=clp_pulse(lon,lat,varargin)
% handle=clp_pulse(lon,lat,varargin)

cl_register_function;

arguments = {...
  {'col','r'},...
  {'rings',100:60:500},...
  {'MarkerSize',15},...
};

[args,rargs]=clp_arguments(varargin,arguments);
for i=1:args.length   
  eval([ args.name{i} ' = ' clp_valuestring(args.value{i}) ';']); 
end

h=m_range_ring(lon,lat,rings);
set(h,'Color',col);
nh=length(h);

h(nh+1)=m_plot(lon,lat,'ro','MarkerSize',MarkerSize);
set(h(nh+1),'MarkerFaceColor','w','LineWidth',2,'MarkerEdgeColor',col);

if nargout>0 handle=h; end

return;
end