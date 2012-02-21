function handle=clp_pulse(lon,lat)
% handle=clp_pulse(lon,lat)

ms=15;
r=100:60:500;

h=m_range_ring(lon,lat,r);
set(h,'Color','r');
nh=length(h);

h(nh+1)=m_plot(lon,lat,'ro','MarkerSize',ms);
set(h(nh+1),'MarkerFaceColor','y','LineWidth',2);

if nargout>0 handle=h; end

return;
end