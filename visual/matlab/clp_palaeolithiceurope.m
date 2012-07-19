function clp_palaeolithiceurope
% clp_palaeolithiceurope()

cl_register_function;

sites=cl_read_palaeolithiceurope;

fig=gcf;
ax=gca;

lat=sites.latitude;
lon=sites.longitude;
lonlim=[-10 45];
latlim=[30 62];
valid=find(isfinite(lat) & isfinite(lon) & lon>=lonlim(1) & lon<=lonlim(2) & lat>=latlim(1) & lat<=latlim(2));
lat=lat(valid);
lon=lon(valid);
lonlim=cl_minmax(lon);
latlim=cl_minmax(lat);
age=sites.age(valid);

if ~ishold(ax) clf reset; 
  m_proj('equidistant','lat',latlim,'lon',lonlim);
  hold on;
  clp_naturalearth('lat',latlim,'lon',lonlim,'fig',gcf,'file','../../data/naturalearth/HYP_HR_SR_W_DR');
  m_grid;
end

agelim=[1E6 200000 100000 50000 30000 20000 15000 12000 10000 9000 8000 7000 6000 5000 4000 3000 2000 100];
n=length(agelim);
cmap=jet(n);
for i=2:n
  j=find(age>=agelim(i) & age<agelim(i-1));
  if isempty(j) continue; end;
  p(i)=m_plot(lon(j),lat(j),'r^','Markersize',2,'color',cmap(i,:));
  agelim(i)
end
hold off;
return;
end
