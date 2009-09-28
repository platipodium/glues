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

cropfraction=cpf*dfarm*100;
cropfraction(cropfraction>100)=100;
naturalforest=repmat(climate.fshare',1,288)*100;
remainingforest=naturalforest-cropfraction;

% Curtis et al (2002) estimate 100 t/ha aboveground carbon in temp decid
% forest
load('regionpath_685.mat');
deforestation=cropfraction/100.0*10000.*repmat(region.area',1,288);
save('hyde_glues_cropfraction','cropfraction','naturalforest',...
    'remainingforest','deforestation');




return
end


    
