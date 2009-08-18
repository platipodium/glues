function plot_map_proxysites(fignum);

cl_register_function();

if ~exist('m_proj') addpath('/h/lemmen/matlab/m_map'); end;
if ~exist('fignum','var') fignum=1; end

matfile=['holodata.mat'];

if ~exist(matfile,'file') 
    fprintf('Required file %s does not exist.',matfile);
    fprintf('Please copy or recreate with get_holodata.m.' );
    return; end;
load(matfile);
r=holodata;

lat=r.Latitude;
lon=r.Longitude;
n=length(lat);
lim=80;

valid=find( ~isnan(lat)  & r.No_sort<500 ...
    & ~strncmp(cellstr(r.Datafile),'sunspot_natur_',14) ...
    & ~strncmp(cellstr(r.Datafile),'Greenland_Be10',14) ...
    & ~strncmp(cellstr(r.Datafile),'GISP2_intcal98',14) ...
);
nvalid=length(valid);


description=r.Datafile(valid);
lat=r.Latitude(valid);
lat=max([min([lat;zeros(1,nvalid)+lim]);zeros(1,nvalid)-lim]);

lon=r.Longitude(valid);
no=r.No_sort(valid);

  
ll=[lon;lat]';
[llu,ai,bi]=unique(ll,'rows');


%[llu,ai,bi]=unique(description);

nu=length(ai);

lon=lon(ai);
lat=lat(ai);


latlim=[82];
lonlim=[min(lon)-5 max(lon)+5];

figure(fignum); clf reset; set_paper(fignum);
set(fignum,'PaperUnits','centimeters');
set(fignum,'PaperOrientation','landscape');
set(fignum,'PaperType','A4');
set(fignum,'PaperPositionMode','manual');
orient(fignum,'tall');
set(fignum,'PaperPosition',[-0.2687    7.1962   21.5288   15.2583])

m_proj('mollweide','lon',lonlim,'lat',[-latlim latlim]);
hold on;
%m_coast('line','Color',[0.7 0.9 0.7],'LineWidth',2);
m_coast('line','Color',[0.3 0.6 0.3],'LineWidth',1);

ilat=find(abs(lat)>latlim);
lat(ilat)=sign(lat(ilat))*latlim;

for j=1:3
[x,y]=m_ll2xy(lon,lat);
[x,y]=dislocate_slightly(x,y,0.03);
[lon,lat]=m_xy2ll(x,y);
end

fprintf('Mark locations of %d proxies at %d sites',nvalid,nu);
titletext=sprintf('Location of %d proxies at %d sites',nvalid,nu);
%title(titletext);

%cown=[[185 255 255];[205 255 255];[225 255 255];[255 255 255];[255 225 225];[255 205 205];[255 185 185]]./255;
% improvement 
ncol=13;
h=round([ncol-1:-1:0]/ncol)/2.0;
s=abs(([1:ncol]-ncol/2-0.5)/ncol/1.2)*1.5;
cown=hsv2rgb([h' s' ones(ncol,1)]);

m_grid('box','fancy','tickdir','in','backcolor','w','xticklabels',[],'yticklabels',[]);
 
hdls=plot_map_markers(lon,lat,lat*0+1,1.5836,2,description);
set(hdls,'MarkerFaceColor',[0.5 0.5 0.5],'Color',[0.5 0.5 0.5],'Marker','d');
fprintf('Plot %d (%d) markers\n',length(lat),length(unique(hdls)));

lon=r.Longitude(valid);
lat=r.Latitude(valid);
no=r.No_sort(valid);

[x,y]=m_ll2xy(lon,lat);
[x,y]=dislocate_slightly(x,y,0.07);
[lont,latt]=m_xy2ll(x,y);
fs=15;
for i=1:nvalid
    t(no(i))=m_text(lont(i),latt(i),num2str(no(i)),'HorizontalAlignment','Center',...
        'VerticalAlignment','Middle','FontSize',fs,'FontName','Helvetica-narrow'); 
   % m_line([lont(i),lon(i)],[latt(i),lat(i)],'r-','Color',[0.7 0.7 0.7]);
end


set(fignum,'Position',[ 162   476   849   448]);


% Now put a breakpoint here and manueally edit the figure, 
% afterwords, save all corrected position in variables pos
if (1==0)
pos=zeros(length(t),3);
for i=1:nvalid, pos(no(i),:)=get(t(no(i)),'Position'); end
save('map_proxysites_correction.mat','pos');
end

% Apply correction
load('map_proxysites_correction');
for i=1:nvalid, set(t(no(i)),'Position',pos(no(i),:)); end

vers=dir('plot_map_proxysites.m');
%v=text(0.5,0.5,['@2008 C. Lemmen ' vers.name ' ' vers.date],'Position',[1.93 0],...
%    'Color',[0 0.5
%    0.5],'Rotation',90,'interpreter','none','FontSize',8,'HorizontalAlignment','Center');

valid=find(strncmp(cellstr(r.Datafile),'sunspot_natur_',14) ...
     | strncmp(cellstr(r.Datafile),'Greenland_Be10',14) ...
     | strncmp(cellstr(r.Datafile),'GISP2_intcal98',14) );
nvalid=length(valid);

[sunx,suny]=m_ll2xy([0,-120],[65,0]);
sunx=sunx(2); suny=suny(1);
plot(sunx,suny,'Color','y','MarkerSize',30,'Marker','hexagram','MarkerFaceColor','y');
[x,y]=dislocate_slightly(repmat(sunx,nvalid,1),repmat(suny,nvalid,1),0.042);
for i=1:length(valid)
    text(x(i),y(i),num2str(r.No_sort(valid(i))),'HorizontalAlignment','Center',...
        'VerticalAlignment','Middle','FontSize',fs,'FontName','Helvetica-narrow'); 
end

plot_multi_format(gcf,'map_proxysites');

hold off;

return
