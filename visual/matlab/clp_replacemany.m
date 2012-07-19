function clp_replacemany(fignum,fmin,fmax,year,ratio,dyear,extra,period)
%extra='eleven';
%period='upp';
cl_register_function();

if ~exist('m_proj') addpath('/h/lemmen/matlab/m_map'); end;

notitle=1;

%extra='eleven';
if ~exist('year','var') | strcmp(year,'') year=6.0; end
if ~exist('dyear','var') dyear=0.5; end
if ~exist('ratio','var') ratio=33; end
if ~exist('fignum','var') fignum=1; end
if ~exist('fmin','var') fmin=200; end
if ~exist('fmax','var') fmax=1800; end
if ~exist('period','var') period='change'; end

yrtext=sprintf('%.1f_%.1f',year,dyear);

if exist('extra','var') yrtext=[yrtext '_' extra]; end

matfile=['replacemany_' yrtext '_' num2str(ratio) '.mat'];

if ~exist(matfile,'file') 
    fprintf('Required file %s does not exist.',matfile);
    fprintf('Please copy or recreate with calc_replacemany.m.' );
    return; 
end;

load(matfile);
r=rmdata;

n=length(r.lat);
lim=80;
r.lat=max([min([r.lat;zeros(1,n)+lim]);zeros(1,n)-lim]);
latlim=[-82,82];
lonlim=[min(r.lon)-5 max(r.lon)+5];

valid=find( ~isnan(r.lat)  & r.No_sort<500 ...
    & ~strncmp(cellstr(r.Site),'sunspot_natur_',14) ...
    & ~strncmp(cellstr(r.Site),'Greenland_Be10',14) ...
    & ~strncmp(cellstr(r.Site),'GISP2_intcal98',14) ...
);
if strcmp(period,'change') 
    valid=valid(find(r.Freq(valid)>=fmin & r.Freq(valid)<=fmax));
end
    nvalid=length(valid);

validsun=find( r.No_sort<500 ...
    & ( strncmp(cellstr(r.Site),'sunspot_natur_',14) ...
      | strncmp(cellstr(r.Site),'Greenland_Be10',14) ...
      | strncmp(cellstr(r.Site),'GISP2_intcal98',14)) ...
);


site=r.Site(valid);
f=r.Freq(valid);
lat=r.lat(valid);
lon=r.lon(valid);
nsun=length(validsun);
latsun=45+[-2,+2,-2];
lonsun=-30+[-2,0,2];
descsun=r.Site(validsun);

description=site;

switch(period)
    case 'change',
      d=r.gdiff(valid);
      %d=r.isupp(valid)-r.islow(valid); 
      %dsun=r.isupp(validsun)-r.islow(validsun);
      dsun=r.gdiff(validsun);

    case 'low'
      d=2*r.islow(valid)-1;
      dsun=2*r.islow(validsun)-1;
    case 'upp'
        d=2*r.isupp(valid)-1;
        dsun=2*r.isupp(validsun)-1;
    otherwise
        error('Period not defined');
end

[llu,ai,bi]=unique(descsun);
nsun=length(ai);
descsun=descsun(ai);

pos=zeros(nsun,1);
for i=1:nsun , pos(bi(i))=pos(bi(i))+dsun(i); end

dsun=max(-1,pos);
dsun=min(1,dsun);

[llu,ai,bi]=unique(description);
nu=length(ai);
lon=lon(ai);
lat=lat(ai);
ll=[lon;lat]';

description=description(ai);

for i=1:nu
  isel=find(bi==i);
  if strcmp(period,'change')
    pos(i)=sum(d(isel));
  else
      pos(i)=max(d(isel));
  end
end
pos=min(1,pos);
pos=max(-1,pos);
d=pos;
nvalid=nu;

figure(fignum); clf reset; set_paper(fignum);

m_proj('equidistant','lon',lonlim,'lat',latlim);
hold on;
%m_coast('line','Color',[0.3 0.6 0.3],'LineWidth',2);
m_coast('line','Color',2*[0.3 0.3 0.3],'LineWidth',2);
% db=20*log10(x);
% 20% = 1.5836
% 10% = 0.8279

[g,glo,gla]=calc_map_mesh(lon,lat,d,3000,1.0);
%function [g,glo,gla]=calc_map_mesh(lon,lat,val,radius,resolution,lonlims,latlims)

titletext=sprintf('Cyclic events %s (%d-%d yr)',period,round(fmin/10)*10,round(fmax));
if ~notitle
  title(titletext);
end

% improvement
ncol=13;
%h=round([ncol-1:-1:0]/ncol)/1.5;
h=zeros(1,ncol);
h(1:ncol/2)=0.6;
h(ncol/2+1:end)=0.04;
s=abs(([1:ncol]-ncol/2-0.5)/ncol/1.2)*1.5;
cown=hsv2rgb([h' s' ones(ncol,1)]);

colormap(cown);

if strcmp(period,'change')
 gt=min([max(max((g)),abs(min(min(g))))]);
 g(g<-gt)=-gt;
 g(g>gt)=gt;
%end

%d=sign(d).*min(abs(d),8)*2; 
else 
 caxis([-1 1]);
end

m_pcolor(glo,gla,g/2);
shading interp;
m_grid('box','on','tickdir','in','backcolor',[0.9 0.9 0.9],'xticklabels',[],'yticklabels',[]);
%plot_origin_regions;

% Plot the markers, wiggle all lats that are unique to a description
allvalid=find(~isnan(r.lat)  & r.No_sort<500 ...
    & ~strncmp(cellstr(r.Site),'sunspot_natur_',14) ...
    & ~strncmp(cellstr(r.Site),'Greenland_Be10',14) ...
    & ~strncmp(cellstr(r.Site),'GISP2_intcal98',14) ...
);
nallvalid=length(allvalid);


invalid=find(r.Freq(allvalid)<fmin | r.Freq(allvalid)>fmax);
site=r.Site(allvalid);
lat=r.lat(allvalid);
lon=r.lon(allvalid);

switch(period)
    case 'change',
      d=r.gdiff(allvalid);
      d(invalid)=NaN;
    case 'upp',d=2*r.isupp(allvalid)-1;
        d(invalid)=0;
    case 'low',d=2*r.islow(allvalid)-1;
        d(invalid)=0;
end
description=site;

[llu,ai,bi]=unique(description);
nu=length(ai);
lon=lon(ai);
lat=lat(ai);

description=description(ai);
pos=NaN;
for i=1:nu
  isel=find(bi==i);
  ifin=find(isfinite(d(isel)));
  if ~isempty(ifin)
    if strcmp(period,'change')
      pos(i)=sum(d(isel(ifin)));
    else pos(i)=max(d(isel(ifin)));
    end
  else
    pos(i)=NaN;
  end
end
valid=find(isfinite(pos));
invalid=find(isnan(pos));

%pos=min(1,pos);
%pos=max(-1,pos);
d=pos;
d(invalid)=NaN;

fprintf('There are %d sites , of these %d with peaks and %d without\n',...
    length(d),length(valid),length(invalid));

[x,y]=m_ll2xy(lon,lat);
[x,y]=dislocate_slightly(x,y,0.05);
[lon,lat]=m_xy2ll(x,y);

if ~isempty(invalid)
  hdls=plot_map_markers(lon(invalid),lat(invalid),invalid*0+1,1.5836,4,description(invalid));
  set(hdls,'MarkerFaceColor','none');
  fprintf('Plot %d (%d) invalid markers\n',length(invalid),length(unique(hdls)));
end

%hdls=plot_map_markers(r.lon(valid(ai)),r.lat(valid(ai)),d,1.5836,4,description);
if strcmp(period,'change')
  hdls=plot_map_markers(lon(valid),lat(valid),d(valid),1.5836,4,description(valid));
  %set(hdls(d(valid)>0),'MarkerFaceColor',cown(ncol,:));
else
   hdls=plot_map_markers(lon(valid),lat(valid),d(valid),0.5,4,description(valid));
end
fprintf('Plot %d (%d)   valid markers\n',length(valid),length(unique(hdls)));



% Plot the sun markers, wiggle all lats that are unique to a description
allvalid=find(~isnan(r.lat)  & r.No_sort<500 ...
    & (strncmp(cellstr(r.Site),'sunspot_natur_',14) ...
    | strncmp(cellstr(r.Site),'Greenland_Be10',14) ...
    | strncmp(cellstr(r.Site),'GISP2_intcal98',14)) ...
);
nallvalid=length(allvalid);


invalid=find(r.Freq(allvalid)<fmin | r.Freq(allvalid)>fmax);
site=r.Site(allvalid);

switch(period)
    case 'change',
      d=r.gdiff(allvalid);
      d(invalid)=NaN;
    case 'upp',d=2*r.isupp(allvalid)-1;
        d(invalid)=0;
    case 'low',d=2*r.islow(allvalid)-1;
        d(invalid)=0;
end
description=site;

[llu,ai,bi]=unique(description);
nu=length(ai);

description=description(ai);
pos=NaN;
for i=1:nu
  isel=find(bi==i);
  ifin=find(isfinite(d(isel)));
  if ~isempty(ifin)
    if strcmp(period,'change')
      pos(i)=sum(d(isel(ifin)));
    else pos(i)=max(d(isel(ifin)));
    end
  else
    pos(i)=NaN;
  end
end
valid=find(isfinite(pos));
invalid=find(isnan(pos));

%pos=min(1,pos);
%pos=max(-1,pos);
d=pos;
d(invalid)=NaN;

fprintf('There are %d sun sites , of these %d with peaks and %d without\n',...
    length(d),length(valid),length(invalid));

[sunx,suny]=m_ll2xy([0,-120],[65,0]);
sunx=sunx(2); suny=suny(1);
%plot(sunx,suny,'Color','y','MarkerSize',30,'Marker','hexagram','MarkerFaceColor','y');
[x,y]=distribute_around(sunx,suny,nsun,0.05);

[lon,lat]=m_xy2ll(x,y);

if ~isempty(invalid)
  hdls=plot_map_markers(lon(invalid),lat(invalid),invalid*0+1,1.5836,4,description(invalid));
  set(hdls,'MarkerFaceColor','none');
  for i=1:length(hdls) set(hdls(i),'XData',x(invalid(i)),'YData',y(invalid(i))); end
  fprintf('Plot %d (%d) invalid markers\n',length(invalid),length(unique(hdls)));
end

if strcmp(period,'change')
  hdls=plot_map_markers(lon(valid),lat(valid),d(valid),1.5836,4,description(valid));
else
   hdls=plot_map_markers(lon(valid),lat(valid),d(valid),0.5,4,description(valid));
end
for i=1:length(hdls) set(hdls(i),'XData',x(valid(i)),'YData',y(valid(i))); end
fprintf('Plot %d (%d)   valid markers\n',length(valid),length(unique(hdls)));


vers=dir('plot_map_replacemany.m');
%v=text(0.5,0.5,['@2008 C. Lemmen ' vers.name ' ' vers.date],'Position',[1.93 0],...
%    'Color',[0 0.5 0.5],'Rotation',90,'interpreter','none','FontSize',8,'HorizontalAlignment','Center');

ending=[ period '_' yrtext  '_' num2str(fmin) '_' num2str(fmax)];
%colorbar

set(fignum,'Position',[360   627   560   297]);
set(fignum,'PaperUnits','centimeters');
set(fignum,'PaperOrientation','landscape');
set(fignum,'PaperType','A4');
set(fignum,'PaperPositionMode','manual');
orient(fignum,'tall');
%set(fignum,'PaperPosition',[0.634517 0.634517 28.4084 19.715])

cl_print('name','replacemany','ext','png','res',300);
hold off;

return


% Control run 
years=5.5; ratios=33; 
fmins=[  200 200   850];
fmaxs=[ 1800 850  1800];
for y=1:1 for j=1:1 for i=1:3 figure(i) ; clf reset; plot_map_replacemany(i,fmins(i),fmaxs(i),years(y),ratios(j),0.5,'eleven','change'); end; end ; end;
plot_map_replacemany(6,200,1800,5.5,33,0.5,'eleven','upp'); 
plot_map_replacemany(7,200,1800,5.5,33,0.5,'eleven','low'); 



% Control run full
years=5.5; ratios=33; 
fmins=[200 200 200  200 250 333 400  500  500 1000  850];
fmaxs=[250 400 850 1800 333 500 1800 1000 1800 1800 1800];
for y=1:1 for j=1:1 for i=1:11 figure(i) ; clf reset; plot_map_replacemany(i,fmins(i),fmaxs(i),years(y),ratios(j),0.5,'eleven'); end; end ; end;

% Methodology variation
extra = {'d0.12','normalised','deevented','detrended'};
years=5.5; ratios=33; 
fmins=[200];
fmaxs=[1800];
for y=1:1 for j=1:1 for i=1:4 figure(i) ; clf reset; plot_map_replacemany(i,fmins,fmaxs,years(y),ratios(j),0.5,extra{i}); end; end ; end;


% TCRIT variation
years=[2.0:0.2:9.0];
ratios=33; dyear=2.0;
fmins=200; fmaxs=1800;
for i=1:numel(years) figure(3); clf reset; plot_map_replacemany(3,fmins,fmaxs,years(i),ratios,2.0); end



