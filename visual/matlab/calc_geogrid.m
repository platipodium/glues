function [latgrid,longrid]=calc_geogrid(nlat,nlon)
% [latgrid,longrid]=CALC_GEOGRID(nlat,nlon)
%
% default nlat=360
% default nlon=720

cl_register_function();

% Default: establish half-degree grid
if ~exist('nlat','var') nlat=360; end;
if ~exist('nlon','var') nlon=720; end;

if nlat<1 | nlon<1
    error('Both number of latitudes and longitudes must be greater than 1');
end

latstep=180/nlat;
lonstep=360/nlon;
lonmin=-180+lonstep/2;
lonmax=180-lonstep/2;
latmin=-90+latstep/2;
latmax=90-latstep/2;
latgrid=[latmin:latstep:latmax];
longrid=[lonmin:lonstep:lonmax];

return;
end
