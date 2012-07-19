function [lonlim, latlim]=cl_geographic_limits(varargin)

cl_register_function;

arguments = {...
  {'countries','China'},...
};

[args,rargs]=clp_arguments(varargin,arguments);
for i=1:args.length   
  eval([ args.name{i} ' = ' clp_valuestring(args.value{i}) ';']); 
end

if ~iscell(countries) countries={countries}; end
n=length(countries);

load('../../data/naturalearth/10m_admin_0_countries.mat');
indices=zeros(n,1);

for j=1:n
  for i=1:length(shape)
    if strmatch(shape(i).SOVEREIGNT,countries{j}) indices(j)=i; break; end
  end
  plat=shape(indices(j)).Y;
  plon=shape(indices(j)).X;
  if j==1
    latlim=[min(plat) max(plat)];
    lonlim=[min(plon) max(plon)];
  else
    latlim=[ min([min(plat),latlim])  max([max(plat),latlim])];
    lonlim=[ min([min(plon),lonlim])  max([max(plon),lonlim])];
  end
end

return
end
