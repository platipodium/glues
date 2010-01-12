function clp_basemap(varargin)

cl_register_function;

% Default values
latlim=[-60 70];
lonlim=[-180 180];

% todo: parse arguments


% todo: adjust default home search for m_map
if (exist('m_proj')~=2)
  addpath('/Users/lemmen/matlab/m_map')
end

try
  m_proj('equidistant','lat',latlim,'lon',lonlim);
catch exception
  error('M_MAP package not found (either not in search path or not downloaded at all');
end

% Create new figure
figure(gcf);
clf reset;

set(gcf,'userdata',cl_cl_get_version);

m_grid;%('backcolor',color_sea);
m_coast;
% m_coast('patch',color_land);

hold on;

end
