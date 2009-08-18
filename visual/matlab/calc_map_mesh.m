function [g,glo,gla]=calc_map_mesh(lon,lat,val,radius,resolution,lonlims,latlims)

cl_register_function();

if ~exist('latlims','var') latlims=[-90 90]; end
if ~exist('lonlims','var') lonlims=[-180 180]; end
if ~exist('resolution','var') resolution=3.0; end
if ~exist('radius','var') radius=3000; end
debug=0;    

if ~exist('val','var')
    debug=1;
    lat=rand(30,1)*180-90;
    lon=rand(30,1)*360-180;
    val=rand(30,1)*16-8;
end

if numel(val)~=numel(lon) | numel(val) ~=numel(lat)
    error('Dimension mismatch');
end

gres=resolution;
gla=[min(latlims):gres:max(latlims)];
glo=[min(lonlims):gres:max(lonlims)];
g = zeros(length(gla),length(glo))+ NaN;
d=val;
n=length(val);
for  isite=1:n
  hdls=m_range_ring(lon(isite),lat(isite),radius,'visible','off');
  lomin=NaN; lomax=NaN; lamin=NaN; lamax=NaN;
  for i=1:length(hdls)
    [lo,la]=m_xy2ll(get(hdls(i),'XData'),get(hdls(i),'ydata'));
    lomin=min([lo,lomin]);lomax=max([lo,lomax]);
    lamin=min([la,lamin]);lamax=max([la,lamax]);
  end
  rl=glo(glo<=lomin);rlo(1)=rl(end);
  rl=glo(glo>=lomax);rlo(2)=rl(1);
  rl=gla(gla<=lamin);rla(1)=rl(end);
  rl=gla(gla>=lamax);rla(2)=rl(1);
  [glon,glat]=meshgrid(rlo(1):gres:rlo(2),rla(1):gres:rla(2));
  ilon=((rlo(1):gres:rlo(2))-glo(1))/gres+1;
  ilat=((rla(1):gres:rla(2))-gla(1))/gres+1;
  [row,col]=size(glon);
  slon=[repmat(lon(isite),row*col,1),reshape(glon,row*col,1)]';
  slat=[repmat(lat(isite),row*col,1),reshape(glat,row*col,1)]';
  dlon=reshape(slon,2*row*col,1);
  dlat=reshape(slat,2*row*col,1);
  dist=m_lldist(dlon,dlat);
  dist(dist>radius)=inf;
  dist=reshape(dist(1:2:row*col*2),row,col);
  rg=g(ilat,ilon);
  ri=find(isnan(rg) & ~isinf(dist));
  rg(ri)=0.0;
  g(ilat,ilon)=rg+d(isite)*(exp(-dist/radius*2));
  %g(ilat,ilon)=rg+d(isite)*(exp(-dist/radius*2)-0*exp(-1))/(1-exp(-1));
  %g(ilat,ilon)=rg+d(isite)*(radius-dist);
  
  %m_pcolor(glo,gla,g);
end

if debug 
    clf reset;
    m_proj('miller');
    m_coast;
    m_pcolor(glo,gla,g); 
    shading interp; 
    m_grid('box','fancy','background','k');
end

end
