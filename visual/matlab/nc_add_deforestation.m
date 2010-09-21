function nc_add_deforestation

cl_register_function;

resultfile='../../test.nc';

ncid=netcdf.open(resultfile,'NC_WRITE');
farming=single(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'farming')));
density=single(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'population_density')));
time=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'time'))';
area=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'area'));
netcdf.close(ncid);



% Visual inspection of full-scale agricultural societeis in mesopotamia
cpf=0.02; % crop km2 per farmer
farmingdensity=farming.*density; % Farmer density in person / km2
cropfraction=cpf*farmingdensity;
cropfraction(cropfraction>1)=1;

ntime=length(time);
deforestation=cropfraction*100.*repmat(area,1,ntime); % unit is km2



% new VECODE formulation
% temp and precip in climate file
% TODO: base this on netcdf, and calculate for each time step (currently
% static on IIASA database
load 'region_iiasa_685.mat';

fshare=repmat(climate.fshare',1,ntime);
gshare=repmat(climate.gshare',1,ntime);
b12f=repmat(climate.b12f',1,ntime);
b12g=repmat(climate.b12g',1,ntime);
b34f=repmat(climate.b34f',1,ntime);
b34g=repmat(climate.b34g',1,ntime);

% 
% [production,share,carbon,p]=clc_vecode(iiasa.temp,iiasa.precip,iiasa.gdd0);
% fshare=share.forest;
% gshare=share.grass;
% b12f=p.b1t+p.b2t;
% b34f=p.b3t+p.b4t;
% b12g=p.b1g+p.b2g;
% b34g=p.b3g+p.b4g;


naturalcarbon=b12f.*fshare+b12g.*gshare ...
    +b34f.*fshare+b34g.*gshare;

remainingcarbon=b12f.*(fshare-cropfraction) ...
    +b12g.*(gshare+cropfraction) ...
    +b34f.*(fshare-cropfraction)...
    +0.58*b34f.*cropfraction...
    +b34g.*gshare;

emission=naturalcarbon-remainingcarbon;


if 1==1
  figure(1);
  clf reset;
  plot(time,sum(emission)/1E2,'r-');
  ylabel('Accumulated emission (Gt C)');
  xlabel('Time (year BC/AD)');
  title('Global carbon emission by deforestation');
  cl_year_one;
end


return
end


    
