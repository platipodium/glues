function [retdata,reterror]=clp_site_timing(varargin)
% Adds timing data to existing plot

cl_register_function();

arguments = {...
  {'timelim',[-9000,1960]},...
  {'lim',[-inf,inf]},...
  {'reg','all'},...
  {'file','neolithicsites.mat'},...
  {'retdata',NaN},...
  {'nocolor',0},...
  {'ncol',19},...
  {'flip',0},...
  {'radius',100},...
  {'latlim',[20,70]},...
  {'lonlim',[-20,50]},...
  {'projection','equidistant'},...
  {'data',NaN},...
  {'reterror',NaN}
};

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length
  valstr=clp_valuestring(a.value{i});
  if ischar(valstr) eval([a.name{i} '=' valstr ';']);
  else eval([a.name{i} '= valstr;']);
  end
end

[d,f]=get_files;

if ~exist(file,'file')
    fprintf('Required file neolithicsites.mat not found, please contact distributor.\n');
    return
end

vars={'Farming'};

load('neolithicsites');

lat=Forenbaher.Latitude;
lon=Forenbaher.Long;
period=Forenbaher.Period;
site=Forenbaher.Site_name;
age=Forenbaher.Median_age;
n=length(lat);
time=1950-age;

if nocolor==0 colmap=jet(ncol);
else colmap=gray(ncol);
end

if flip==1 colmap=flipud(colmap); end

ctime=(time-timelim(1))/(timelim(2)-timelim(1));
ctime(ctime<0)=0;
ctime(ctime>1)=inf;
ctime=round(ctime*(ncol-1)+0.51);

itime=isfinite(ctime);
if isempty(itime) error('No data in time limits'); end
ctime=ctime(itime);
lat=lat(itime);
lon=lon(itime);
site=site(itime);
n=length(site);

m_proj(projection,'lat',latlim,'lon',lonlim);
%m_coast;

for i=1:n
  distlons=reshape([repmat(lon(i),n,1),lon']',2*n,1);
  distlats=reshape([repmat(lat(i),n,1),lat']',2*n,1);
  dist=m_lldist(distlons,distlats);
  inear=find(dist(1:2:end)<radius);
  [etime(i) esite(i)]=min(time(inear));
  esite(i)=inear(esite(i));
end

[usite,i,j]=unique(esite);
uctime=ctime(i);
utime=etime(i);
nu=length(usite);
ulon=lon(i);
ulat=lat(i);

for i=1:nu
  m_line(ulon(i),ulat(i),'MarkerEdgeColor','k','MarkerFaceColor',colmap(uctime(i),:),'LineStyle','none','Marker','o');
end

%% Calculate an error if data contains value/lat/lon positions
if isstruct(data)
  ivalid=find(data.lat<=latlim(2) & data.lat>=latlim(1) & data.lon<=lonlim(2) & data.lon>=lonlim(1) & isfinite(data.value));
  slat=data.lat(ivalid);
  slon=data.lon(ivalid);
  sval=data.value(ivalid);
  ns=length(sval);
  
  %% Loop over all sites
  for i=1:n
    distlons=reshape([repmat(lon(i),ns,1),slon]',2*ns,1);
    distlats=reshape([repmat(lat(i),ns,1),slat]',2*ns,1);
    dist=m_lldist(distlons,distlats);
    dist(find(dist>1000))=inf;
    distweight=exp(-dist(1:2:end)/500);
    disttime=time(i)'-sval;
    error_s(i)=sum(disttime.*distweight)/sum(distweight);
    distetime=etime(i)'-sval;
    error_e(i)=sum(distetime.*distweight)/sum(distweight);
  end
    
  %%
  error_s=error_s(isfinite(error_s));
  error_e=error_e(isfinite(error_e));
  ne=lenght(error_s);
  
  fprintf('Site      error: mean %4d, r2=%d / abs mean %4d years\n',round(mean(error_s)),round(error_s.^2/(ne-1)),round(mean(abs(error_s))));
  fprintf('Early     error: mean %4d, r2=%d / abs mean %4d years\n',round(mean(error_e)),round(error_e.^2/(ne-1)),round(mean(abs(error_e))));
   
  %% Loop over all region data
  for i=1:ns
    distlons=reshape([repmat(slon(i),n,1),lon'],2*n,1);
    distlats=reshape([repmat(slat(i),n,1),lat'],2*n,1);
    dist=m_lldist(distlons,distlats);
    dist(find(dist>1000))=inf;
    distweight=exp(-dist(1:2:end)/500);
    disttime=time'-sval(i);
    error_rs(i)=sum(disttime.*distweight)/sum(distweight);
    distetime=etime'-sval(i);
    error_re(i)=sum(distetime.*distweight)/sum(distweight);
  end
  
  error_rs=error_rs(isfinite(error_rs));
  error_re=error_re(isfinite(error_re));
  
  fprintf('Sim site  error: mean %4d / abs mean %4d years\n',round(mean(error_rs)),round(mean(abs(error_rs))));
  fprintf('Sim early error: mean %4d / abs mean %4d years\n',round(mean(error_re)),round(mean(abs(error_re))));
    
  
end


if (nargout>0) retdata=utime; end
if (nargout>1) 
    reterror.rs=error_rs;
    reterror.re=error_re;
    reterror.s=error_s;
    reterror.e=error_e;
return
end
