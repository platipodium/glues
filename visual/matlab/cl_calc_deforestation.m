function cl_calc_deforestation

cl_register_function;

hydefile='region_hyde_685.mat';
climatefile='region_iiasa_685.mat';
%resultfilename='result_iiasaclimber_ref_all.mat';
resultfilename='results.mat';

hyde=load(hydefile);
hyde=hyde.climate;
load(climatefile);
load(resultfilename);
    
% per capita cropland
cpc=hyde.crop./hyde.popd/100; % in km2 per person

% farmer density
dfarm=r.Farming.*r.Density; % in person per km2

% select farming regions at 3000 BP
[mtime,itime]=min(abs(r.time-3000));
ifarm=find(r.Farming(:,itime)>0.9);

% per farmer cropland share
hyde.time=[12000:-1000:1000];
[mtime,itime]=min(abs(hyde.time-3000));
hc=hyde.crop(ifarm,itime)/100.;
hp=hyde.popd(ifarm,itime);
hv=(hc>0 & isfinite(hp));
iv=find(hv);
hp=hp(iv); hc=hc(iv);

p=polyfit(hp,hc,3);

% the above is leading to nothing ...

% Visual inspection of full-scale agricultural societeis in mesopotamia
cpf=0.02; % km2 per farmer

cropfraction=cpf*dfarm;
cropfraction(cropfraction>1)=1;
% static 100 t C/ha 
% Curtis et al (2002) estimate 100 t/ha aboveground carbon in temp decid
% forest
% naturalforest=repmat(climate.fshare',1,r.nstep)*100;

% new VECODE formulation

fshare=repmat(climate.fshare',1,r.nstep);
gshare=repmat(climate.gshare',1,r.nstep);
b12f=repmat(climate.b12f',1,r.nstep);
b12g=repmat(climate.b12g',1,r.nstep);
b34f=repmat(climate.b34f',1,r.nstep);
b34g=repmat(climate.b34g',1,r.nstep);


% carbon is calculated as t/ha
naturalcarbon=b12f.*fshare+b12g.*gshare ...
    +b34f.*fshare+b34g.*gshare;
remainingcarbon=b12f.*(fshare-cropfraction) ...
    +b12g.*(gshare+cropfraction) ...
    +b34f.*(fshare-cropfraction)...
    +0.58*b34f.*cropfraction...
    +b34g.*gshare;


%load('regionpath_685.mat');
load('regionmap_sea_685.mat');
if ~exist('region','var')
  region.area=regionarea;
end

if ~isfield(region,'area')
  land.area=calc_gridcell_area(map.latgrid(land.ilat))';
  for i=1:region.nreg
    r.area(i)=sum(land.area(land.region==i));
  end
end


deforestation=cropfraction*100.*repmat(r.area',1,r.nstep);
save('hyde_glues_cropfraction','cropfraction','naturalcarbon',...
    'remainingcarbon','deforestation');




return
end


    
