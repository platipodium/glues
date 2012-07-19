function plot_hyde(var,itime)

cl_register_function;

if ~exist('latlim','var') latlim=[29,55]; end
if ~exist('lonlim','var') lonlim=[-5,43]; end
if ~exist('var','var')    var='pasturefraction'; end
if ~exist('itime','var')    itime=2; end


%             landmask: [4320x2160 int8]
%             landarea: [4320x2160 int8]
%             gridarea: [4320x2160 int8]
%         cropfraction: {1x10 cell}
%      pasturefraction: {1x10 cell}
%                 time: [-10000 -1000 -2000 -3000 -4000 -5000 -6000 -7000 -8000 -9000]
%    populationdensity: {1x10 cell}
%      populationcount: {1x10 cell}



matfile='hyde.mat';
 if ~exist(matfile,'file')
   warning('HYDE  file %s does not exist, recreate with read_hyde.m\n',matfile);
   return
 end

load(matfile); %,['hyde.' var],'hyde.lon','hyde.lat');

lat=hyde.lat;
lon=hyde.lon;
ilat=find(lat>=latlim(1) & lat<=latlim(2));
ilon=find(lon>=lonlim(1) & lon<=lonlim(2));

if isempty(ilon) | isempty(ilat)
    error('No data in specified range of lon/lat\');
end


eval(['val = hyde.' var ';']);

if numel(hyde.time)==numel(val)
    pval=val{itime};
else
pval=val;
end

gt=max(max(pval(ilon,ilat)));
pval(hyde.isocean)=-gt;

figure(1);
clf reset;
m_proj('miller','lat',latlim,'lon',lonlim);
m_coast;
m_pcolor(lon(ilon),lat(ilat),double(pval(ilon,ilat)'));
shading interp;
caxis([-gt gt]);
ttext=sprintf('HYDE %s ',var);
title(ttext);
colorbar;
m_grid;


figure(2);
clf reset;
c=hyde.cropfraction{2}(ilon,ilat);
g=hyde.pasturefraction{2}(ilon,ilat);
pd=hyde.populationdensity{2};
pc=hyde.populationcount{2}(ilon,ilat);


dval=double(pval./pd);
gt=cl_mmax(dval(ilon,ilat));
dval(hyde.isocean)=-gt;

m_proj('miller','lat',latlim,'lon',lonlim);
m_coast;
m_pcolor(lon(ilon),lat(ilat),dval(ilon,ilat)');
shading interp;
caxis([-gt gt]);
ttext=sprintf('HYDE per capita %s (ha)',strrep(var,'fraction',''));
title(ttext);
colorbar;
m_grid;

plot_multi_format(1,['hyde_' var]);
plot_multi_format(2,['hyde_' var '_percapita']);

end


  
 


