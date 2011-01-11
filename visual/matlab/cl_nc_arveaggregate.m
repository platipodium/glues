function cl_nc_arveaggregate(varargin)
% This function takes glues results for glues regions, maps them to a 
% half-degree grid and aggregates over the ARVE population regions.

arguments = {...
  {'timelim',[-9500,1000]},...
  {'variables','population_density'},...
  {'timestep',1},...
  {'file','../../test.nc'},...
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

[ndim nvar natt udimid] = netcdf.inq(ncid); 
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
file='../../data/pop_region_key2.txt';
fid=fopen(file,'r');
C=textscan(fid,'%d %s');
fclose(fid);
arveid=C{1};
arvename=C{2};
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

debug=0
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
for ia=1:nar
%for ia=213:213 % MAyan America
  [iarow,iacol,val]=find(arveregion==ar(ia));
  % calculate arve regional area
  arvearea(ia)=sum(calc_gridcell_area(arvelat(iacol),1/12.0,1/12.0));
  
  % convert to GLUES: col->row, reverse lats
  irow=nrow-floor((iacol-1)/(nacol/nrow));
  icol=floor((iarow-1)/(narow/ncol))+1;
  [irc,airc,birc]=unique([irow icol],'rows');
  nirc=size(irc,1);
  
  reg=[];
  for i=1:nirc reg(i)=map.region(irc(i,2),irc(i,1)); end
 
  
  if debug
    clf reset;
    m_proj('miller','lon',...
      [min(arvelon(iarow))-1 max(arvelon(iarow))+1],...
      'lat',[min(arvelat(iacol))-1 max(arvelat(iacol))+1]);
    m_coast;
    m_grid;
    hold on;
    m_plot(arvelon(iarow),arvelat(iacol),'r.');
    %m_plot(map.longrid(icol),map.latgrid(irow),'b.');
    for i=1:length(irc)
      m_text(map.longrid(irc(i,2)),map.latgrid(irc(i,1)),num2str(reg(i)),...
          'Vertical','middle','Horizontal','center','fontsize',8);
    end
  end
  
  % Afghanistan area 652.225 km²
  
  iv=find(reg>0);
  if size(reg)>0
    iarea=calc_gridcell_area(map.latgrid(irc(iv,1)),0.5,0.5);
    garea(ia)=sum(iarea);
    warea=iarea/garea(ia);
    arvesize(ia,:)=sum(repmat(iarea,ntime,1).*population_density(reg(iv),itime)',2);
    arvedensity(ia,:)=sum(repmat(warea,ntime,1).*population_density(reg(iv),itime)',2);
    
    % find proportion of glues region in cell
    gluessize(ia,:)=sum(population_size(reg(iv),itime)./repmat(ncell(reg(iv)),1,ntime));
    gluesarea(ia)=sum(area(reg(iv))./ncell(reg(iv)));
    
  else
    arvedensity(ia,1:ntime)=NaN;
    arvesize(ia,1:ntime)=NaN;
    gluessize(ia,1:ntime)=NaN;
    gluesarea(ia,1:ntime)=NaN;
    garea(ia)=inf;
 end
  %fprintf('.');
  
  iid=find(arveid==ar(ia));
  if isempty(iid) iid=999; end
  
  fprintf('%3d %s\t%.2f %.2f %.2f %.2f %.2f %.2f\n',arveid(iid),arvename{iid},gluesarea(ia)/1E6,...
      garea(ia)/1E6,arvearea(ia)/1E6,gluessize(ia,end)/1E6,...
      arvesize(ia,end)/1E6,arvedensity(ia,end));
  
  
end


  fprintf('999 World\t\t%.2f %.2f %.2f %.2f %.2f %.2f\n',sum(gluesarea)/1E6,...
      sum(garea)/1E6,sum(arvearea)/1E6,sum(gluessize(:,end))/1E6,...
      sum(arvesize(:,end))/1E6,mean(arvedensity(:,end)));


index=ar;
save('arveaggregate','-v6','arvedensity','arvesize','gluessize','gluesarea','garea','index','time');





return
end