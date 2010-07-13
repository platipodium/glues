% Skript to produce the figures for the american antiquity paper presented
% at saa

% Figure 7 histogram of timing
% clp_woodland_histogram;





%% Figure 6 nospread trajectories

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



% Figure 1 timing map (global)
% clp_map_timing('latlim',[-40 65],'lonlim',[-135 150],'timelim',[-7000 1491],'ncol',5);

return

%* World map
clp_map_variable('var','Density','timelim',3000,'latlim',[-50 75],'ylim',[0 6],'lonlim',[-140 150]);
clp_map_variable('var','Density','timelim',1000,'latlim',[-50 75],'ylim',[0 6],'lonlim',[-140 -40]);

return

%clp_nc_trajectory('latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491],'var','technology','nosum',1,'lim',[1 12]);
%clp_nc_trajectory('latlim',[40 55],'lonlim',[-10 30],'timelim',[-8000 -1000],'var','technology','nosum',1,'lim',[1 12]);

return

clp_nc_trajectory('sce','nospread','latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491],'var','population_density','lim',[0 5]);
clp_nc_trajectory('sce','nospread','latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491],'var','farming','nosum',1,'lim',[0 1]);
clp_nc_trajectory('sce','nospread','latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491],'var','technology','nosum',1,'lim',[1 12]);
clp_nc_trajectory('sce','nospread','latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491],'var','economies','nosum',1,'lim',[0 7]);

clp_nc_trajectory('sce','nospread','latlim',[40 55],'lonlim',[-10 30],'timelim',[-8000 -1000],'var','population_density','lim',[0 5]);
clp_nc_trajectory('sce','nospread','latlim',[40 55],'lonlim',[-10 30],'timelim',[-8000 -1000],'var','farming','nosum',1,'lim',[0 1]);
clp_nc_trajectory('sce','nospread','latlim',[40 55],'lonlim',[-10 30],'timelim',[-8000 -1000],'var','technology','nosum',1,'lim',[1 12]);
clp_nc_trajectory('sce','nospread','latlim',[40 55],'lonlim',[-10 30],'timelim',[-8000 -1000],'var','economies','nosum',1,'lim',[0 7]);

% Timing maps world, Europe, US
clp_map_timing('timelim',[12000 500],'variable','Farming','latlim',[-50 75],'lonlim',[-140 150]);

return

%* World map
clp_map_variable('var','Farming','timelim',3000,'latlim',[-50 75],'ylim',[0 1],'lonlim',[-140 150]);
clp_map_variable('var','Farming','timelim',1000,'latlim',[-50 75],'ylim',[0 1],'lonlim',[-140 150]);

%* World map
clp_map_variable('var','Density','timelim',3000,'latlim',[-50 75],'ylim',[0 6],'lonlim',[-140 150]);


% Europe maps
clp_map_variable('var','Density','timelim',3000,'latlim',[30 60],'lonlim',[-15 45],'ylim',[0 6]);
eutime=[10000 8000 7000 6000 5500 5000 4500 4000];
for i=1:length(eutime)
  clp_map_variable('var','Density','timelim',eutime(i),'latlim',[30 60],'lonlim',[-15 45],'ylim',[0 6],'nocbar',1);
end

% US maps
clp_map_variable('var','Density','timelim',1000,'latlim',[16 48],'lonlim',[-126 -68],'ylim',[0 1]);
ustime=[6000 5000 4500 4000 3500 3000 2500 2000 1500];
for i=1:length(ustime)
  clp_map_variable('var','Density','timelim',ustime(i),'latlim',[16 48],'lonlim',[-126 -68],'ylim',[0 1],'nocbar',1);
end
