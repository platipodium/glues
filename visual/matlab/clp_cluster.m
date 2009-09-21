function clp_cluster(varargin)
%CLP_CLUSTER plots diagnostic information on cluster 
%  CLP_CLUSTER display three plots based on a clustering obtained 
%  with CL_CALC_CLUSTER
%
% SEE also CL_CALC_CLUSTER

cl_register_function();

[d,f]=get_files;

colors='rgbcym';

clusterfile='cluster_-65_085_-180_0180_0100_0200_01017.mat';

[tok,rem]=strtok(clusterfile,'_');
[tok,rem]=strtok(rem,'_'),latlim(1)=str2num(tok);
[tok,rem]=strtok(rem,'_'),latlim(2)=str2num(tok);
[tok,rem]=strtok(rem,'_'),lonlim(1)=str2num(tok);
[tok,rem]=strtok(rem,'_'),lonlim(2)=str2num(tok);

% Europe:
latlim=[30,56];
lonlim=[-5,35];

load(clusterfile);
lon=cluster.lon;
lat=cluster.lat;
nc=cluster.nc;
cid=cluster.cid;
clon=cluster.clon;
clat=cluster.clat;
itop=cluster.itop;
ileft=cluster.ileft;
idone=cluster.idone;
val=cluster.val;

figure(1);
clf reset;
set(gcf,'DoubleBuffer','on');
m_proj('miller','lat',latlim,'lon',lonlim);
m_coast;
m_grid;
hold on;
ucid=unique(cid);
for i=1:nc
  ic=find(cid==ucid(i));
  m_plot(lon(ic),lat(ic),'kd','color',colors(mod(i,6)+1),'MarkerFaceColor',colors(mod(i,6)+1));
  icil=find(cid(ileft)==ucid(i));
  pl=m_plot(lon(ileft(icil)),lat(ileft(icil)),'kd','MarkerFaceColor',colors(mod(i,6)+1));
end;
  
set(gcf,'Position',[100 100 1100 550]);
set(gcf,'PaperPosition',[0 0 30 15]);
plot_multi_format(gcf,'../plots/calc_cluster_regions');

figure(2);

clf reset;
set(gcf,'DoubleBuffer','on');
m_proj('miller','lat',latlim,'lon',lonlim);
pk=m_plot(lon,lat,'k.');
m_coast;
m_grid;
hold on;
pc=m_plot(clon,clat,'ko','color',[0.5 0.5 0.5]);
pl=m_plot(lon(ileft),lat(ileft),'rd','MarkerSize',3);
pd=m_plot(lon(idone),lat(idone),'kd','MarkerSize',3);
pt=m_plot(lon(itop),lat(itop),'ys','MarkerSize',5);
set(gcf,'Position',[100 100 1100 550]);
set(gcf,'PaperPosition',[0 0 30 15]);
plot_multi_format(gcf,'../plots/calc_cluster_diagnostic');

figure(3);
clf reset;
set(gcf,'DoubleBuffer','on');
m_proj('miller','lat',latlim,'lon',lonlim);
pk=m_plot(lon,lat,'k.');
m_coast;
m_grid;
hold on;
cmap=colormap(rainbow(64));

for i=1:nc
  ic=find(cid==ucid(i))
  mlon(i)=mean(lon(ic));
  mlat(i)=mean(lat(ic));
  mval(i)=mean(val(ic));
end

maxval=max(mval); minval=min(mval);
vcol=round((val-minval)/(maxval-minval)*64)+1

for i=1:nc
  ic=find(cid==ucid(i))
  m_plot(lon(ic),lat(ic),'kd','color',cmap(vcol(i),:),'MarkerFaceColor',cmap(vcol(i),:));
end;

pc=m_plot(mlon,mlat,'ko','color',[0.5 0.5 0.5]);
set(gcf,'Position',[100 100 1100 550]);
set(gcf,'PaperPosition',[0 0 30 15]);
cb=colorbar;
ytl=str2num(get(cb,'YTickLabel'));
set(cb,'YTickLabel',num2str(ytl*(maxval-minval)+minval));

plot_multi_format(gcf,[fullfile(d.plot,'calc_cluster_val')]);
return
end
