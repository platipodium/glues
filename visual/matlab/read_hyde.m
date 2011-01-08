function read_hyde

cl_register_function;

% requires
% - cl_register_function.m
% - read_hyde_asc.m


% (ftp://ftp.mnp.nl/hyde/hyde_sept08)

% Population  
% popc = population counts, in inhabitants/gridcell
% popd = population density, in inhabitants/km2 per gridcell. Calculated with gridarea.asc
% rurc = rural population counts, in inh/gridcell
% urbc = urban population counts, in inh/gridcell
% uopp = urban area, in km2/gridcell

% Land use
% crop = cropland area, in km2/gridcell
% gras = pasture area, in km2/gridcell

% General
% landlake.asc (land-sea mask on 5'), including lakes (land = 1, lakes = 0, rest = -9999)
% mland_cr.asc (maximum landarea available per gridcell in km2)
% garea_cr.asc (total gridcell area in km2, spherical Earth)

dhyde='/h/koedata01/data/model/hyde';
dhyde='data';

vars={'landlake','mland_cr','garea_cr'};
nvars=length(vars);
fland=dir(fullfile(dhyde,'landlake.asc'));

for ivar=1:nvars
      var=vars{ivar};
    
    fname=strrep(fland(1).name,'landlake',var);
    matfile=strrep(fname,'.asc','.mat');
    if ~exist(matfile,'file')
      read_hyde_asc(fullfile(dhyde,fname));
    end

    load(matfile);

end

% Create the appropriate grid
nlon=size(land,1);
nlat=size(land,2);
lon=(1.0*[0:nlon-1])/nlon*360.0-180.0;
lat=90.0-(1.0*[0:nlat-1])/nlat*180.0;

% Data is lower-left coded, change to center
lon=lon+0.5*360./nlon;
lat=lat-0.5*180./nlat;

hyde.lon=lon;
hyde.lat=lat;


% simplify data structures
% landmask -1 ocean 0 lake 1 land
hyde.isocean=find(isnan(land));
hyde.islake=find(land==0);
hyde.island=find(land>0);
hyde.iswater=find(land<1);

land(hyde.isocean)=-1;
land=int8(land);

gare(hyde.iswater)=0;
mlan(hyde.iswater)=0;
gare=single(gare); 
mlan=single(mlan); 

hyde.landmask=land;
hyde.landarea=mlan;
hyde.gridarea=gare;

if str2num(version('-release'))>13
  save('-v6','hyde.mat','hyde');
else
   save('hyde.mat','hyde');
 end
 
%return
fcrop=dir(fullfile(dhyde,'crop*BC.asc'));
nfiles=length(fcrop);

vars={'crop','gras','popd_','popc_'};
nvars=length(vars);
for ifile=1:nfiles 

  for ivar=1:nvars
      var=vars{ivar};
    
    fname=strrep(fcrop(ifile).name,'crop',var);
    matfile=strrep(fname,'.asc','.mat');
    if ~exist(matfile,'file')
           matfile=fullfile(dhyde,matfile);
      if ~exist(matfile,'file')
      matfile=strrep(fname,'.asc','.mat');
    
        read_hyde_asc(fullfile(dhyde,fname));
      end
    end

    load(matfile);

   switch(ivar)
       case 1,  c{ifile}=single(crop);
       case 2,  g{ifile}=single(gras);
       case 3,  pd{ifile}=single(popd);
      case 4,  pc{ifile}=single(popc);
   end
  end 
  fname=strrep(fname,'_','');
   fname=strrep(fname,'.asc','');
 l=length(fname);
  varname=fname(1:4);
  period=fname(end-1:end);
  time=str2num(fname(5:end-2));
  if strcmp(lower(period),'bc')
      t(ifile)=-time;
  else t(ifile)=time;
  end
  fprintf('Read %s for time %d (%d/%d %.1f/%.1f\n',matfile,t(ifile),cl_mmax(c{ifile}), ...
      cl_mmax(g{ifile}), cl_mmax(pd{ifile}), cl_mmax(pc{ifile}));
end

hyde.cropfraction=c;
hyde.pasturefraction=g;
hyde.time=t;
hyde.populationdensity=pd;
hyde.populationcount=pc;

 save('hyde.mat','hyde')
%save('-v6','hyde.mat','hyde');

end


  
 


