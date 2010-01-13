function [lonlimit,latlimit]=clp_basemap(varargin)
% CLP_BASEMAP plots a basic map with coast line
% 
% [lo,la]=CLP_BASEMAP returns the longitude and latitude limits

cl_register_function;

arguments = {...
  {'latlim',[-60 70]},...
  {'nocoast',0},...
  {'lonlim',[-180 180]},...
  {'projection','equidistant'}...
};

[args,rargs]=clp_arguments(varargin,arguments);
for i=1:args.length   
  eval([ args.name{i} ' = ' clp_valuestring(args.value{i}) ';']); 
end

if (exist('m_proj')~=2)
  addpath(fullfile(getenv('HOME'),'matlab/m_map'));
end

try
  m_proj('equidistant','lat',latlim,'lon',lonlim);
catch exception
  error('M_MAP package not found (either not in search path or not downloaded at all');
end

% Create new figure
figure(gcf);
if ~ishold(gcf) clf reset; end

set(gcf,'userdata',cl_get_version);

m_grid;%('backcolor',color_sea);
if ~nocoast
    m_coast;
  % m_coast('patch',color_land);
end

hold on;

if nargout>0
  lonlimit=lonlim;
  latlimit=latlim;
end

end