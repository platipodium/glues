function [p,lonlim,latlim]=clp_relief(varargin)

cl_register_function;

% typically called after clp_basemap
% Default values
latlim=[-60 70];
lonlim=[-180 180];

% todo: if no figure exists, create one with a call to clp_basemap

m_gshhs('lc');

return
end