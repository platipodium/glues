function plot_iiasa_npp_gdd(varargin)

cl_register_function();

[d,f]=get_files;

if ~exist('regionpath.mat','file')
    fprintf('Required file regionpath.mat not found, please run calc_regionmap_outline.\n');
    return
end

load('regionpath');

regs=find_region_numbers('med');
latlim=[27,55];
lonlim=[-15,42];

if nargin==1
  if all(isletter(varargin{1})) var=varargin{1};
  else regs=varargin{1};
  end
elseif nargin>1
  for iarg=1:2:nargin
    switch lower(varargin{iarg}(1:3))
      case 'reg' 
        regs=varargin{iarg+1};
     case 'lat' 
        latlim=varargin{iarg+1};
      case 'lon' 
        lonlim=varargin{iarg+1};
    end
  end
end

if ~exist('iiasa.mat','file') 
  read_iiasa;
end
iiasa=load('iiasa');

  
lon=iiasa.lon-0.25;
lat=iiasa.lat-0.25;

ivalid=find(lon<lonlim(2) & lon>lonlim(1) & lat<latlim(2) & lat>latlim(1));
if isempty(ivalid) return; end
nvalid=length(ivalid);

lon=lon(ivalid);
lat=lat(ivalid);
dlon=0.5;
dlat=0.5;
dlons=[0 dlon dlon 0];
dlats=[0 0 dlat dlat];
lons=repmat(lon,1,4)+repmat(dlons,nvalid,1);
lats=repmat(lat,1,4)+repmat(dlats,nvalid,1);
lons(find(lons<lonlim(1)))=lonlim(1);
lons(find(lons>lonlim(2)))=lonlim(2);
lats(find(lats>latlim(2)))=latlim(2);
lats(find(lats<latlim(1)))=latlim(1);

prec=iiasa.prec(ivalid,:);
tmean=iiasa.tmean(ivalid,:);

gdd=sum(tmean>0,2)*30.;
prec=sum(prec,2);
tmean=mean(tmean,2);

prec(find(prec<0))=0;
%prec(find(prec>2000))=2000;
prange=2000;
trange=max(tmean)-min(tmean);

[npp,nppp,nppt,lp,lt]=vecode_npp_lieth(tmean,prec);
nmax=max(max(npp));
sensitivity=-lp/trange;
it=find(lt>0);
sensitivity(it)=lt(it)/prange;
sensitivity=sensitivity./max(abs(sensitivity));

ncol=64;
cmap=colormap(rainbow(ncol));
figoff=0;

gcol=round((gdd-0)/360.0*ncol)+1;
npcol=round((npp-0)/nmax*ncol)+1;
scol=round((sensitivity+1)/2.0*ncol)+1;

var.col={gcol,npcol,scol};
var.title={'IIASA number of days above 0°C',
           'IIASA annual NPP according to Lieth (1972, g/m2)'
           'IIASA/Miami model NPP climate sensitivity'};
var.name={'gdd','npp','sensitivity'};
var.range={360,nmax,2};
var.prec={3,3,2};
var.min={0,0,-1};
   
%ivariables=[1,2,3];

for ivar=1:3
  figure(figoff+ivar); 
  clf reset; 
  m_proj('Miller','lon',lonlim,'lat',latlim);
  m_grid;
  hold on;
  cmap=colormap(rainbow(ncol));
  if (nvalid>10000)
  for icol=1:ncol+1
    ireg=find(var.col{ivar}==icol);
    if isempty(ireg) continue; end;
    m_plot(lon(ireg),lat(ireg),'r.','Color',cmap(var.col{ivar}(ireg(1)),:));
  end
  else
    for i=1:nvalid
        m_patch(lons(i,:),lats(i,:),cmap(var.col{ivar}(i),:),'EdgeColor','none');
    end;
  end;
  m_coast;
  title(var.title{ivar});
  set(gcf,'Position',[100 100 1100 550]);
  set(gcf,'PaperPosition',[0 0 30 15]);
  cb=colorbar;
  ytl=str2num(get(cb,'YTickLabel'));
  set(cb,'YTickLabel',num2str(scale_precision(ytl*var.range{ivar}+var.min{ivar},var.prec{ivar})));
  v=get_version;
  cptext=sprintf('%s, created %s by %s (%s)',v.copy,datestr(datenum(v.time),'YYMMDD'),v.file,v.version);
  cp=text(min(get(gca,'Xlim')),min(get(gca,'Ylim')),cptext);
  set(cp,'Color',[0.5 0.5 0.5],'Interpreter','none','VerticalAlignment','bottom');
  plot_multi_format(gcf,fullfile(d.plot,['iiasa_',var.name{ivar}]));
end


  %legend
  
return
end
  
