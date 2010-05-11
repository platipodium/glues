function redist_population
% This function takes glues results for countries, maps them to a grid and
% allocates the population to the most suitable grid cells

%% Read results file

clear all;

file='../../test.nc';
ncid=netcdf.open(file,'NC_NOWRITE');
varid=netcdf.inqVarId(ncid,'population_density');
pop=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarId(ncid,'time');
time=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarId(ncid,'region');
r_id=netcdf.getVar(ncid,varid)+1;
netcdf.close(ncid);


%% Read grid file
file='../../src/test/regions_11k.nc';
ncid=netcdf.open(file,'NC_NOWRITE');
varid=netcdf.inqVarId(ncid,'npp');
npp=netcdf.getVar(ncid,varid);
npp=single(npp(:,110));
varid=netcdf.inqVarId(ncid,'gdd');
gdd=netcdf.getVar(ncid,varid);
gdd=single(gdd(:,110));
varid=netcdf.inqVarId(ncid,'area');
area=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarId(ncid,'map_id');
map=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarId(ncid,'region');
c_id=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarId(ncid,'lat');
latit=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarId(ncid,'lon');
lonit=netcdf.getVar(ncid,varid);
netcdf.close(ncid);


%% Calculate
kappa=550*1.5; % most suitable, SiSi param in standard GLUES run
tlim=single(gdd./max(gdd));
natfert=hyper(kappa,npp,2);
natfert=natfert.*tlim;

%% Loop over all regions
nreg=max(max(map));
nc=length(area);
ntime=length(time);
%ntime=40;

pmax=max(max(pop));
wmax=0;

%% Comput maximal number of cells from max region only
ncmax=0;
for ireg=1:nreg
  ic=find(map==ireg);
  if length(ic)>ncmax ncmax=length(ic); end
end
w=zeros(nreg,nc)+NaN;

%% Compute weights
for ireg=1:nreg
  ic=find(map==ireg);
  nc=length(ic);
  weight=natfert(ic);
  [s,isort]=sort(weight);
  weight=(weight).^5;
  weight=weight/mean(weight);
  w(ireg,1:nc)=weight;
end
  
wmax=max(max(weight));
weigth=weight/wmax;
pop=pop/pmax;


rpop=uint8(zeros(nc,ntime));
for ireg=1:nreg
  ic=find(map==ireg);
  nc=length(ic);
  rpop(ic,:)=uint8(w(ireg,1:nc)'*pop(ireg,1:ntime)*255.0);
end

latmin=min(latit);
latmax=max(latit);

cmap=colormap(jet(256));
ncol=length(cmap);
col=rpop;
col(col<1)=1;
col(col>ncol)=ncol;

figure(1);
clf reset;
m_proj('miller','lat',[latmin latmax]);
hold on;
m_coast;
m_grid;

%% Time loop
for itime=1:100:ntime
    
  title(num2str(time(itime)));
  for icol=1:ncol
    %if (itime>1 && exist('p','var') && length(p)>=icol && ishandle(p(icol))) delete(p(icol)); end
    ic=find(col(:,itime)==icol);
    if isempty(ic) continue; end
    p(icol)=m_plot(lonit(ic),latit(ic),'ks','color',cmap(icol,:),'MarkerSize',0.1);
  end
  pause(0.1);
end

return
end


function fertility=hyper(kappa,npp,n)
  k=kappa.^(n-1);
  %npp=npp*factor; % factor is regional climate fluctuation
  fertility=(n*k*npp)./ (k*kappa*(n-1)+npp.^n);
  return
end



