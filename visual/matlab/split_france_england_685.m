function split_france_england_686

cl_register_function();

regionmapfile='regionmap_685.mat';
load(regionmapfile);

nreg=region.nreg;
ncol=map.ncol;
latgrid=map.latgrid;
longrid=map.longrid;

figure(1);
clf reset;

freg=159;

iselect=find(land.region == freg);
nselect=length(iselect);
if nselect<1 error('Region with zero grid cells'); end
[ilon,ilat]=regidx2geoidx(land.map(iselect),ncol);

m_proj('miller','lat',[min(latgrid(ilat))-1,max(latgrid(ilat))+1],'lon',[min(longrid(ilon))-1,max(longrid(ilon))+1]);
m_coast;
m_grid;
hold on;

m_line(map.longrid(ilon),map.latgrid(ilat),'color','k','Linestyle','none','marker','.');
m_line(land.lon(iselect),land.lat(iselect),'color','r','Linestyle','none','marker','o');

ilalo=find(map.region==freg);
[ilon,ilat]=regidx2geoidx(ilalo,ncol);
m_line(map.longrid(ilon),map.latgrid(ilat),'color','b','Linestyle','none','marker','d');



lo=map.longrid(ilon);
m_plot(lo,0.65*lo+50,'g-');
    
ieng=find(land.lat(iselect)>0.65*land.lon(iselect)+50);
ifra=find(land.lat(iselect)<0.65*land.lon(iselect)+50);
iseng=iselect(ieng);
isfra=iselect(ifra);

land.region(iseng)=686;

region.nreg=686;
region.length(686)=length(ieng);
region.length(freg)=length(ifra);
region.land(686,1:region.length(686))=land.map(iseng);
region.land(freg,1:region.length(freg))=land.map(isfra);
region.lat(686)=calc_geo_mean(land.lat(iseng),land.lat(iseng));
region.lat(freg)=calc_geo_mean(land.lat(isfra),land.lat(isfra));
region.lon(686)=mean(land.lon(iseng));
region.lon(freg)=mean(land.lon(isfra));
region.center(freg,:)=[region.lon(freg),region.lat(freg)];
region.center(686,:)=[region.lon(686),region.lat(686)];
region.id(686)=686;

map.region(land.map(iseng))=686;

%ifra==region.land(159,1:region.length(159))==land.map(iselect)
m_line(land.lon(isfra),land.lat(isfra),'color','g','Linestyle','none','marker','o');
m_line(land.lon(iseng),land.lat(iseng),'color','m','Linestyle','none','marker','o');


save('-v6','regionmap_686.mat','region','map','land');
    
return
end
