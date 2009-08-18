function plot_map_anomalies(varargin)

cl_register_function();

if ~exist('m_proj') addpath('~/matlab/m_map'); end;
if nargin==0 fignum=1; else fignum=varargin{1}; end;

[dirs,files]=get_files;

load('ts');

holodata=get_holodata(fullfile(dirs.proxies,'proxysites.csv')); 
lon=holodata.Longitude;
lat=holodata.Latitude;

nsites=length(holodata.Datafile);
nts=length(tsfiles);

latlim=[min(lat),max(lat)];
lonlim=[min(lon),max(lon)];

wres=3.0;
lagrid=[ -90+wres/2.0:wres: 90-wres/2.0];
logrid=[-180+wres/2.0:wres:180-wres/2.0];
[wlon,wlat]=meshgrid(logrid,lagrid);
wmap=zeros(length(lagrid),length(logrid),3);
cmap=[copper(8);1,1,1]; 

figure(fignum); clf reset;
colormap(flipud(cmap(2:end,:)));
m_proj('mollweide','lat',latlim,'lon',lonlim);
m_coast('patch',[0.9,0.9,0.9]);
m_grid('box','fancy','tickdir','in');
orient 'landscape';
%m_line(lon,lat,'color','red','Marker','square','linestyle','none','markersize',4);

radius=1000;
level=[1:4];

events=sum(nevents(:,level,:),2)./length(level);
for i=1:nts  
    ts(i).timespan=max(ts(i).time)-min(ts(i).time); 
    ilow=find(ts(i).time >= 5.5);
    iupp=find(ts(i).time <= 6.0);
    if ilow ts(i).lowspan=max(ts(i).time(ilow))-min(ts(i).time(ilow)); else ts(i).lowspan=inf; end
    if iupp ts(i).uppspan=max(ts(i).time(iupp))-min(ts(i).time(iupp)); else ts(i).uppspan=inf; end
    events(i,:)=events(i,:)./[ts(i).lowspan,ts(i).uppspan];
end

if ~exist('noncyclic_wmap.mat','file') 
  for isite=1:nsites
    ifile=0;  
    [dummy, sitename, dummy, dummy]=fileparts(holodata.Datafile{isite});  
    for its=1:nts 
      %fprintf('%d %d %s %s\n',ifile,its,sitename,tsfiles(its).name);
      if strmatch(sitename,tsfiles(its).name) ifile=its;  break; end
    end 
    if ifile==0 
      for its=1:nts 
        fprintf('%d %d %s %s\n',ifile,its,sitename,tsfiles(its).name);
      end
      continue; 
    end 
    holodata.ifile(isite)=ifile;
    ts(ifile).isite=isite;
    
  hdls=m_range_ring(lon(isite),lat(isite),3000,'visible','off');
  [lo,la]=m_xy2ll(get(hdls(1),'XData'),get(hdls(1),'ydata'));
  rl=logrid(logrid<min(lo));rlo(1)=rl(end);
  rl=logrid(logrid>max(lo));rlo(2)=rl(1);
  rl=lagrid(lagrid<min(la));rla(1)=rl(end);
  rl=lagrid(lagrid>max(la));rla(2)=rl(1);
  [glon,glat]=meshgrid(rlo(1):wres:rlo(2),rla(1):wres:rla(2));
  ilon=((rlo(1):wres:rlo(2))-logrid(1))/wres+1;
  ilat=((rla(1):wres:rla(2))-lagrid(1))/wres+1;
  [row,col]=size(glon);
  slon=[repmat(lon(isite),row*col,1),reshape(glon,row*col,1)]';
  slat=[repmat(lat(isite),row*col,1),reshape(glat,row*col,1)]';
  dlon=reshape(slon,2*row*col,1);
  dlat=reshape(slat,2*row*col,1);
  dist=m_lldist(dlon,dlat);
  dist(dist>3000)=inf;
  dist=reshape(dist(1:2:row*col*2),row,col);
  for iperiod=1:2
     ev=events(ifile,1,iperiod);
     if ev>0
        wmap(ilat,ilon,iperiod)=max(wmap(ilat,ilon,iperiod),1*exp(-dist/radius)) ...
                                      +0*exp(-dist/radius);       
        %wmap(ilat,ilon,iperiod)=max(wmap(ilat,ilon,iperiod),0.0*exp(-dist/1000)) + exp(-dist/1000);       
     end
 end   
 ev=events(ifile,1,:);
 wmap(ilat,ilon,3)=wmap(ilat,ilon,3) + (ev(2)-ev(1))*exp(-dist/radius);
 
  fprintf('.'); if mod(isite,80)==0 fprintf('\n'); end;
end
save('noncyclic_wmap','wmap','holodata');
else
  load('noncyclic_wmap');
end

zmap=wmap(:,:,1)*0;
%wmap(:,:,3)=wmap(:,:,2)-wmap(:,:,1);

pnames={'Lower','Upper','Change'};

%set(gcf,'renderer','zbuffer');
%set(gcf,'units','centimeters','Position',[0 0 21.0 13.7]);
%set(gcf, 'PaperPositionMode', 'auto', 'PaperOrientation', 'portrait');

cown=[[185 255 255];[205 255 255];[225 255 255];[255 255 255];[255 225 225];[255 205 205];[255 185 185]]./255;

%wmap(:,:,3)=wmap(:,:,2)-wmap(:,:,1);

names=strrep(holodata.Datafile,'.dat','');

for iperiod=1:3
  figure(iperiod); clf reset;
 
  if iperiod<3 absmax=max(max(max(abs(wmap(:,:,1:2)))));
  else absmax=0.08*max(max(max(abs(wmap(:,:,3))))); end

  m_proj('mollweide','lat',latlim,'lon',lonlim);
  if any(any(wmap(:,:,iperiod))>0)
    m_pcolor(wlon,wlat,wmap(:,:,iperiod)); 
    shading('interp');
    caxis([-absmax,absmax]);
    colormap(cown);
 end
  m_coast('line','color',[0.8,0.8,0.8]);
  m_grid('box','fancy','tickdir','in');
  m_text(-142,-65,pnames(iperiod),'fontsize',18);
  if iperiod<3
    ev=events(holodata.ifile>0,1,iperiod);
    m_line(lon(ev>0) ,lat(ev>0) ,'MarkerSize',6,'color',[1 0 0],'linestyle','none','Marker','Diamond','MarkerFaceColor',[1 0.5 0.5]);
    colorbar;
else
    ev=events(holodata.ifile>0,1,2)-events(holodata.ifile>0,1,1);
    %m_line(lon(ev>0),lat(ev>0),'color','r','marker','d','linestyle','none');
    %m_line(lon(ev<0),lat(ev<0),'color','b','marker','s','linestyle','none');
    plot_map_markers(lon,lat,ev,0,2,names)
end

title(['R=' num2str(radius) ' P=' num2str(level)]);

  
end

hdl=colorbar;



return;
