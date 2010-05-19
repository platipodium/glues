function redist_cropfraction
% This function takes glues results for countries, maps them to a grid and
% allocates the population to the most suitable grid cells

%% Read results file

clear all;

load('hyde_glues_cropfraction');
time=-9500:20:1980;


% Select only one time
%itime=find(time==0);
%time=time(itime);
%cropfraction=cropfraction(:,itime);

%% Read grid file
  file='../../src/test/regions_11k.nc';
  ncid=netcdf.open(file,'NC_NOWRITE');
  varid=netcdf.inqVarId(ncid,'npp');
  npp=netcdf.getVar(ncid,varid);
  npp=single(npp);
  varid=netcdf.inqVarId(ncid,'gdd');
  gdd=netcdf.getVar(ncid,varid);
  gdd=single(gdd);
varid=netcdf.inqVarId(ncid,'area');
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


%% REad arve grid file
%   file='/h/lemmen/projects/glues/tex/2010/holopop/arve/biome4out.nc';
%   ncid=netcdf.open(file,'NC_NOWRITE');
%   varid=netcdf.inqVarId(ncid,'npp');
%   npp=netcdf.getVar(ncid,varid);
%   varid=netcdf.inqVarId(ncid,'gdd0');
%   gdd=netcdf.getVar(ncid,varid);
% netcdf.close(ncid);

%% Calculate
ntime=length(time);

%% Loop over all regions
nreg=max(max(map));
nc=length(latit);

%ntime=40;

crop=uint8(zeros(nc,ntime));
%% Comput maximal number of cells from max region only
ncmax=0;
for ireg=1:nreg
  ic=find(map==ireg);
  if length(ic)>ncmax ncmax=length(ic); end
end
w=zeros(nreg,nc)+NaN;
usemax=0.33; % maximal use of one grid cell
cmap=colormap(greenred(9));
ncol=length(cmap);

latmin=min(latit);
latmax=max(latit);



res=0.5;
dlat=[-res/2 -res/2 +res/2 +res/2 -res/2 NaN];
dlon=[-res/2 +res/2 +res/2 -res/2 -res/2 NaN];


%itime=find(time==-1000);
%for itime=itime
for itime=1:25:ntime

 [a ictime]=min(abs(ctime-time(itime)));

kappa=550*1.5; % most suitable, SiSi param in standard GLUES run
tlim=single(gdd(:,ictime)./max(gdd(:,ictime)));
natfert=hyper(kappa,npp(:,ictime),2);
natfert=natfert.*tlim;

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
%for ireg=236:236
  ic=find(map==ireg);
  nc=length(ic);
  %nfull=floor(cropfraction(ireg,:)*nc/usemax);
  %chalf=cropfraction(ireg,:)*nc-nfull*usemax;
  
  for ifull=1:-1%max(nfull)
    it=find(nfull==ifull);
    if isempty(it) continue; end
    crop(ic(w(ireg,1:ifull)),it)=uint8(usemax*255);
    crop(ic(w(ireg,ifull+1)),it)=uint8(chalf(it)*255);
  end
  
  
  cropicit=(w(ireg,1:nc)/sum(w(ireg,1:nc))*nc*cropfraction(ireg,itime));
  cropicit=0.5-0.5*cos(cropicit*pi);
  cropicit(cropicit>1)=1;
  cropicit(cropicit<0)=0;
  cropicit=cropicit.^2;
  cropicit=cropicit/mean(cropicit)*cropfraction(ireg,itime);
    
  crop(ic,itime)=uint8(255*cropicit);

  %   for it=1:ntime
%     cropicit=(w(ireg,1:nc)/sum(w(ireg,1:nc))*nc*cropfraction(ireg,it));
%     cropicit=0.5-0.5*cos(cropicit*pi);
%     cropicit(cropicit>1)=1;
%     cropicit(cropicit<0)=0;
%     cropicit=cropicit.^2;
%     cropicit=cropicit/mean(cropicit)*cropfraction(ireg,it);
%     
%     crop(ic,it)=uint8(255*cropicit);
%     if cropfraction(ireg,it)<-0.01
%       a(it)=mean(cropicit);
%       b(it)=cropfraction(ireg,it);
%       fprintf('%.2f %.2f\n',a(it),b(it));
%     end
%   end
%   
  
end
col=crop*(ncol/256);
col(col<1)=1;
col(col>ncol)=ncol;


%% Prepare the figure
figure(1);
clf reset;
m_proj('equidistant','lat',[latmin latmax]);
%m_proj('equidistant','lat',[30 60 ],'lon',[-10 30]);
hold on;
m_coast('patch',cmap(1,:));
m_grid;
colormap(cmap);


%itime=find(time==0);
% Time loop
%for itime=1:25:ntime
%for itime=itime 
  if time(itime)>=0 adstr='AD '; else adstr = ''; end
  if time(itime) <0 bcstr=' BC'; else bcstr=''; end
  if time(itime)==0 time(itime)=1; end
  strtime=sprintf('%s%d%s',adstr,ceil(abs(time(itime))),bcstr);

  title(strtime);
  for icol=1:max(max(col))
    %if (itime>1 && exist('p','var') && length(p)>=icol && ishandle(p(icol))) delete(p(icol)); end
    ic=find(col(:,itime)==icol);
    nk=length(ic);
    if nk<1 continue; end
    %lon=reshape((lonit(ic)*dlon)',nk*6,1);
    %lat=reshape((latit(ic)*dlat)',nk*6,1);
    p(icol)=m_plot(lonit(ic),latit(ic),'ks','MarkerFaceColor',cmap(icol,:),...
      'MarkerEdgeColor','none','MarkerSize',2.0);%,'MarkerSize',0.1,'MarkerEdgeColor','none');
    %p(icol)=m_patch(lon,lat,cmap(icol,:));
  end
  %pause(0.01);
  name=sprintf('redist_cropfraction_%05d',ceil(time(itime)));
  %colorbar('SouthOutside');
  plot_multi_format(gcf,name);
  
end
;

%% Exit cleanly
return
end


function fertility=hyper(kappa,npp,n)
  k=kappa.^(n-1);
  %npp=npp*factor; % factor is regional climate fluctuation
  fertility=(n*k*npp)./ (k*kappa*(n-1)+npp.^n);
  return
end



