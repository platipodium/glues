function plot_map_freqchange(varargin)

cl_register_function();

if ~exist('m_proj') addpath('~/matlab/m_map'); end;
if nargin==0 fignum=1; else fignum=varargin{1}; end;

[dirs,files]=get_files;


files.redfit=['redsig'];
fid=fopen([files.redfit '.mat'],'r');
if fid<0
  redfitdata=read_textcsv([files.redfit '.tsv'],' ','"');
  save([files.redfit '.mat'],'redfitdata');
else
  fclose(fid);
  load([files.redfit '.mat']);
end

holodata=get_holodata(fullfile(dirs.proxies,'proxysites.csv')); 

valid=[1:138];
%valid=[1:5,7:14,17:23,26:29,31:35,37:43,45:47,49,51:56,...
%       58:60,63:65,67:69,71,73:77,80:87,89,90,92:96,98:100,...
%       102:104,107:109,111:118,121:138];

lon=holodata.Longitude;
lat=holodata.Latitude;

nsites=length(holodata.Datafile);
nred=length(redfitdata.dataset);

latlim=[min(lat),max(lat)];
lonlim=[min(lon),max(lon)];

wres=3.0;
lagrid=[ -90+wres/2.0:wres: 90-wres/2.0];
logrid=[-180+wres/2.0:wres:180-wres/2.0];
[wlon,wlat]=meshgrid(logrid,lagrid);
wmap=zeros(length(lagrid),length(logrid),7,3,7);

cown=[[185 255 255];[205 255 255];[225 255 255];[255 255 255];[255 225 225];[255 205 205];[255 185 185]]./255;
colormap(cown);

figure(9); clf  reset; 
m_proj('miller','lat',latlim,'lon',lonlim);
close(9);
if 0 m_coast; m_grid; end


if exist([files.redfit '_wmap.mat'],'file') load([files.redfit '_wmap.mat']);
else for isite=valid
  hdls=m_range_ring(lon(isite),lat(isite),3000,'visible','off');
  lomin=NaN; lomax=NaN; lamin=NaN; lamax=NaN;
  for i=1:length(hdls)
    [lo,la]=m_xy2ll(get(hdls(i),'XData'),get(hdls(i),'ydata'));
    lomin=min([lo,lomin]);lomax=max([lo,lomax]);
    lamin=min([la,lamin]);lamax=max([la,lamax]);
    
  end
  rl=logrid(logrid<=lomin);rlo(1)=rl(end);
  rl=logrid(logrid>=lomax);rlo(2)=rl(1);
  rl=lagrid(lagrid<=lamin);rla(1)=rl(end);
  rl=lagrid(lagrid>=lamax);rla(2)=rl(1);
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
         wmap(ilat,ilon,iperiod,iband,isig)=wmap(ilat,ilon,iperiod,iband,isig)+ (exp(-dist/radius));
  end; end;
  if 0 %(sig.low(isite,3)>=min(positive)   )
      m_pcolor(wlon,wlat,sum(wmap(:,:,1,3,positive+2),5)/length(positive)); 
      shading('interp');
      %colormap(cown);
      %caxis([-absmax;absmax]);
        m_line(lon(isite),lat(isite),'MarkerSize', (sig.low(isite,3)-2)*2,'color',[1 0 0],'linestyle','none','Marker','Square','MarkerFaceColor','none');
      continue;
  end
  fprintf('.'); if mod(isite,80)==0 fprintf('\n'); end;
end
save(['wmap_' scenario],'wmap');
end

nomap=zeros(length(lagrid),length(logrid),7,3);
for iband=1:3 for iperiod=1:3 
  nomap(:,:,iperiod,iband)=any(wmap(:,:,iperiod,iband,:)>0,5);
end; end;
       

%DIN A4 = 210 mm x 0297 mm
figure(10); clf reset;
set(gcf,'units','centimeters','Position',[0 0 18.0 22.0]);
set(gcf, 'PaperPositionMode', 'auto', 'PaperOrientation', 'portrait');
m_proj('miller','lat',latlim,'lon',lonlim);
ptitle=sprintf('p=[%d',positive(1)); 
for i=2:length(positive) ptitle=[ptitle sprintf(', %d',positive(i))]; end
ptitle=[ptitle sprintf('] n=[%d',negative(1))];
for i=2:length(negative) ptitle=[ptitle sprintf(', %d',negative(i))]; end
ptitle=[ptitle ']'];
orient 'portrait';

pnames={'Lower','Upper','Total','Low-not-total','Upp-not-total','Low-not-upp','Upp-not-low'};
fnames={'(1300\pm 500yr)^{-1}','(550\pm 90yr)^{-1}','(330\pm 50yr)^{-1}'};


for iperiod=1:2
 if iperiod==1 period='low' ;
 elseif iperiod==2 period='upp';
 else period='tot'; end
 for iband=1:3
  %figure((iperiod-1)*3+iband); clf;
  %set(gcf, 'PaperPositionMode', 'auto', 'PaperOrientation', 'landscape');
  %m_proj('miller','lat',latlim,'lon',lonlim);
  axes('Position',[1-iperiod*.5,(iband-1)*.32,.48,.31]);
  m_coast('patch',[0.9,0.9,0.9]);
  m_grid('box','fancy','tickdir','in');
  
  %m_pcolor(wlon,wlat,nomap(:,:,iperiod,iband));
  
  signif=eval(sprintf('sig.%s(valid,%d)',period,iband));
  sigsun=eval(sprintf('sig.%s([66,88,91],%d)',period,iband));
  if any(sigsun(1)==positive) m_text(-15,latlim(2)-12,'\Delta^{14}C','FontSize',7,'Color','r','HorizontalAlignment','center'); end
  if any(sigsun(1)==negative) m_text(-15,latlim(2)-12,'\Delta^{14}C','FontSize',7,'Color','b','HorizontalAlignment','center');end
  if any(sigsun(2)==positive) m_text(-30,latlim(2)-4,'^{10}Be','FontSize',7,'Color','r','HorizontalAlignment','center');end
  if any(sigsun(2)==negative) m_text(-30,latlim(2)-4,'^{10}Be','FontSize',7,'Color','b','HorizontalAlignment','center');end
  if any(sigsun(3)==positive) m_text(2,latlim(2)-4,'SSN','FontSize',7,'Color','r','HorizontalAlignment','center');end
  if any(sigsun(3)==negative) m_text(2,latlim(2)-4,'SSN','FontSize',7,'Color','b','HorizontalAlignment','center');end
  for isig=negative
    m_line(lon(valid(signif==isig)),lat(valid(signif==isig)) ,'MarkerSize',-(isig-2)*2,'color',[0 0 1],'linestyle','none','Marker','Diamond','MarkerFaceColor','none');
 end
  for isig=positive
    m_line(lon(valid(signif==isig)),lat(valid(signif==isig)),'MarkerSize',(isig-2)*2,'color',[1 0 0],'linestyle','none','Marker','Square','MarkerFaceColor','none');
  end
  
  m_text(-142,-70,fnames(iband),'FontSize',16);
  m_text(-142,-10,pnames(iperiod),'FontSize',16);  

end
end

figure(11); clf reset;
set(gcf,'units','centimeters','Position',[0 0 18.0 22.0]);
set(gcf, 'PaperPositionMode', 'auto', 'PaperOrientation', 'portrait');
m_proj('miller','lat',latlim,'lon',lonlim);
orient 'portrait';
absmax=max(max(max(max(max(abs(wmap(:,:,:,:,positive+2)))))));

for iperiod=1:3 for iband=1:3 
    if iperiod==1 period='low' ;
    elseif iperiod==2 period='upp';
    else period='tot'; end
    %axes('Position',[1-iperiod*.32,(iband-1)*.32,.31,.31]);
    axes('Position',[1-iperiod*.5,(iband-1)*.32,.48,.31]);
    
    m_proj('miller','lat',latlim,'lon',lonlim);
    if any(any(any(wmap(:,:,iperiod,iband,positive+2)))>0)
      m_pcolor(wlon,wlat,max(wmap(:,:,iperiod,iband,positive+2),[],5));
      %m_pcolor(wlon,wlat,max(wmap(:,:,iperiod,iband,positive+2),[],5) ...
      %-max(wmap(:,:,iperiod,iband,negative+2),[],5));
      
      shading('interp');
      colormap(cown);
      caxis([-absmax;absmax]);
    end;
    m_coast;
    m_grid('box','fancy','tickdir','in');
    if (iperiod<3) set(gca,'yticklabel',[]); end
    if (iband>1)   set(gca,'xticklabel',[]); end
    t=m_text(-142,-70,fnames(iband),'FontSize',16,'Background','w');
    m_text(-142,-10,pnames(iperiod),'FontSize',16,'Background','w');  
     signif=eval(sprintf('sig.%s(valid,%d)',period,iband));
    for isig=negative
      m_line(lon(valid(signif==isig)),lat(valid(signif==isig)),'MarkerSize',-(isig-2)*2,'color',[0 0 1],'linestyle','none','Marker','diamond','MarkerFaceColor','none');
    end
    for isig=positive
      m_line(lon(valid(signif==isig)),lat(valid(signif==isig)),'MarkerSize',(isig-2)*2,'color',[1 0 0],'linestyle','none','Marker','square','MarkerFaceColor','none');
    end
  sigsun=eval(sprintf('sig.%s([66,88,91],%d)',period,iband));
  if any(sigsun(1)==positive) m_text(-15,latlim(2)-16,'\Delta^{14}C','FontSize',8,'Color','r','HorizontalAlignment','center'); end
  if any(sigsun(1)==negative) m_text(-15,latlim(2)-16,'\Delta^{14}C','FontSize',8,'Color','b','HorizontalAlignment','center');end
  if any(sigsun(2)==positive) m_text(-30,latlim(2)-6,'^{10}Be','FontSize',8,'Color','r','HorizontalAlignment','center');end
  if any(sigsun(2)==negative) m_text(-30,latlim(2)-6,'^{10}Be','FontSize',8,'Color','b','HorizontalAlignment','center');end
  if any(sigsun(3)==positive) m_text(0,latlim(2)-6,'SSN','FontSize',8,'Color','r','HorizontalAlignment','center');end
  if any(sigsun(3)==negative) m_text(0,latlim(2)-6,'SSN','FontSize',8,'Color','b','HorizontalAlignment','center');end

    %if (iperiod==2 & iband==3) title('Presence of signal in frequency bands'); end;

end; end;

zmap=wmap(:,:,1,1,:)*0;
for iband=1:3 
  wmap(:,:,4,iband,:)=max(wmap(:,:,1,iband,:)-wmap(:,:,3,iband,:),zmap); % low not tot
  wmap(:,:,5,iband,:)=max(wmap(:,:,2,iband,:)-wmap(:,:,3,iband,:),zmap); % upp not tot
  wmap(:,:,6,iband,:)=max(wmap(:,:,1,iband,:)-wmap(:,:,2,iband,:),zmap); % low not upp
  wmap(:,:,7,iband,:)=max(wmap(:,:,2,iband,:)-wmap(:,:,1,iband,:),zmap); % upp not low
end;

figure(12); clf reset;
set(gcf,'units','centimeters','Position',[0 0 18.0 22.0]);
set(gcf, 'PaperPositionMode', 'auto', 'PaperOrientation', 'portrait');
m_proj('miller','lat',latlim,'lon',lonlim);
orient 'portrait';
absmax=max(max(max(max(max(abs(wmap(:,:,4:7,1:3,positive+2)))))));

for iperiod=6:7 for iband=1:3 
  %axes('Position',[.04+(iband-1)*.32,(iperiod-6)*.25,.27,.22]);
  axes('Position',[(iperiod-6)*.50,.04+(iband-1)*.32,.48,.27]);
  
  m_proj('miller','lat',latlim,'lon',lonlim);
  if any(any(wmap(:,:,iperiod,iband,positive+2)>0))
    m_pcolor(wlon,wlat,max(wmap(:,:,iperiod,iband,positive+2),[],5)); 
    %m_pcolor(wlon,wlat,sum(wmap(:,:,iperiod,iband,positive+2),5)); 
    shading('interp');
    colormap(cown);
    caxis([-absmax,absmax]);
 end;
 m_coast;
 m_grid('box','fancy','tickdir','in');
 title(sprintf('%s band %d',pnames{iperiod},iband),'FontSize',16);
 
  
  if (iperiod<7) set(gca,'yticklabel',[]); end
  if (iband>1)   set(gca,'xticklabel',[]); end

end; end;

text(-2.95,2.13,ptitle,'HorizontalAlignment','center','FontSize',16);


for iband=1:3 
  wmap(:,:,4,iband,:)=wmap(:,:,1,iband,:)-wmap(:,:,3,iband,:); % low - tot
  wmap(:,:,5,iband,:)=wmap(:,:,2,iband,:)-wmap(:,:,3,iband,:); % upp - tot
  wmap(:,:,6,iband,:)=wmap(:,:,2,iband,:)-wmap(:,:,1,iband,:); % upp - low
end;

pnames={'Lower','Upper','Total','Low-Total','Upp-total','Upper - Lower'};

figure(13); clf reset;
set(gcf,'units','centimeters','Position',[0 0 18.0 22.0]);
set(gcf, 'PaperPositionMode', 'auto', 'PaperOrientation', 'portrait');
m_proj('miller','lat',latlim,'lon',lonlim);
orient 'portrait';

for iperiod=6:6 for iband=1:3 
  axes('Position',[0.1,.04+(iband-1)*.32,0.8,.24]);
  m_proj('miller','lat',latlim,'lon',lonlim);
  m_pcolor(wlon,wlat,sum(wmap(:,:,iperiod,iband,positive),5)); 
  shading('interp');
  m_coast;
  m_grid('box','fancy','tickdir','in');
  colormap(cown);
  caxis([-absmax,absmax]);
  title(sprintf('%s %s',pnames{iperiod},fnames{iband}),'FontSize',16);
  sunbe=m_line(-30,latlim(2)-6,'Marker','hexagram','MarkerFaceColor','y','MarkerEdgeColor','y','LineWidth',4,'MarkerSize',20);
txtbe=m_text(-30,latlim(2)-6,'^{10}Be','FontSize',8,'Color',[0.5 0.5 0.5],'HorizontalAlignment','center');
if (sig.upp(88,iband)-sig.low(88,iband)> 1) set(txtbe,'Color','r'); end
if (sig.upp(88,iband)-sig.low(88,iband)<-1) set(txtbe,'Color','b'); end
sunbe=m_line(0,latlim(2)-6,'Marker','hexagram','MarkerFaceColor','y','MarkerEdgeColor','y','LineWidth',4,'MarkerSize',20);
txtbe=m_text(0,latlim(2)-6,'SSN','FontSize',8,'Color',[0.5 0.5 0.5],'HorizontalAlignment','center');
if (sig.upp(91,iband)-sig.low(91,iband)> 1) set(txtbe,'Color','r'); end
if (sig.upp(91,iband)-sig.low(91,iband)<-1) set(txtbe,'Color','b'); end
sunbe=m_line(-15,latlim(2)-16,'Marker','hexagram','MarkerFaceColor','y','MarkerEdgeColor','y','LineWidth',4,'MarkerSize',20);
txtbe=m_text(-15,latlim(2)-16,'\Delta^{14}C','FontSize',8,'Color',[0.5 0.5 0.5],'HorizontalAlignment','center');
if (sig.upp(66,iband)-sig.low(66,iband)> 1) set(txtbe,'Color','r'); end
if (sig.upp(66,iband)-sig.low(66,iband)<-1) set(txtbe,'Color','b'); end

end; end;

scenario=sprintf('%d',positive(1));
for i=2:length(positive) scenario=sprintf('%s%d',scenario,positive(i)); end
scenario=sprintf('%s_%d',scenario,negative(1));
for i=2:length(negative) scenario=sprintf('%s%d',scenario,negative(i)); end



for fignum=10:13 
  figure(fignum);  
  plot_multi_format(gcf,fullfile(dirs.setup,['map_band_events_' scenario '_' num2str(fignum) ]));
end;
return;
