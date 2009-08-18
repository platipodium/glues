function plot_region_continents

cl_register_function();

load regionpath;

lat=regioncenter(:,1);
lon=regioncenter(:,2);
cont=zeros(size(lat));
n=length(cont);

% Continents from glues::GeographicalRegion.cc
cont(:)=7;

cont(find(lat > 18.8   & (lon > -15 | lon<=-170))) = 1;
cont(find((lat > 18.8 & lat < 60) & (lon > -30 & lon<=60))) = 1;
cont(find(lat > 0    & lon >  45)) = 1;
cont(find((lat > -10 & lat < 60) & (lon > 60 & lon<=120))) = 1;

cont(find(lat <=18.8 & (lon > -30 & lon < 60))) = 4; % Africa
cont(find(lat < 15   & lon < -30)) = 2; % South America
cont(find(lat > 15   & (lon < -30 & lon > -170) )) = 3;
cont(find(lat < 10   & lon > 110 & lon < 180)) = 5; % Oceania 
cont(find(lat > 60   & lon < -15 & lon > -80)) = 6; % Greenland

figure(1);clf reset;
m_proj('Miller','lat',[-60 85]);
m_grid;

color='rgbcymk';

prism;
for i=1:n
  %if cont(i)~=7 continue; end;
  valid=find(isfinite(regionpath(i,:,1)));
  mp=m_patch(regionpath(i,valid,1),regionpath(i,valid,2),color(cont(i)));
  set(mp,'Linestyle','none');
end
%m_coast;

title('Glues continents')

for i=1:7
  m_line(-170,30-i*10,'Marker','s','Color',color(i),'MarkerSize',10,'MarkerFacecolor',color(i));
  m_text(-160,30-i*10,num2str(i),'HorizontalAlignment','left','VerticalAlignment','middle');
end
  

plot_multi_format(1,'../plots/region_continents');
end
