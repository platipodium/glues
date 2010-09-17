function do_landuse
%% Landuse definition
%
%

file='../../landuse_fluc04.nc';
scenario='fluc04';
timelim=[-5500 -2000];
reg=143;

%% Originating variables (for China only)
clp_nc_trajectory('file',file,'scenario',scenario,'var','population_density','reg',reg,'timelim',timelim);
%clp_nc_trajectory('file',file,'scenario',scenario,'var','economies','reg',reg,'timelim',timelim);
clp_nc_trajectory('file',file,'scenario',scenario,'var','subsistence_intensity','reg',reg,'timelim',timelim);
%clp_nc_trajectory('file',file,'scenario',scenario,'var','technology','reg',reg,'timelim',timelim);
clp_nc_trajectory('file',file,'scenario',scenario,'var','landuse','reg',reg,'timelim',timelim);
%clp_nc_trajectory('file',file,'scenario',scenario,'var','cropfraction','reg',reg,'timelim',timelim);
clp_nc_trajectory('file',file,'scenario',scenario,'var','temperature_limitation','reg',reg,'timelim',timelim

clp_nc_trajectory('file',file,'scenario',scenario,'var','cropfraction_static','reg',reg,'timelim',timelim);








return
file='../../landuse_fluc09.nc';
scenario='fluc09';

%% Originating variables (for China only)
clp_nc_trajectory('file',file,'scenario',scenario,'var','population_density','reg','chi','timelim',[-9000 -1000]);
clp_nc_trajectory('file',file,'scenario',scenario,'nosum',1,'var','technology','reg','chi','timelim',[-9000 -1000]);
clp_nc_trajectory('file',file,'scenario',scenario,'nosum',1,'var','subsistence_intensity','reg','chi','timelim',[-9000 -1000]);

%% Total land use
% extensive land use is impact per productivity
% ncap2 -A -s
% 'landuse[time,region]=population_density[time,region]*sqrt(technology)/subsistence_intensity;'
% reference.nc reference.nc

lim=[0,1];
clp_nc_trajectory('file',file,'scenario',scenario,'lim',lim,'nosum',1,'var','landuse','reg','all','timelim',[-9000 -1000],'fig',5);

%% Per capita land use
% landuse divided by population_density
lim=[0,2];
clp_nc_trajectory('file',file,'scenario',scenario,'lim',lim,'nosum',1,'var','landuse','reg','eur','div','population_density','timelim',[-9000 -1000],'fig',1);
clp_nc_trajectory('file',file,'scenario',scenario,'lim',lim,'nosum',1,'var','landuse','reg','nam','div','population_density','timelim',[-9000 -1000],'fig',2);
clp_nc_trajectory('file',file,'scenario',scenario,'lim',lim,'nosum',1,'var','landuse','reg','chi','div','population_density','timelim',[-9000 -1000],'fig',3);
clp_nc_trajectory('file',file,'scenario',scenario,'lim',lim,'nosum',1,'var','landuse','reg','all','div','population_density','timelim',[-9000 -1000],'fig',4);

%% Conversion of land use to cropfraction
% In Chinese full neolithic regions, the land use is between 0.08 and 0.12,
% seems asymptotic to 0.08 (lets take 0.1 for now)
% In Gregg 1988, the typical land use is cpf=0.02 per Farmer (also used in
% Lemmen 2009, where cropfraction was simply cropfraction=cpf*P (where Q>0.9)
% Thus, we should use the formulation cropfraction=landuse/0.1*0.02*Q and
% ncap2 -A -s 'cropfraction[time,region]=landuse/0.1*0.02*farming;cropfraction_static[time,region]=0.02*population_density*farming' test.nc test.nc

clp_nc_trajectory('file',file,'scenario',scenario,'nosum',1,'var','cropfraction','reg','chi','timelim',[-9000 -1000],'fig',10);
clp_nc_trajectory('file',file,'scenario',scenario,'nosum',1,'var','cropfraction_static','reg','chi','timelim',[-9000 -1000],'fig',10);

%% Plot timeslice map of results at 500-year interval
clp_nc_variable('file',file,'scenario',scenario,'var','cropfraction','mult',100,'lim',[0 15],'timelim',[-6000 , -1000],'timestep',500);
clp_nc_variable('file',file,'scenario',scenario,'var','cropfraction_static','mult',100,'lim',[0 15],'timelim',[-6000 , -1000],'timestep',500);

%% Get results from VECODE from climate file (current climate)
climatefile='region_iiasa_685.mat';
load(climatefile);

%% extract cropfraction from results file
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

figure(1); clf reset;
itime=find(time<=-1000);
plot(time(itime),emission(itime)/1E9,'r-');
title('Cumulative carbon emission by deforestation');
xlabel('Year BC/AD');
ylabel('Emission (Gt C)');
plot_multi_format(1,['landuse_glues_cumulative_emission_' scenario]);

figure(2); clf reset;
result=[time(itime) (emission(itime+1)-emission(itime))'/1E9./(time(itime+1)-time(itime))];
plot(result(:,1),result(:,2));
title('Annual carbon emission by deforestation');
xlabel('Year BC/AD');
ylabel('Emission (Gt C a$^{-1}$)','Interpreter','none');
plot_multi_format(2,['landuse_glues_annual_emission_' scenario]);

%% Save data
fid=fopen(['data/glues_deforestation_emission_' scenario '.tsv'],'w');
fprintf(fid,'# GLUES (v1.1.15) land use emissions by deforestation, including technological change\n');
fprintf(fid,'# Carsten Lemmen, GKSS-Forschungszentrum Geesthacht \n');
fprintf(fid,'# Column 1: Calendar year AD (positive) or BC (negative)');
fprintf(fid,'# Column 2: Annual global emission (Gt C a-1) as mean over given time interval\n');
fprintf(fid,'%5d\t%7.5f\n',result');
fclose(fid);


%% extract cropfraction_static from results file
ncid=netcdf.open(file,'NOWRITE');
varid=netcdf.inqVarID(ncid,'cropfraction_static');
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

figure(1); clf reset;
itime=find(time<=-1000);
plot(time(itime),emission(itime)/1E9,'r-');
title('Cumulative carbon emission by deforestation (static)');
xlabel('Year BC/AD');
ylabel('Emission (Gt C)');
plot_multi_format(1,['landuse_glues_cumulative_emission_static_' scenario]);

figure(2); clf reset;
result=[time(itime) (emission(itime+1)-emission(itime))'/1E9./(time(itime+1)-time(itime))];
plot(result(:,1),result(:,2));
title('Annual carbon emission by deforestation (static)');
xlabel('Year BC/AD');
ylabel('Emission (Gt C a$^{-1}$)','Interpreter','none');
plot_multi_format(2,['landuse_glues_annual_emission_static_' scenario]);

%% Save data
fid=fopen(['data/glues_deforestation_emission_static_' scenario '.tsv'],'w');
fprintf(fid,'# GLUES (v1.1.15) land use emissions by deforestation, disregarding technological change\n');
fprintf(fid,'# Carsten Lemmen, GKSS-Forschungszentrum Geesthacht \n');
fprintf(fid,'# Column 1: Calendar year AD (positive) or BC (negative)');
fprintf(fid,'# Column 2: Annual global emission (Gt C a-1), as mean over given time interval\n');
fprintf(fid,'%5d\t%7.5f\n',result');
fclose(fid);




%% return to main

return;



%%

file='../../landuse_fluc04.nc';
scenario='fluc04';
timelim=[-9500 2000];

ncid=netcdf.open(file,'NOWRITE');
varid=netcdf.inqVarID(ncid,'population_density');p=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'farming');f=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'technology');t=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'area');area=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'time');time=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'cropfraction_static');cf=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'npp');npp=netcdf.getVar(ncid,varid);
nppstar=450;  %NPP where LAE = 1	450
x=npp./nppstar;
fep=2*x./(1+x.^2);


netcdf.close(ncid);





end
