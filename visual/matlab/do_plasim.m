function do_plasim
% DO_PLASIM script creates figures to compare the reference run based on
% Climber/VECODE with Plasim/VECODE npp and gdd, possibly also transient
% climate

rsce='reference';
psce='plasim_base';
rfile=fullfile('../..',[rsce '.nc']);
pfile=fullfile('../..',[psce '.nc']);
timelim=[-9500 -1000];

clp_nc_trajectory('sce',rsce,'nosum',1,'file',rfile,'var','population_density','reg','all','timelim',timelim);
clp_nc_trajectory('sce',psce,'nosum',1,'file',pfile,'var','population_density','reg','all','timelim',timelim);
clp_nc_trajectory('sce',rsce,'nosum',1,'file',rfile,'var','farming','reg','all','timelim',timelim);
clp_nc_trajectory('sce',psce,'nosum',1,'file',pfile,'var','farming','reg','all','timelim',timelim);
clp_nc_variable('sce',rsce,'file',rfile,'var','farming','reg','all','threshold',0.5,'timelim',timelim);
clp_nc_variable('sce',psce,'file',pfile,'var','farming','reg','all','threshold',0.5,'timelim',timelim);

return


clp_nc_trajectory('file',rfile,'var','population_density','reg','all','timelim',timelim);
clp_nc_trajectory('file',rfile,'nosum',1,'var','farming','reg','all','timelim',timelim);
clp_nc_trajectory('file',rfile,'nosum',1,'var','npp','reg','all','timelim',timelim);




%% return to main

return;
end
