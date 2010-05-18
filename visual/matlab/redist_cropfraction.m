function redist_cropfraction
% This function takes glues results for countries, maps them to a grid and
% allocates the population to the most suitable grid cells

%% Read results file

clear all;

load('hyde_glues_cropfraction');
time=-9500:20:1980;

%% Read grid file
file='../../src/test/regions_11k.nc';
ncid=netcdf.open(file,'NC_NOWRITE');
varid=netcdf.inqVarId(ncid,'npp');
npp=netcdf.getVar(ncid,varid);
npp=single(npp(:,110));
varid=netcdf.inqVarId(ncid,'gdd');
gdd=netcdf.getVar(ncid,varid);
gdd=single(gdd(:,110));
%varid=netcdf.inqVarId(ncid,'area');
%area=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarId(ncid,'map_id');
map=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarId(ncid,'lat');
latit=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarId(ncid,'time');
ctime=netcdf.getVar(ncid,varid);
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
nc=length(latit);
ntime=length(time);
%ntime=40;

crop=uint8(zeros(nc,ntime));

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
  [s,isort]=sort(weight,'descend');
  weight=isort;
  w(ireg,1:nc)=weight;
end
  
%% reassign cells
for ireg=1:nreg
% for ireg=236:236
  ic=find(map==ireg);
  nc=length(ic);
  nfull=floor(cropfraction(ireg,:)*nc);
  chalf=cropfraction(ireg,:)*nc-nfull;
  
  for ifull=1:max(nfull)
    it=find(nfull==ifull);
    if isempty(j) continue; end
    crop(ic(w(ireg,1:ifull)),it)=uint8(255);
    crop(ic(w(ireg,ifull+1)),it)=uint8(chalf(it)*255);
  end
end

latmin=min(latit);
latmax=max(latit);

cmap=colormap(jet(256));
ncol=length(cmap);
col=crop;
col(col<1)=1;
col(col>ncol)=ncol;

figure(1);
clf reset;
m_proj('miller','lat',[latmin latmax]);
hold on;
m_coast('patch',cmap(1,:));
m_grid;

res=0.5;
dlat=[-res/2 -res/2 +res/2 +res/2 -res/2 NaN];
dlon=[-res/2 +res/2 +res/2 -res/2 -res/2 NaN];

%% Time loop
for itime=ntime:10:ntime
    
  title(num2str(time(itime)));
  for icol=1:ncol
    %if (itime>1 && exist('p','var') && length(p)>=icol && ishandle(p(icol))) delete(p(icol)); end
    ic=find(col(:,itime)==icol);
    nk=length(ic);
    if nk<1 continue; end
    %lon=reshape((lonit(ic)*dlon)',nk*6,1);
    %lat=reshape((latit(ic)*dlat)',nk*6,1);
    p(icol)=m_plot(lonit(ic),latit(ic),'ks','MarkerFaceColor',cmap(icol,:),'MarkerEdgeColor','none','MarkerSize',2.0);%,'MarkerSize',0.1,'MarkerEdgeColor','none');
    %p(icol)=m_patch(lon,lat,cmap(icol,:));
  end
  pause(0.01);
end

return
end


function fertility=hyper(kappa,npp,n)
  k=kappa.^(n-1);
  %npp=npp*factor; % factor is regional climate fluctuation
  fertility=(n*k*npp)./ (k*kappa*(n-1)+npp.^n);
  return
end



