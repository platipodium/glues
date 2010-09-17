function clp_topography(varargin)

cl_register_function;

arguments = {...
  {'latlim',[-inf inf]},...
  {'lonlim',[-inf inf]},...
};

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

lali=[-60, 80];
iinf=isinf(latlim);
latlim(iinf)=lali(iinf);
loli=[-180,180];
iinf=isinf(lonlim);
lonlim(iinf)=loli(iinf);

nyt=max([10,round((latlim(2)-latlim(1))/4)]);
nxt=max([10,round((lonlim(2)-lonlim(1))/10)]);
cont=[0,10,50,100,200,300,500,750,1000,1500,2000,2500,3000,3500,4000,4500,5000,5500,6000,6500,7000,7500,8000,8500];
ncont=length(cont);

figure(1);
clf reset;
if lonlim(1)==-180
  set(gcf,'PaperType','A3');
  set(gcf,'PaperOrientation','Landscape');
  set(gcf,'PaperPosition',[0 0 get(gcf,'PaperSize')]);
  set(gcf,'PaperPositionMode','auto');
  set(gcf,'Position',[0 0 40*get(gcf,'PaperSize')]);
end

m_proj('equidistant','lat',latlim,'lon',lonlim);
%m_coast('patch',[1 .80 .7]);
m_grid('box','fancy','tickdir','in','ytick',nyt,'xtick',nxt,'linestyle','-','fontsize',7);
m_tbase('contourf',cont,'LineWidth',0.1);
colormap(flipud(copper(ncont)));
m_gshhs('ic','color','black','linewidth',0.3,'linestyle','-','tag','coastline'); % plot coastline in high resolution
m_gshhs('ib','color','red','linewidth',0.2,'linestyle','-','tag','border'); % plot boundaries in high resolution
m_gshhs('ir','color','blue','linewidth',0.1,'tag','river'); % plot rivers in high resolution

plot_multi_format(1,'topography');

return;
end
