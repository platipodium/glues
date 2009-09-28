function [lonc,latc]=clm_polygon(lon,lat,n,dist)
% [LONOUT,LATOUT]=CLM_POLYGON(LON,LAT,N,DISTANCE)
%
% Creates a closed n-polygon with external radius (in plot points)
%   default N=6
%   default DISTANCE=0.1
%
% TODO: give distance in km

cl_register_function();

lonc=NaN;
latc=NaN;

[x,y]=m_xy2ll(lon,lat);
[xc,yc]=cl_polygon(x,y,n,dist);
[lonc,latc]=m_ll2xy(xc,yc);

return;
end