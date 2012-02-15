function esd=cl_esd(lon,lat)

cl_register_function;

if nargin<2 error('At least two arguments are required'); end

if numel(lon)<2 error('At least two longitudes are required'); end
if numel(lat)<2 error('At least two latitudes are required'); end

mlon=mean(lon);
mlat=mean(lat);
dx=m_lldist([max(lon),min(lon)],[mlat mlat]);
dy=m_lldist([mlon,mlon],[max(lat) min(lat)]);

d=sqrt(dx*dx+dy*dy);
if nargout>0
  esd=d;
end

return
end