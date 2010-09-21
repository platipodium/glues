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
       
latlim=[-10,70];%[-60,70];
lonlim=[-25,80];%[-150,150];
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
var.max=[25,11000,3000,1,1,1500,4,0.2,200,200,200,500,100];

for ivar=1:nvar
    val=var.val{ivar};
    var.range(ivar)=var.max(ivar)-var.min(ivar);
    val(find(val>var.max(ivar)))=var.max(ivar);
    val(find(val<var.min(ivar)))=var.min(ivar);
    var.col{ivar}=round((var.val{ivar}-var.min(ivar))/var.range(ivar)*ncol)+1;
end

cmap=colormap(rainbow(ncol));

for ivar=15:nvar
  figure(ivar); clf reset; 
  m_proj('equidistant','lat',latlim,'lon',lonlim);  
  m_coast;
  hold on;
  m_grid;

  if (nvalid>1)
    for icol=1:ncol+1
      ireg=find(var.col{ivar}==icol);
      if isempty(ireg) continue; end;
      m_plot(lon(ireg),lat(ireg),'r.','Color',cmap(var.col{ivar}(ireg(1)),:));
    end
  end
  
  title(var.title{ivar});
  
  set(gcf,'Position',[100 100 1100 550]);
  set(gcf,'PaperPosition',[0 0 30 15]);
  cb=colorbar;
  ytl=str2num(get(cb,'YTickLabel'));
  set(cb,'YTickLabel',num2str(scale_precision(ytl*var.range(ivar)+var.min(ivar),var.prec(ivar))));
  %v=cl_get_version;
  %cptext=sprintf('%s, created %s by %s (%s)',v.copy,datestr(datenum(v.time),'YYMMDD'),v.file,v.version);
  %cp=text(min(get(gca,'Xlim')),min(get(gca,'Ylim')),cptext);
  %set(cp,'Color',[0.5 0.5 0.5],'Interpreter','none','VerticalAlignment','bottom');
  %plot_multi_format(gcf,fullfile(d.plot,['iiasa_',var.name{ivar}]));

   
end

return;
end