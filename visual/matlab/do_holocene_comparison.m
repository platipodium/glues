function do_holocene_comparison
%% Compare to figures in Kaplan 2010 et al, The Holocen
% extract data from results file
file='../../test.nc';
ncid=netcdf.open(file,'NOWRITE');
varid=netcdf.inqVarID(ncid,'cropfraction');
cropfraction=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'area');
area=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'time');
time=netcdf.getVar(ncid,varid);
netcdf.close(ncid);

% Carbon is calculated as t/ha
ntime=length(time);
fshare=repmat(climate.fshare',1,ntime);
gshare=repmat(climate.gshare',1,ntime);
b12f=repmat(climate.b12f',1,ntime);
b12g=repmat(climate.b12g',1,ntime);
b34f=repmat(climate.b34f',1,ntime);
b34g=repmat(climate.b34g',1,ntime);
naturalcarbon=b12f.*fshare+b12g.*gshare ...
    +b34f.*fshare+b34g.*gshare;
remainingcarbon=b12f.*(fshare-cropfraction) ...
    +b12g.*(gshare+cropfraction) ...
    +b34f.*(fshare-cropfraction)...
    +0.58*b34f.*cropfraction...
    +b34g.*gshare;

% Scale emissions with factor 100 to make it t/km2 * km2
emission=(sum((naturalcarbon-remainingcarbon).*repmat(area,1,ntime)))*100.0/0.8;


%% Per capita ALCC (ha/capita) 
timelim=[-6050 1850];
itime=find(time>=timelim(1) & time<=timelim(2));
data=clp_nc_trajectory('lim',[0 0.1],'nosum',1,'var','cropfraction','reg','all','div','population_density','timelim',timelim);
ieur=find_region_numbers('eur');
ichi=find_region_numbers('chi');
icam=find_region_numbers('cam');
ntime=size(data,2);

figure(1); clf reset;
plot(time(itime),sum(data(ichi,:).*repmat(area(ichi),1,ntime))*100.0/sum(area(ichi)),'y--');
hold on;
plot(time(itime),sum(data(ieur,:).*repmat(area(ieur),1,ntime))*100.0/sum(area(ieur)),'g--');
plot(time(itime),sum(data(icam,:).*repmat(area(icam),1,ntime))*100.0/sum(area(icam))),'b--';

set(gca,'XLim',timelim,'Ylim',[0 10]);
%%
return

%% Originating variables (for China only)
clp_nc_trajectory('var','population_density','reg','chi','timelim',[-9000 -1000]);
clp_nc_trajectory('nosum',1,'var','technology','reg','chi','timelim',[-9000 -1000]);
clp_nc_trajectory('nosum',1,'var','subsistence_intensity','reg','chi','timelim',[-9000 -1000]);

%% Total land use
% extensive land use is impact per productivity
% ncap2 -A -s 'landuse[time,region]=population_density[time,region]*sqrt(technology)/subsistence_intensity;' test.nc test2.nc

lim=[0,1];
clp_nc_trajectory('lim',lim,'nosum',1,'var','landuse','reg','all','timelim',[-9000 -1000],'fig',5);

%% Per capita land use
% landuse divided by population_density
lim=[0,2];
clp_nc_trajectory('lim',lim,'nosum',1,'var','landuse','reg','eur','div','population_density','timelim',[-9000 -1000],'fig',1);
clp_nc_trajectory('lim',lim,'nosum',1,'var','landuse','reg','nam','div','population_density','timelim',[-9000 -1000],'fig',2);
clp_nc_trajectory('lim',lim,'nosum',1,'var','landuse','reg','chi','div','population_density','timelim',[-9000 -1000],'fig',3);
clp_nc_trajectory('lim',lim,'nosum',1,'var','landuse','reg','all','div','population_density','timelim',[-9000 -1000],'fig',4);



return
end