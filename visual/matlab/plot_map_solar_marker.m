function sun=plot_map_solar_marker(lon,lat,val,msize)

cl_register_function();

if ~exist('msize','var') msize=15.0; end
if ~exist('val','var') val=0; end;
if ~exist('lat','var') lat=45; end;
if ~exist('lon','var') lon=-30; end;

colors=['bkr'];

sun=m_plot(lon,lat,'Color','y','MarkerSize',msize,'Marker','hexagram','MarkerFaceColor','y');
%val=m_plot(lon,lat,'Color',colors(val+2),'MarkerSize',msize/2.5,'Marker','o','LineWidth',msize/8.0);

return
