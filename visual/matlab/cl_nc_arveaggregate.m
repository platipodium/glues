function cl_nc_arveaggregate(varargin)
% This function takes glues results for glues regions, maps them to a 
% half-degree grid and aggregates over the ARVE population regions.

arguments = {...
  {'timelim',[-9500,1000]},...
  {'variables','population_density'},...
  {'timestep',1},...
  {'file','../../eurolbk_events.nc'},...
  {'scenario',''}...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end


%% Read results file
if ~exist(file,'file') error('File does not exist'); end
ncid=netcdf.open(file,'NC_NOWRITE');

varname='region'; varid=netcdf.inqVarID(ncid,varname);
id=netcdf.getVar(ncid,varid);

[ndim, nvar, natt, udimid] = netcdf.inq(ncid); 
for varid=0:nvar-1
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
  if strcmp(varname,'lat') lat=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'lon') lon=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'latitude') latit=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'longitude') lonit=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'area') area=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'population_density') population_density=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'population_size') population_size=netcdf.getVar(ncid,varid); end
end

if exist('lat','var') 
  if length(lat)~=(region)
    if exist('latit','var') lat=latit; end
  end
else
  if exist('latit','var') lat=latit; end
end

if exist('lon','var') 
  if length(lon)~=(region)
    if exist('lonit','var') lon=lonit; end
  end
else
  if exist('lonit','var') lon=lonit; end
end

data=population_density;


% Find time dimension
ntime=1;
if numel(data)>length(data)
  idimid=find(udimid==dimids);
  tid=netcdf.inqVarID(ncid,netcdf.inqDim(ncid,udimid));
  time=netcdf.getVar(ncid,tid);
  itime=find(time>=timelim(1) & time<=timelim(2));
  if isempty(itime)
      error('Not data in specified time range')
  end
  itime=itime([1:timestep:length(itime)]);
  time=time(itime);
  ntime=length(time);
end
if ntime==1 && ~exist('itime','var') itime=1; end
netcdf.close(ncid);




%% Read popregions file
% arvelat is -89.xx .. 89.xx
% arvelon is -179.xx .. 179.xx (col=lat)
% size arveregion is 4320 x 2160 (row=lon)

file='../../data/popregions6.nc';
ncid=netcdf.open(file,'NC_NOWRITE');
varid=netcdf.inqVarID(ncid,'z');
arveregion=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'lat');
arvelat=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'lon');
arvelon=netcdf.getVar(ncid,varid);
netcdf.close(ncid);

%% Region region names
file='../../data/super_region_key.txt';
fid=fopen(file,'r');
C=textscan(fid,'%d %d %s');
fclose(fid);
arvesuper=C{1};
arveid=C{2};
arvename=C{3};
arvename{999}='Not_named';
arveid(999)=0;

%% Read GLUES raster
% map.latgrid is 89 . -89
% map.longrid is -179.. 179
% size(map.region) is 360 x 720

load('regionmap_sea_685.mat');
nrow=size(map.region,1);
ncol=size(map.region,2);

%% For each ARVE region find cells and read GLUES
ar=unique(arveregion);
nland=sum(sum(arveregion>0));
nwater=sum(sum(arveregion<0));

ar=ar(ar>0);
nar=length(ar);
[narow,nacol]=size(arveregion);

debug=0;
if debug>0;figure(1); clf reset;end 

map.region=zeros(720,360);
for i=1:length(land.region)
  map.region(land.ilon(i),land.ilat(i))=land.region(i);
end
  

% find ncell for each glues region
for i=1:length(id)
  ncell(i,1)=sum(land.region==i);
end


%%
arveregionarea=zeros(nar,1);
arvedensity=zeros(nar,ntime);
arvesize=zeros(nar,ntime);
arvegluessize=zeros(nar,ntime);
arvearea=zeros(nar,1);

for ia=1:nar
    
    
    
  [iarow,iacol,val]=find(arveregion==ar(ia));
  nval=length(iarow);
  % calculate arve regional area
  arvecellarea=calc_gridcell_area(arvelat(iacol),1/12.0,1/12.0);
  arveregionarea(ia)=sum(arvecellarea);
  
  % convert to GLUES: col->row, reverse lats
  irow=nrow-floor((iacol-1)/(nacol/nrow));
  icol=floor((iarow-1)/(narow/ncol))+1;
  %icol=ncol-floor((iarow-1)/(narow/ncol));
  [irc,airc,birc]=unique([irow icol],'rows');
  nirc=size(irc,1);
  
  arvecellgluesregion=zeros(nval,1);
  for i=1:nval 
    arvecellgluesregion(i)=map.region(icol(i),irow(i)); 
  end
 
  reg=zeros(nirc,1);
  for i=1:nirc reg(i)=map.region(irc(i,2),irc(i,1)); end
  
  if debug
    clf reset;
    m_proj('miller','lon',...
      [min(arvelon(iarow))-1 max(arvelon(iarow))+1],...
      'lat',[min(arvelat(iacol))-1 max(arvelat(iacol))+1]);
    m_coast;
    m_grid;
    hold on;
    p1=m_pcolor(map.longrid,map.latgrid,map.region');
    set(p1,'FaceAlpha',0.5,'EdgeColor','none');
    p2=m_plot(arvelon(iarow),arvelat(iacol),'r.');
    
    title(sprintf('%d-%d: %s',ia,arvesuper(ia),arvename{ia})); 
    m_plot(map.longrid(icol),map.latgrid(irow),'b.');
    for i=1:length(irc)
      m_text(map.longrid(irc(i,2)),map.latgrid(irc(i,1)),num2str(reg(i)),...
          'Vertical','middle','Horizontal','center','fontsize',8);
    end
    
  end
  
  % Afghanistan area 652.225 km²
  
  iv=find(arvecellgluesregion>0);
  nvalid=length(iv);
  if size(reg)>0 & nvalid>0
    arvedensity(ia,:)=sum(population_density(arvecellgluesregion(iv),itime))/nvalid;
    arvesize(ia,:)=sum(repmat(arvecellarea(iv),1,ntime)...
        .*population_density(arvecellgluesregion(iv),itime))...
        *sum(arvecellarea)/sum(arvecellarea(iv));
    arvegluessize(ia,:)=sum(population_size(arvecellgluesregion(iv),itime))/nvalid;
    arvearea(ia)=arveregionarea(ia);
  else
    arvedensity(ia,1:ntime)=NaN;
    arvesize(ia,1:ntime)=NaN;
    arvegluessize(ia,1:ntime)=NaN;
    arvearea(ia)=inf;
  end
  
  iid=find(arveid==ar(ia));
  if isempty(iid) iid=999; end
  
  fprintf('%3d %s\t%.2f %.2f %.2f(=%.2f) %.2f\n',arveid(iid),arvename{iid},...
      arveregionarea(ia)/1E6,arvegluessize(ia,end)/1E6,...
      arvesize(ia,end)/1E6,arvedensity(ia,end)*arveregionarea(ia)/1E6,...
      arvedensity(ia,end));
  
  
end


fprintf('999 World\t\t%.2f %.2f %.2f %.2f\n',...
      sum(arveregionarea)/1E6,sum(arvegluessize(:,end))/1E6,...
      sum(arvesize(:,end))/1E6,mean(arvedensity(:,end)));


index=ar;
population_density=arvedensity;
population_size=arvesize;
area=arveregionarea;


save('arveaggregate','-v6','population_density','population_size','area','index','time');





return
end