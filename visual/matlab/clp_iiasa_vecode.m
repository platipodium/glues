function clp_iiasa_vecode(varargin)

cl_register_function;

iiasafile='iiasa.mat';

if ~exist(iiasafile,'file')
    error('Required input file does not exist');
end

iiasa=load(iiasafile);

temp=mean(iiasa.tmean,2);
[gdd,gdd0,gdd5]=clc_gdd(iiasa.tmean);
prec=sum(iiasa.prec,2);
lat=iiasa.lat;
lon=iiasa.lon;
       
%latlim=[-10,70];
latlim=[-60,70];
%lonlim=[-25,80];
lonlim=[-180,180];
ncol=64;

valid=find(lat<latlim(2) & lat>latlim(1) & lon<lonlim(2) & lon>lonlim(1));
nvalid=length(valid);
lat=lat(valid);
lon=lon(valid);
temp=temp(valid);
prec=prec(valid);
gdd=gdd(valid);
gdd0=gdd0(valid);


[production,share,carbon,p]=clc_vecode(temp,prec,gdd0,280);

carbon.total=carbon.soil+carbon.litter+carbon.stem+carbon.leaf;
carbon.above=100*(carbon.stem+carbon.leaf)./carbon.total;

production.npp=production.nppt.*share.forest+production.nppg.*share.grass;

var.val={temp,gdd0,prec,share.forest,share.desert,production.npp,...
    production.lai,carbon.leaf,carbon.stem,carbon.litter,...
    carbon.soil,carbon.total,carbon.above};

nvar=length(var.val);
var.title={'IIASA temperature',
           'IIASA gdd_0'
           'IIASA precipitation',
           'VECODE forest share',
           'VECODE desert share',
           'Lieth NPP',
           'Vecode LAI',
           'Vecode Leaf C',
           'Vecode Stem C',
           'Vecode Litter C',
           'Vecode Soil C',
           'Vecode Total C',
           'Vecode above %'};
var.prec=[3 3 4 3 3 3 3 3 3 3 3 3 3];
var.min=[-25,0,0,0,0,0,0,0,0,0,0,0,0];
var.max=[25,6000,3000,1,1,1300,4,0.2,200,120,120,300,50];
var.name={'atemp','gdd0','aprec','fshare','dshare','npp','lai','leafcarbon',...
    'stemcarbon','littercarbon','soilcarbon','totalcarbon','abovefraction'}

for ivar=1:nvar
    val=var.val{ivar};
    var.range(ivar)=var.max(ivar)-var.min(ivar);
    val(find(val>var.max(ivar)))=var.max(ivar);
    val(find(val<var.min(ivar)))=var.min(ivar);
    var.col{ivar}=round((var.val{ivar}-var.min(ivar))/var.range(ivar)*(ncol))+1;
    var.col{ivar}(var.col{ivar}>ncol)=ncol;
    var.col{ivar}(var.col{ivar}<1)=1;
end

cmap=colormap(rainbow(ncol));

for ivar=1:nvar
  figure(ivar); clf reset; 
  m_proj('equidistant','lat',latlim,'lon',lonlim);  
  m_coast;
  hold on;
  m_grid;
  colormap(rainbow(ncol));

  if (nvalid>1)
    for icol=1:ncol+1
      ireg=find(var.col{ivar}==icol);
      if isempty(ireg) continue; end;
      m_plot(lon(ireg),lat(ireg),'r.','Color',cmap(var.col{ivar}(ireg(1)),:));
    end
  end
  
  title(var.title{ivar});
  
  d.plot='../plots'
  
  set(gcf,'Position',[100 100 1100 550]);
  set(gcf,'PaperPosition',[0 0 30 15]);
  cb=colorbar;
  ytl=str2num(get(cb,'YTickLabel'));
  set(cb,'YTickLabel',num2str(scale_precision(ytl*var.range(ivar)+var.min(ivar),var.prec(ivar))));
  v=cl_get_version;
  stamptext=sprintf('%s, created by %s (%s)',v.copy,v.file,v.version);
  stamp=text(min(get(gca,'Xlim')),min(get(gca,'Ylim')),stamptext);
  set(stamp,'Color',repmat(0.5,1,3),'Interpreter','none','VerticalAlignment','bottom');
  clp_stamp;
  plot_multi_format(gcf,fullfile(d.plot,['iiasa_vecode_',var.name{ivar}]));

   
end

return;
end