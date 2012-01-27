% Run script for hunter-gatherer simulations

timelim=[-9500 2000];
file='../../hg_q0.nc';


clp_nc_trajectory('var','population_density','timelim',[-9500 1000],'file',file,'noprint',1,'reg','all','ylim',[0 1]);
ax=get(gcf,'Children')
set(ax(1),'visible','on','ylim',[0 20])


clp_nc_trajectory('var','population_density','timelim',[-9500 1000],'file','../../eurolbk_events.nc','noprint',1,...
    'reg','all','ylim',[0 1],'figoff',1);
ax=get(gcf,'Children')
set(ax(1),'visible','on','ylim',[0 200])


return

reg='lbk';
noprint=0;

clp_nc_trajectory('var','population_density','timelim',timelim,'file',file,'noprint',noprint,'reg',reg);
clp_nc_trajectory('var','technology','timelim',timelim,'file',file,'noprint',noprint,'reg',reg);
clp_nc_trajectory('var','economies','timelim',timelim,'file',file,'noprint',noprint,'reg',reg);

for ifile=1:length(file)
  gridfile=strrep(file,'.nc','_0.5x0.5.nc');
  if exist(gridfile,'file')
    gdir=dir(gridfile);
    fdir=dir(file);
    if (datenum(fdir.date)<=datenum(gdir.date)) continue; end
  end
  cl_glues2grid('variables',{'population_density','region','technology'},'file',file,'timelim',timelim,'timestep',50);
end