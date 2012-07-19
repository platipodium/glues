function clp_megalithtombs
% clp_megalithtombs()

cl_register_function;

sites=cl_read_megalithtombs;

fig=gcf;
ax=gca
if ~ishold(ax) clf reset; 
  m_proj('equidistant','lat',cl_minmax(sites.lat),'lon',cl_minmax(sites.lon));
  hold on;
  clp_naturalearth('lat',cl_minmax(sites.lat),'lon',cl_minmax(sites.lon),'fig',gcf,'file','../../data/naturalearth/HYP_HR_SR_W_DR');
  m_grid;
end

m_plot(sites.lon,sites.lat,'r^','MarkerSize',1);
hold off;
return;
end
