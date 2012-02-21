function handle=clp_pulse(lon,lat)
% handle=clp_pulse(lon,lat)

ms=10;
r=200:100:1000;

h(1)=m_plot(lon,lat,'ro','MarkerSize',ms);
set(h(1),'MarkerFaceColor','y','LineWidth',2);


h(2)=m_range_ring(lon,lat,r);
set(h(2),'Color','r');

if nargout>0 handle=h; end

return;
end