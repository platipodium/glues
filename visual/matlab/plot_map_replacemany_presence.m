function plot_map_replacemany_presence(fignum,fmin,fmax,year,ratio,period);

cl_register_function();

if ~exist('m_proj') addpath('/h/lemmen/matlab/m_map'); end;

binary=1;

if ~exist('period','var') period='low'; end
if ~exist('year','var') year=5.5; end
if ~exist('ratio','var') ratio=33; end
if ~exist('fignum','var') fignum=3; end
if ~exist('fmin','var') fmin=200; end
if ~exist('fmax','var') fmax=1800; end
if ~exist('dyear','var') dyear=0.5; end
if ~exist('extra','var') extra='eleven'; end

yrtext=sprintf('_%.1f_%.1f',year,dyear);
if exist('extra','var') yrtext=[yrtext '_' extra]; end

matfile=['replacemany' yrtext '_' num2str(ratio) '.mat'];
if ~exist(matfile,'file') 
    fprintf('Required file %s does not exist.',matfile);
    fprintf('Please copy or recreate with calc_replacemany.m.' );
    return; end;
load(matfile);
r=rmdata;

%valid=find((r.Freq>=fmin | r.Freq==0) & r.Freq<=fmax & ~isnan(r.lat) ...
valid=find( ~isnan(r.lat) ...
    & ~strncmp(cellstr(r.Site),'sunspot_natur_',14) ...
    & ~strncmp(cellstr(r.Site),'Greenland_Be10',14) ...
    & ~strncmp(cellstr(r.Site),'GISP2_intcal98',14) ...
);
nvalid=length(valid);

validsun=find( ~isnan(r.lat) ...
    & ( strncmp(cellstr(r.Site),'sunspot_natur_',14) ...
      | strncmp(cellstr(r.Site),'Greenland_Be10',14) ...
      | strncmp(cellstr(r.Site),'GISP2_intcal98',14)) ...
);
nvalidsun=length(validsun);

site=r.Site(valid);
f=r.Freq(valid);
lat=r.lat(valid);
lon=r.lon(valid);
d=-ones(nvalid,1);
dsun=-ones(nvalidsun,1);
if strcmp(period(1:3),'upp') 
    pres=r.isupp(valid);
    sunpres=r.isupp(validsun);
else
    pres=r.islow(valid);
    sunpres=r.islow(validsun);
end

ipres=find(f>=fmin & f<=fmax & pres);
isunpres=find(r.Freq(validsun)>=fmin & r.Freq(validsun)<=fmax & sunpres);

d(ipres)=1;
dsun(isunpres)=1;



description=site;

ll=[lon;lat]';
[llu,ai,bi]=unique(ll,'rows');
nu=length(ai);

lon=lon(ai);
lat=lat(ai);
description=description(ai);

for i=1:nu
  isel=find(bi==i);
  pos(i)=max(d(isel));
end
d=pos;
nvalid=nu;


latlim=[min(r.lat)-2 max(r.lat)+2];
lonlim=[min(r.lon)-5 max(r.lon)+5];

figure(fignum); clf reset; set_paper(fignum);

m_proj('mollweide','lon',lonlim,'lat',latlim);
hold on;
m_coast('line','Color',[0.7 0.9 0.7]);
% db=20*log10(x);
% 20% = 1.5836
% 10% = 0.8279

nsun=length(validsun);
descsun=r.Site(validsun);
[sunx,suny]=m_ll2xy([0,-120],[65,0]);
sunx=sunx(2); suny=suny(1);
plot(sunx,suny,'Color','y','MarkerSize',30,'Marker','hexagram','MarkerFaceColor','y');
[xs,ys]=distribute_around(sunx,suny,nsun,0.05);
lonsun=zeros(nsun,1);
latsun=zeros(nsun,1);


% put here wiggling /example nAmerica red patch 
[g,glo,gla]=calc_map_mesh(lon,lat,d,3000,1.0);
%function [g,glo,gla]=calc_map_mesh(lon,lat,val,radius,resolution,lonlims,latlims)


%titletext=sprintf('Periodic anomaly presence %s (%d-%d yr, n=%d, %4d/%2d/%1d)',period,round(fmin),round(fmax),length(d(d>0)),year,ratio,binary);

if strcmp(period,'upp') titletext='Cyclic events, Upper Holocene';
else titletext='Cyclic events, Lower Holocene';
end
title(titletext);

%cown=[[185 255 255];[205 255 255];[225 255 255];[255 255 255];[255 225 225];[255 205 205];[255 185 185]]./255;
% improvement 
ncol=13;
h=round([ncol-1:-1:0]/ncol)/2.0;
s=abs(([1:ncol]-ncol/2-0.5)/ncol/1.6);
cown=hsv2rgb([h' s' ones(ncol,1)]);

colormap(cown);
caxis([-1 1]);

m_pcolor(glo,gla,g);
shading interp;
m_grid('box','fancy','tickdir','in','backcolor',[0.9 0.9 0.9],'xticklabels',[],'yticklabels',[]);
%plot_origin_regions;




lona=lon;
lata=lat;

[x,y]=m_ll2xy(lona,lata);
[x,y]=dislocate_slightly(x,y,0.05);
[lona,lata]=m_xy2ll(x,y);

lat=lata;
lon=lona;



plot_map_markers(lon,lat,d,0.5,4,description);

plot(sunx,suny,'Color','y','MarkerSize',30,'Marker','hexagram','MarkerFaceColor','y');
%plot_map_solar_marker(-30,45,dsun,25);
hdls=plot_map_markers(lonsun(1:nsun),latsun(1:nsun),dsun,0,4,descsun);
fprintf('Plot %d (%d)     sun markers\n',nsun,length(unique(hdls)));
for i=1:nsun set(hdls(i),'XData',xs(i),'YData',ys(i)); end

vers=dir('plot_map_replacemany_presence.m');
v=text(0.5,0.5,['@2008 C. Lemmen ' vers.name ' ' vers.date],'Position',[2.9353 -1.8187],...
    'Color',[0.5 0.5 0.5],'Rotation',90,'interpreter','none','FontSize',8);

ending=[ yrtext  '_' num2str(fmin) '_' num2str(fmax)];

set(fignum,'Position',[360   627   560   297]);

set(fignum,'PaperUnits','centimeters');
set(fignum,'PaperOrientation','landscape');
set(fignum,'PaperType','A4');
set(fignum,'PaperPositionMode','manual');
orient(fignum,'tall');
set(fignum,'PaperPosition',[0.634517 0.634517 28.4084 19.715])

plot_multi_format(gcf,['map_replacemany/map_replacemany_presence_' period ending]);

hold off;

return

plot_map_replacemany_presence(1,200,1800,5.5,33,'low');
plot_map_replacemany_presence(2,200,1800,5.5,33,'upp');



ratios=[15 30 40];
years=[1111 5500 6000];
fmins=[200 250 333  500 1000 200  400  200];
fmaxs=[250 333 500 1000 1800 400 1800 1800];
periods=['low'; 'upp'];
for y=1:3 for j=1:3 for i=1:8 for p=1:2 figure(i) ; clf reset; plot_map_replacemany_presence(i,fmins(i),fmaxs(i),years(y),ratios(j),periods(p,:)); end; end ; end; end; 

years=5750; ratios=33; 
fmins=[200 250 333  500 1000 200  400  200];
fmaxs=[250 333 500 1000 1800 400 1800 1800];
periods=['low'; 'upp'];
for y=1:1 for j=1:1 for i=1:8 for p=1:2 figure(i) ; clf reset; plot_map_replacemany_presence(i,fmins(i),fmaxs(i),years(y),ratios(j),periods(p,:)); end; end ; end; end; 

years=5750; ratios=33; 
fmins=[200 200 850 ];
fmaxs=[1800 850 1800];
periods=['low'; 'upp'];
for y=1:1 for j=1:1 for i=1:3 for p=1:2 figure(i) ; clf reset; plot_map_replacemany_presence(i,fmins(i),fmaxs(i),years(y),ratios(j),periods(p,:)); end; end ; end; end; 
