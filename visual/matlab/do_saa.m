% Skript to produce the figures for the article at SAA 2010

clp_woodland_histogram;

%clp_map_timing('latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491]);

return

%* World map
clp_map_variable('var','Density','timelim',3000,'latlim',[-50 75],'ylim',[0 6],'lonlim',[-140 150]);
clp_map_variable('var','Density','timelim',1000,'latlim',[-50 75],'ylim',[0 6],'lonlim',[-140 -40]);

return

% Trajetories for US and Europe

clp_nc_trajectory('latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491],'var','population_density','lim',[0 5]);
clp_nc_trajectory('latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491],'var','farming','nosum',1,'lim',[0 1]);
clp_nc_trajectory('latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491],'var','technology','nosum',1,'lim',[1 12]);
clp_nc_trajectory('latlim',[30 50],'lonlim',[-108 -60],'timelim',[-5000 1491],'var','economies','nosum',1,'lim',[0 7]);

clp_nc_trajectory('latlim',[40 55],'lonlim',[-10 30],'timelim',[-8000 -1000],'var','population_density','lim',[0 5]);
clp_nc_trajectory('latlim',[40 55],'lonlim',[-10 30],'timelim',[-8000 -1000],'var','farming','nosum',1,'lim',[0 1]);
clp_nc_trajectory('latlim',[40 55],'lonlim',[-10 30],'timelim',[-8000 -1000],'var','technology','nosum',1,'lim',[1 12]);
clp_nc_trajectory('latlim',[40 55],'lonlim',[-10 30],'timelim',[-8000 -1000],'var','economies','nosum',1,'lim',[0 7]);

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
