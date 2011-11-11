function area=calc_gridcell_area(clat,dlon,dlat,radius)

cl_register_function();

if ~exist('radius','var') radius=6378.137; end
if ~exist('dlon','var') dlon=0.5; end
if ~exist('dlat','var') dlat=0.5; end

%area=2*pi*radius*radius*(abs(sind(clat+dlat/2.0)));
area=2*pi*radius*radius*(2*cosd(clat)*sind(dlat/2.0));
area=area.*dlon/360;

return;
end
