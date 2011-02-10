% Run script to produce the figures for the american antiquity paper presented
% Carsten Lemmen
% 2011-02-09

% Figures in this paper
% 1. world_timing_map
% 2. world density map for different scenarios
% 3. Europe density maps
% 4. NAM density maps
% 5. base trajectories
% 6. nospread trajectories
% 7. woodland historgram

% select which figures to plot
doplot=[7];






%% Figure US timing maps
if any(4==4)
  [d,b]=clp_nc_variable('var','farming','timelim',[-3000,1490],'latlim',[24 48],'lonlim',[-112 -68],...
     'marble',0,'transpar',0,...
    'nogrid',1,'threshold',0.5,'file','../../amant_base.nc','flip',1);
  [d,b]=clp_nc_variable('var','gdd','timelim',[-3000],'latlim',[24 48],'lonlim',[-112 -68],...
     'marble',0,'transpar',0,...
    'nogrid',1,'file','../../amant_base.nc','flip',1);
  [d,b]=clp_nc_variable('var','npp','timelim',[-3000],'latlim',[24 48],'lonlim',[-112 -68],...
     'marble',0,'transpar',0,...
    'nogrid',1,'file','../../amant_base.nc','flip',1);
  [d,b]=clp_nc_variable('var','temperature_limitation','timelim',[-3000,1490],'latlim',[24 48],'lonlim',[-112 -68],...
     'marble',0,'transpar',0,...
    'nogrid',1,'file','../../amant_base.nc','flip',1);
%   [d,b]=clp_nc_variable('var','farming','timelim',[-3000,1490],'latlim',[16 48],'lonlim',[-126 -68],...
%     'nogrid',1,'threshold',0.5,'file','../../amant_nofluc.nc','flip',1,'fig',2);
%   [d,b]=clp_nc_variable('var','farming','timelim',[-3000,1490],'latlim',[16 48],'lonlim',[-126 -68],...
%     'nogrid',1,'threshold',0.5,'file','../../amant_nospread.nc','flip',1,'fig',3);
%   [d,b]=clp_nc_variable('var','farming','timelim',[-3000,1490],'reg','nam',...
%     'nogrid',1,'threshold',0.5,'file','../../amant_nospread.nc','flip',1,'fig',1);
%   [d,b]=clp_nc_variable('var','farming','timelim',[-3000,1490],'latlim',[15 80],'lonlim',[-170 -50],...
%     'nogrid',1,'threshold',0.5,'file','../../amant_nospread.nc','flip',1,'fig',4);
   ax=get(gcf,'Children');
   axes(ax(2));
   [d,n,e]=fileparts(b);
end



return

%% Figure 1 World timing map
if any(doplot==1)
  [d,b]=clp_nc_variable('var','farming','timelim',[-7000,1490],'latlim',[-50 75],'lonlim',[-140 150],...
    'nogrid',1,'threshold',0.5,'file','../../amant_base.nc','flip',1);
  [d,b]=clp_nc_variable('var','farming','timelim',[-7000,1490],'reg','all',...
    'nogrid',1,'threshold',0.5,'file','../../amant_base.nc','flip',1);
  ax=get(gcf,'Children');
  axes(ax(2));
  yt=get(gca,'YTick');
  ytl=str2num(get(gca,'YTickLabel'));
  yt=0:1.0/6.0:1.0
  ytl=yt.*(ytl(3)-ytl(1))+ytl(1);
  set(gca,'YTick',yt,'YTickLabel',num2str(ytl'));
  [d,n,e]=fileparts(b);
  plot_multi_format(gcf,fullfile(d,['lemmen_fig1_color']));
end

%% Figure 2 World density maps at 1000 BC for different scenarios
if any(doplot==2)
[d,b]=clp_nc_variable('var','population_density','timelim',-1000,'latlim',[-50 75],'lonlim',[-140 150],...
    'lim',[0 6],'nogrid',1,'file','../../amant_base.nc');
ax=get(gcf,'Children');
axes(ax(1));
yt=get(gca,'YTick');
ytl=str2num(get(gca,'YTickLabel'));
yt=0:1.0/6.0:1.0
ytl=yt.*ytl(3);
set(gca,'YTick',yt,'YTickLabel',num2str(ytl'));
axes(ax(2));
text(2.48,01.26,'Reference','Vertical','top','Horizontal','right',...
      'FontSize',13,'FontWeight','bold','background','w');
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,['lemmen_fig2a_color']));

[d,b]=clp_nc_variable('var','population_density','timelim',-1000,'latlim',[-50 75],'lonlim',[-140 150],...
    'lim',[0 6],'nogrid',1,'file','../../amant_tropical.nc');
ax=get(gcf,'Children');
axes(ax(1));
yt=get(gca,'YTick');
ytl=str2num(get(gca,'YTickLabel'));
yt=0:1.0/6.0:1.0
ytl=yt.*ytl(3);
set(gca,'YTick',yt,'YTickLabel',num2str(ytl'));
axes(ax(2));
text(2.48,01.26,'No seasons','Vertical','top','Horizontal','right',...
      'FontSize',13,'FontWeight','bold','background','w');
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,['lemmen_fig2b_color']));

[d,b]=clp_nc_variable('var','population_density','timelim',-1000,'latlim',[-50 75],'lonlim',[-140 150],...
    'lim',[0 6],'nogrid',1,'file','../../amant_subpolar.nc');
ax=get(gcf,'Children');
axes(ax(1));
yt=get(gca,'YTick');
ytl=str2num(get(gca,'YTickLabel'));
yt=0:1.0/6.0:1.0
ytl=yt.*ytl(3);
set(gca,'YTick',yt,'YTickLabel',num2str(ytl'));
axes(ax(2));
text(2.48,01.26,'Too seasonal','Vertical','top','Horizontal','right',...
      'FontSize',13,'FontWeight','bold','background','w');
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,['lemmen_fig2c_color']));
end
   

%% Figure 3 Europe density maps
if any(doplot==3)
  eutime=[10000 8000 7000 6000 5500 5000 4500 4000];
  euletter='abcdef';
  eutime=[-8000 -6000 -5000 -4000 -3000 -1000];
  for i=1:length(eutime)
    [d,b]=clp_nc_variable('var','population_density','timelim',eutime(i),'latlim',[30 60],'lonlim',[-15 45],'lim',[0 6],'nogrid',1);
    ax=get(gcf,'Children');
    axes(ax(2));
    bcad='BC';
    text(0.5,01.46,sprintf('%d %s',abs(eutime(i)),bcad),'Vertical','top','Horizontal','right',...
      'FontSize',13,'FontWeight','bold','background','w');
    [d,n,e]=fileparts(b);
    plot_multi_format(gcf,fullfile(d,['lemmen_fig3' euletter(i) '_color']));
  end
end

%% Figure 4 US density maps
if any(doplot==4)
  ustime=[-3000 -2000 -1000 0 500 1000];
  usletter='abcdef';
  for i=1:length(ustime)
    [d,b]=clp_nc_variable('var','population_density','timelim',ustime(i),'latlim',[16 48],'lonlim',[-126 -68],'lim',[0 2],'nogrid',1);
    ax=get(gcf,'Children');
    axes(ax(2));
    if ustime(i)==0 ustime(i)=1; end
    if ustime(i)<0 bcad='BC'; else bcad='AD'; end
    text(0.49,0.975,sprintf('%d %s',abs(ustime(i)),bcad),'Vertical','top','Horizontal','right',...
      'FontSize',13,'FontWeight','bold','background','w');
    [d,n,e]=fileparts(b);
    plot_multi_format(gcf,fullfile(d,['lemmen_fig4' usletter(i) '_color']));
  end
end



if any(doplot==5)
% Figure 5 trajectories in Europe and NAM
[d,b]=clp_nc_trajectory('latlim',[40 55],'lonlim',[-10 30],'timelim',[-8000 -1000],'var','population_density','lim',[0 5],'nocolor',1,'file','../../amant_base.nc');
ax=get(gcf,'Children');
ylabel(ax(2),'Population density (km^{-2})');
ylabel(ax(1),'Population size (million)');
xtl=get(ax(2),'XTickLabel');
xtl([1 8],:)=' ';
set(ax(2),'XTickLabel',xtl);
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,'lemmen_fig5a_gray'));

[d,b]=clp_nc_trajectory('latlim',[40 55],'lonlim',[-10 30],'timelim',[-8000 -1000],'var','population_density','lim',[0 5]);
ax=get(gcf,'Children');
ylabel(ax(2),'Population density (km^{-2})');
ylabel(ax(1),'Population size (million)');
xtl=get(ax(2),'XTickLabel');
xtl([1 8],:)=' ';
set(ax(2),'XTickLabel',xtl);
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,'lemmen_fig5a_color'));


%%

[d,b]=clp_nc_trajectory('latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491],'var','population_density','lim',[0 5],'nocolor',1);
ax=get(gcf,'Children');
ylabel(ax(2),'Population density (km^{-2})');
ylabel(ax(1),'Population size (million)');
xtl=get(ax(2),'XTickLabel');
xtl([1],:)=' ';
set(ax(2),'XTickLabel',xtl);
leg=legend(ax(2),'Local density','Mean density','Total size')
legc=get(leg,'Children');
set(legc([2 5]),'Linewidth',5);
set(legc([8]),'Linewidth',1.5);
set(legc(2),'LineStyle','--');
set(legc(8),'Color',repmat(0.3,3,1));
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,'lemmen_fig5d_gray'));
%%
[d,b]=clp_nc_trajectory('latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491],'var','population_density','lim',[0 5]);
ax=get(gcf,'Children');
ylabel(ax(2),'Population density (km^{-2})');
ylabel(ax(1),'Population size (million)');
xtl=get(ax(2),'XTickLabel');
xtl([1],:)=' ';
set(ax(2),'XTickLabel',xtl);
leg=legend(ax(2),'Local density','Mean density','Total size')
legc=get(leg,'Children');
set(legc([2 5]),'Linewidth',5);
set(legc([8]),'Linewidth',2);
set(legc(2),'LineStyle','--','Color','r');
set(legc(5),'Color','b');
set(legc(8),'Color','c');
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,'lemmen_fig5d_color'));



%%
[d,b]=clp_nc_trajectory('latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491],'var','economies','nosum',1,'lim',[0 7],'nocolor',1);
ax=get(gcf,'Children');
ylabel(ax(1),'Diversity');
xtl=get(ax(1),'XTickLabel');
xtl([1],:)=' ';
set(ax(1),'XTickLabel',xtl);
ytl=get(ax(1),'YTickLabel');
ytl([1 8],:)=' ';
set(ax(1),'YTickLabel',ytl);
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,'lemmen_fig5e_gray'));

[d,b]=clp_nc_trajectory('latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491],'var','economies','nosum',1,'lim',[0 7]);
ax=get(gcf,'Children');
ylabel(ax(1),'Diversity');
xtl=get(ax(1),'XTickLabel');
xtl([1],:)=' ';
set(ax(1),'XTickLabel',xtl);
ytl=get(ax(1),'YTickLabel');
ytl([1 8],:)=' ';
set(ax(1),'YTickLabel',ytl);
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,'lemmen_fig5e_color'));

[d,b]=clp_nc_trajectory('latlim',[40 55],'lonlim',[-10 30],'timelim',[-8000 -1000],'var','economies','nosum',1,'lim',[0 7],'nocolor',1);
ax=get(gcf,'Children');
ylabel(ax(1),'Diversity');
xtl=get(ax(1),'XTickLabel');
xtl([1 8],:)=' ';
set(ax(1),'XTickLabel',xtl);
ytl=get(ax(1),'YTickLabel');
ytl([1 8],:)=' ';
set(ax(1),'YTickLabel',ytl);
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,'lemmen_fig5b_gray'));

[d,b]=clp_nc_trajectory('latlim',[40 55],'lonlim',[-10 30],'timelim',[-8000 -1000],'var','economies','nosum',1,'lim',[0 7]);
ax=get(gcf,'Children');
ylabel(ax(1),'Diversity');
xtl=get(ax(1),'XTickLabel');
xtl([1 8],:)=' ';
set(ax(1),'XTickLabel',xtl);
ytl=get(ax(1),'YTickLabel');
ytl([1 8],:)=' ';
set(ax(1),'YTickLabel',ytl);
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,'lemmen_fig5b_color'));

%%
[d,b]=clp_nc_trajectory('latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491],'var','farming','nosum',1,'lim',[0 102],'mult',100,'nocolor',1);
ax=get(gcf,'Children');
ylabel(ax(1),'Fraction (%)');
xtl=get(ax(1),'XTickLabel');
xtl([1],:)=' ';
set(ax(1),'XTickLabel',xtl);
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,'lemmen_fig5f_gray'));

[d,b]=clp_nc_trajectory('latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491],'var','farming','nosum',1,'lim',[0 102],'mult',100);
ax=get(gcf,'Children');
ylabel(ax(1),'Fraction (%)');
xtl=get(ax(1),'XTickLabel');
xtl([1],:)=' ';
set(ax(1),'XTickLabel',xtl);
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,'lemmen_fig5f_color'));

%%
[d,b]=clp_nc_trajectory('latlim',[40 55],'lonlim',[-10 30],'timelim',[-8000 -1000],'var','farming','nosum',1,'lim',[0 102],'mult',100,'nocolor',1);
ax=get(gcf,'Children');
ylabel(ax(1),'Fraction (%)');
xtl=get(ax(1),'XTickLabel');
xtl([1 8],:)=' ';
set(ax(1),'XTickLabel',xtl);
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,'lemmen_fig5c_gray'));

[d,b]=clp_nc_trajectory('latlim',[40 55],'lonlim',[-10 30],'timelim',[-8000 -1000],'var','farming','nosum',1,'lim',[0 102],'mult',100);
ax=get(gcf,'Children');
ylabel(ax(1),'Fraction (%)');
xtl=get(ax(1),'XTickLabel');
xtl([1 8],:)=' ';
set(ax(1),'XTickLabel',xtl);
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,'lemmen_fig5c_color'));
end


%% Figure 6 nospread trajectories
if any(doplot==6)
[d,b]=clp_nc_trajectory('latlim',[40 55],'lonlim',[-10 30],'timelim',[-8000 -1000],'var','economies','nosum',1,'lim',[0 7],'nocolor',1,'file','../../amant_nospread.nc');
ax=get(gcf,'Children');
ylabel(ax(1),'Diversity');
xtl=get(ax(1),'XTickLabel');
xtl([1 8],:)=' ';
set(ax(1),'XTickLabel',xtl);
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,'lemmen_fig6a_gray'));

[d,b]=clp_nc_trajectory('latlim',[40 55],'lonlim',[-10 30],'timelim',[-8000 -1000],'var','economies','nosum',1,'lim',[0 7],'file','../../amant_nospread.nc');
ax=get(gcf,'Children');
ylabel(ax(1),'Diversity');
xtl=get(ax(1),'XTickLabel');
xtl([1 8],:)=' ';
set(ax(1),'XTickLabel',xtl);
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,'lemmen_fig6a_color'));

%%
[d,b]=clp_nc_trajectory('latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491],'var','economies','nosum',1,'lim',[0 7],'nocolor',1,'file','../../amant_nospread.nc');
ax=get(gcf,'Children');
ylabel(ax(1),'Diversity');
xtl=get(ax(1),'XTickLabel');
xtl([1],:)=' ';
set(ax(1),'XTickLabel',xtl);
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,'lemmen_fig6b_gray'));

[d,b]=clp_nc_trajectory('latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491],'var','economies','nosum',1,'lim',[0 7],'file','../../amant_nospread.nc');
ax=get(gcf,'Children');
ylabel(ax(1),'Diversity');
xtl=get(ax(1),'XTickLabel');
xtl([1],:)=' ';
set(ax(1),'XTickLabel',xtl);
[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,'lemmen_fig6b_color'));
end

%% Figure 7 histogram of timing
if any(doplot==7)
%   [d,b]=clp_woodland_histogram('nocolor',1);
%   [d,n,e]=fileparts(b);
%   plot_multi_format(gcf,fullfile(d,'lemmen_fig7_gray'));

  [d,b]=clp_woodland_histogram('file','../../amant_nospread.nc','sce','nospread','fig',2);
  [d,b]=clp_woodland_histogram('file','../../amant_nofluc.nc','sce','nofluc','fig',1);
  [d,b]=clp_woodland_histogram('file','../../amant_base.nc','sce','base','fig',0);
  [d,n,e]=fileparts(b);
  plot_multi_format(gcf,fullfile(d,'lemmen_fig7_color'));
end

return

