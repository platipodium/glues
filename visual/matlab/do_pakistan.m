function do_pakistan


clp_single_redfit('file','data/indus_varves_red.mat','lim',[-50,30],'freqlim',[1/5000 1/5],'xticks',30);
plot_multi_format(1,'../plots/indus_varves_red');

clp_single_redfit('file','data/indus_varves_red.mat','lim',[-50,30],'freqlim',[1/5000 1/30]);
plot_multi_format(1,'../plots/indus_varves_red_centennial');
clp_single_redfit('file','data/indus_varves_red.mat','lim',[-50,30],'freqlim',[1/30 1/5]);
plot_multi_format(1,'../plots/indus_varves_red_decadal');
 
return

%clp_nc_timeseries('file','../../src/test/plasim_11k.nc','latlim',[24,37],'lonlim',[67,76],'variable','lsp');
 

%return
v=clp_varves('timelim',[1901,2010]);
r=clp_cru_bycountry('timelim',[1901,2010]);

figure(5); clf reset;
v.year=flipud(v.year);
v.thick=flipud(v.thick);
plot(v.year,v.thick*100,'r-','Linewidth',4);

hold on;
plot(r.year,r.wetseason,'c-','LineWidth',1);
plot(r.year,movavg(r.year,r.wetseason,3),'b-','LineWidth',2);
legend('Varve thickness','Wet season rain','3-year running');

iyear=1:length(v.year);
[s,p]=corrcoef([v.thick(iyear),r.wetseason(iyear),r.annual(iyear)]);
[i,j]=find(p<0.05);

plot([1964:2010],repmat(60,47,1),'y-','LineWidth',10);
text(1980,60,'Dams','Color','k','FontSize',15);


title('Indus varve thickness and Pakistan rainfall');
plot_multi_format(5,'varves_and_rainfall');

return

% Plot SWAT valley data
variables='pre';
nosum=1;
file='data/cru_ts_3_00.1901.2006.pre.nc';
mult=0.1;
lim=[0 600];
clp_nc_timeseries('nosum',nosum,'mult',mult,'lim',lim,'latlim',[35,35.3],'lonlim',[71.7,71.8],'file',file,'variables',variables,'figoffset',0,'timestep',12,'timelim',[31*12+7,141*12+7]);
title('August precip 35.25N 71.75W from CRU TS3.0');
plot(datenum(now),217,'md','MarkerSize',20,'MarkerFaceColor','m');
plot_multi_format(3,'precipitation_dir');


figure(1);
clf reset;
m_proj('equidistant','lat',[23 38],'lon',[60 78]);
m_coast('patch',[1 .80 .7]);
m_elev('contourf',[250:250:8000]);
m_grid('box','fancy','tickdir','in');
colormap(flipud(bone));
m_gshhs('ib','color','red','linewidth',1.5,'linestyle',':'); % plot boundaries in high resolution
m_gshhs('hr'); % plot boundaries in high resolution
m_plot(71+52/60.+29.72/3600.,35+11/60.+51.58/3600.,'ro','MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',10); % Dir, PK
m_text(72.5,35+11/60.+51.58/3600.,'Dir','Color','r','FontSize',14);
m_plot(68+52/60.+1.57/3600,27+41/60.+19.03/3600.,'ro','MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',10); % Sukkur, PK
m_text(68,28.3,'Sukkur','Color','r','FontSize',14);

plot_multi_format(1,'map_of_pakistan')


% Plots CRU TS 3.0 timeseries of precipitation in various areas of Pakistan
variables='pre';
nosum=1;
file='data/cru_ts_3_00.1901.2006.pre.nc';
mult=0.1;
lim=[0 1000];
clp_nc_timeseries('nosum',nosum,'mult',mult,'lim',lim,'latlim',[33,37],'lonlim',[70,76],'file',file,'variables',variables,'figoffset',0);
title('Hindukush rainfall from CRU TS3.0');
plot_multi_format(gcf,'precipitation_hindukush');

clp_nc_timeseries('nosum',nosum,'mult',mult,'lim',lim,'latlim',[30,33],'lonlim',[70,77],'file',file,'variables',variables,'figoffset',1);
title('Punjab rainfall from CRU TS3.0');
plot_multi_format(gcf,'precipitation_punjab');

clp_nc_timeseries('nosum',nosum,'mult',mult,'lim',lim,'latlim',[24,30],'lonlim',[67,72],'file',file,'variables',variables,'figoffset',2);
title('Sindh rainfall from CRU TS3.0');
plot_multi_format(gcf,'precipitation_sindh');


clp_ncep_timeseries('latlim',[24,30],'lonlim',[67,72],'lim',[0 200]);
clp_ncep_timeseries('latlim',[30,33],'lonlim',[70,77],'lim',[0 200]);
clp_ncep_timeseries('latlim',[33,37],'lonlim',[70,76],'lim',[0 200]);

end