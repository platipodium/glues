function plot_map_band_cluster(varargin)

cl_register_function();

if ~exist('m_proj') addpath('~/matlab/m_map'); end;
if nargin==0 fignum=1; else fignum=varargin{1}; end;

[dirs,files]=get_files;

scenario='o4n2w1';

files.redfit=['redfit_',scenario];
fid=fopen([files.redfit '.mat'],'r');
if fid<0
  redfitdata=read_textcsv([files.redfit '.tsv'],' ','"');
  save([files.redfit '.mat'],'redfitdata');
else
  fclose(fid);
  load([files.redfit '.mat']);
end

holodata=get_holodata(fullfile(dirs.proxies,'proxysites.csv')); 
lon=holodata.Longitude;
lat=holodata.Latitude;

nsites=length(holodata.Datafile);
nred=length(redfitdata.dataset);

sigfile=['sig_' scenario '.mat'];
load(sigfile);

latlim=[min(lat)-2,max(lat)+2];
lonlim=[min(lon)-2,max(lon)+2];

wres=3.0;
lagrid=[ -90+wres/2.0:wres: 90-wres/2.0];
logrid=[-180+wres/2.0:wres:180-wres/2.0];
[wlon,wlat]=meshgrid(logrid,lagrid);
wmap=zeros(length(lagrid),length(logrid),7,3,7);

cown=[[185 255 255];[205 255 255];[225 255 255];[255 255 255];[255 225 225];[255 205 205];[255 185 185]]./255;
colormap(cown);

maxdist=1500;
%figure(fignum);
m_proj('miller','lat',latlim,'lon',lonlim);
m_coast('line','color',[0.8 0.8 0.8]);
m_grid;

level=5;
currentsites=[];
for isite=1:nsites
  if (any([sig.low(isite,:)==level, sig.upp(isite,:)==level])) currentsites=[currentsites,isite]; end
end
ncurrent=length(currentsites);
distances=zeros(ncurrent,ncurrent)+inf;
nextneighbour=zeros(ncurrent);
for i=1:ncurrent
  isite=currentsites(i);
  for j=i:ncurrent
    distances(i,j)=m_lldist([lon(isite),lon(currentsites(j))],[lat(isite),lat(currentsites(j))]);
  end
  distances(i,find(distances(i,:)<1))=inf;
  [dum,imin]=min(distances(i,:));
  jsite=currentsites(imin);
  dist=min([distances(i,imin),maxdist]);

  m_line(lon(isite),lat(isite)','Marker','diamond');
  hdls=m_range_ring(lon(isite),lat(isite),dist);
  continue;
  
   
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
    if (isite==1) for iperiod=1:3 figure(iperiod); clf; end; end;
    radius=1500.;
    for iperiod=1:3 
      if iperiod==1 period='low' ;
      elseif iperiod==2 period='upp';
      else period='tot';
      end        
      for iband=1:3
        signif=eval(sprintf('sig.%s(%d,%d)',period,isite,iband));
        isig=signif+2;
        if isnan(signif) continue; end
        wmap(ilat,ilon,iperiod,iband,isig)=max(wmap(ilat,ilon,iperiod,iband,isig),dist);%wmap(ilat,ilon,iperiod,iband,isig)+ (exp(-dist/radius));
      end; end;
    %shading('interp');
    %m_pcolor(wlon,wlat,wmap); shading('interp');
    %colormap(map);
    %shading('interp')
    %colormap(map);
    fprintf('.'); if mod(isite,80)==0 fprintf('\n'); end;
  end
end

return
%hold off;
%DIN A4 = 210 mm x 0297 mm
%figure(1); clf;
%set(gcf,'renderer','zbuffer');
%set(gcf,'units','centimeters','Position',[0 0 21.0 13.7]);
%set(gcf, 'PaperPositionMode', 'auto', 'PaperOrientation', 'portrait');
%m_proj('miller','lat',latlim,'lon',lonlim);
%m_coast('patch',[0.9,0.9,0.9]);
%m_grid('box','fancy','tickdir','in');
orient 'landscape';

pnames={'Lower','Upper','Total','Low-not-total','Upp-not-total','Low-not-upp','Upp-not-low'};
fnames={'(1300\pm 500yr)^{-1}','(550\pm 90yr)^{-1}','(330\pm 50yr)^{-1}'};

for iperiod=1:3
  if iperiod==1 period='low' ;
  elseif iperiod==2 period='upp';
  else period='tot'; end
  for iband=1:3
    figure((iperiod-1)*3+iband); clf;
    set(gcf, 'PaperPositionMode', 'auto', 'PaperOrientation', 'portrait');
    m_proj('miller','lat',latlim,'lon',lonlim);
    m_coast('patch',[0.9,0.9,0.9]);
    m_grid('box','fancy','tickdir','in');
    

    % Plot blue markers for significance less than 90% (sig<2)
    for isig=1:-1:-1
     
     valid=eval(['find(sig.' period '(:,iband)==isig)']);
     if ~isempty(valid)
        m_line(lon(valid),lat(valid),'MarkerSize',(2-isig)*2,'color',[0 0 0],'linestyle','none',...
          'Marker','Square','MarkerFaceColor',[0.5 0.5 1]);
      end
    end

    
    
    % Plot red markers for significance greaterequal critical (sig==5)
    % also plot rangring from wmap
    for isig=2:7
      %m_pcolor(wlon,wlat,wmap(:,:,iperiod,iband,6)); 

      valid=eval(['find(sig.' period '(:,iband)==isig)']);
      if ~isempty(valid)
        m_line(lon(valid),lat(valid),'MarkerSize',(isig-1)*2,'color',[1 0 0],'linestyle','none',...
          'Marker','Diamond','MarkerFaceColor',[1 0.5 0.5]);
      end
    end
    m_text(-142,-70,fnames(iband),'FontSize',16);
    m_text(-142,-10,pnames(iperiod),'FontSize',16);
  end
end


figure(11); clf reset;
absmax=max(max(max(max(max(abs(wmap(:,:,:,:,:)))))));
wmax=max(max(max(max(max(wmap(:,:,:,:,:))))));
wmin=min(min(min(min(min(wmap(:,:,:,:,:))))));

dmap=sum(wmap(:,:,:,:,4:7),5)-sum(wmap(:,:,:,:,1:3),5);
absmax=max(max(max(max(max(abs(dmap(:,:,:,:)))))));

for iperiod=1:3 for iband=1:3 
    if iperiod==1 period='low' ;
    elseif iperiod==2 period='upp';
    else period='tot'; end
    axes('Position',[1-iperiod*.32,(iband-1)*.32,.31,.31]);
    
    m_proj('miller','lat',latlim,'lon',lonlim);
    %if any(any(wmap(:,:,iperiod,iband,4))>0)
      m_pcolor(wlon,wlat,dmap(:,:,iperiod,iband));
      %m_pcolor(wlon,wlat,max(wmap(:,:,iperiod,iband,5:7),[],5));
      shading('interp');
      colormap(cown);
      caxis([-absmax;absmax]);
      %end;
    m_coast;
    m_grid('box','fancy','tickdir','in');
    if (iperiod<3) set(gca,'yticklabel',[]); end
    if (iband>1)   set(gca,'xticklabel',[]); end
    m_patch([-150,0,0,-150],[-75,-75,-60,-60],'w'); 
    m_text(-142,-70,fnames(iband));
    m_text(-150,-10,pnames(iperiod));
    signif=eval(sprintf('sig.%s(:,%d)',period,iband));
    m_line(lon(signif==5) ,lat(signif==5) ,'MarkerSize',6,'color',[1 0 0],'linestyle','none','Marker','Diamond','MarkerFaceColor',[1 0.5 0.5]);
    %m_line(lon(signif<0)  ,lat(signif<0),'MarkerSize',6,'color',[0 0 1],'linestyle','none','Marker','Diamond','MarkerFaceColor',[0.5 0.5 1]);
    if (iperiod==2 && iband==3) title('Presence of signal in frequency bands'); end;

end; end;

zmap=wmap(:,:,1,1,:)*0;
for iband=1:3 
  wmap(:,:,4,iband,:)=max(wmap(:,:,1,iband,:)-wmap(:,:,3,iband,:),zmap); % low not tot
  wmap(:,:,5,iband,:)=max(wmap(:,:,2,iband,:)-wmap(:,:,3,iband,:),zmap); % upp not tot
  wmap(:,:,6,iband,:)=max(wmap(:,:,1,iband,:)-wmap(:,:,2,iband,:),zmap); % low not upp
  wmap(:,:,7,iband,:)=max(wmap(:,:,2,iband,:)-wmap(:,:,1,iband,:),zmap); % upp not low
end;

figure(12); clf;
set(gcf,'renderer','zbuffer');
set(gcf,'Position',[200 0 700 550]);
absmax=max(max(max(max(max(abs(wmap(:,:,4:7,1:3,:)))))));

for iperiod=4:7 for iband=1:3 
  axes('Position',[.04+(iband-1)*.32,(iperiod-4)*.25,.27,.22]);
  
  m_proj('miller','lat',latlim,'lon',lonlim);
  if any(any(wmap(:,:,iperiod,iband,4:6)>0))
    m_pcolor(wlon,wlat,sum(wmap(:,:,iperiod,iband,4:6),5)); 
    shading('interp');
    colormap(cown);
    caxis([-absmax,absmax]);
 end;
  m_coast;
  m_grid('box','fancy','tickdir','in');
  title(sprintf('%s band %d',pnames{iperiod},iband));
  
  
  if (iperiod<7) set(gca,'yticklabel',[]); end
  if (iband>1)   set(gca,'xticklabel',[]); end

end; end;

for iband=1:3 
  wmap(:,:,4,iband,:)=wmap(:,:,1,iband,:)-wmap(:,:,3,iband,:); % low - tot
  wmap(:,:,5,iband,:)=wmap(:,:,2,iband,:)-wmap(:,:,3,iband,:); % upp - tot
  wmap(:,:,6,iband,:)=wmap(:,:,2,iband,:)-wmap(:,:,1,iband,:); % upp - low
end;
absmax=max(max(max(max(max(abs(wmap(:,:,4:6,:,:)))))));

pnames={'Lower','Upper','Total','Low-Total','Upp-total','Upp-Low'};

figure(13); clf;
set(gcf,'renderer','zbuffer');
set(gcf,'Position',[200 0 700 550]);

for iperiod=4:6 for iband=1:3 
  axes('Position',[.04+(iband-1)*.32,(iperiod-4)*.32,.27,.27]);
  m_proj('miller','lat',latlim,'lon',lonlim);
  if (any(any(any(wmap(:,:,iperiod,iband,:))))>0)
    m_pcolor(wlon,wlat,sum(wmap(:,:,iperiod,iband,:),5)); 
    shading('interp');
    colormap(cown);
    caxis([-absmax,absmax]);
 end;
  m_coast;
  m_grid('box','fancy','tickdir','in');
  title(sprintf('%s band %d',pnames{iperiod},iband));
end; end;
%colorbar;

%m_coast('patch',[0.9,0.9.0.9]);
%m_line(lon,lat,'color','red','Marker','square','linestyle','none','markersize',4);

for fignum=1:3 
  plot_multi_format(fignum,fullfile(dirs.setup,['map_band_events_' num2str(fignum)]));
end;
return;
