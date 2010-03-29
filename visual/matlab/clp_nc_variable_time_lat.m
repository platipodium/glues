function clp_nc_variable_time_lat(varargin)

arguments = {...
  {'latlim',[-60 80]},...
  {'lonlim',[-180 180]},...
  {'timelim',[-9500,-1000]},...
  {'lim',[-inf,inf]},...
  {'reg','all'},...
  {'discrete',0},...
  {'vars','actual_fertility'},...
  {'scale','absolute'},...
  {'figoffset',0},...
  {'timeunit','BP'},...
  {'timestep',100},...
  {'marble',0},...
  {'seacolor',0.7*ones(1,3)},...
  {'landcolor',.8*ones(1,3)},...
  {'transparency',1},...
  {'snapyear',1000},...
  {'movie',1},...
  {'showsites',0},...
  {'file','../../src/test.nc'}
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

[d,f]=get_files;

% Choose 'emea' or 'China' or 'World'
%[regs,nreg,lonlim,latlim]=find_region_numbers(reg);
[regs,nreg,~,~]=find_region_numbers(reg);


if ~exist(file,'file')
    error('File does not exist');
end
ncid=netcdf.open(file,'NC_NOWRITE');

varname='region'; varid=netcdf.inqVarId(ncid,varname);
region=netcdf.getVar(ncid,varid);

[ndim nvar natt udimid] = netcdf.inq(ncid); 
for varid=0:nvar-1
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
  if strcmp(varname,'lat') lat=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'lon') lon=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'latitude') latit=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'longitude') lonit=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'area') area=netcdf.getVar(ncid,varid); end
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


varname=vars; varid=netcdf.inqVarId(ncid,varname);
try
    description=netcdf.getAtt(ncid,varid,'description');
catch
    description=varname;
end

try
    units=netcdf.getAtt(ncid,varid,'units');
catch
    units='';
end
data=double(netcdf.getVar(ncid,varid));
[varname,xtype,dimids,natt] = netcdf.inqVar(ncid,varid);

% Find time dimension
ntime=1;
if numel(data)>length(data)
  idimid=find(udimid==dimids);
  tid=netcdf.inqVarId(ncid,netcdf.inqDim(ncid,udimid));
  time=netcdf.getvar(ncid,tid);
  itime=find(time>=timelim(1) & time<=timelim(2));
  if isempty(itime)
      error('Not data in specified time range')
  end
  time=time(itime);
  ntime=length(time);
end

netcdf.close(ncid);

if ~exist('area','var') area=ones(length(lat),1); end


ireg=find(lat>=latlim(1) & lat<=latlim(2) & lon>=lonlim(1) & lon<=lonlim(2));
nreg=length(ireg);
region=region(ireg);
lat=lat(ireg);
lon=lon(ireg);
area=area(ireg);

switch (varname)
    case 'region_neighbour', data=(data==0) ;
    otherwise ;
end

cmap=colormap('hotcold');
rlon=lon;
rlat=lat;


%% interpolate data to lat-time
latstep=3;
latlim=[min(lat)-0.5 max(lat)+0.5];
latgrid=linspace(latlim(1),latlim(2),floor((latlim(2)-latlim(1))/latstep));
nlat=length(latgrid);
gdata=zeros(nlat,ntime)+NaN;
for i=1:nlat
  ilat=find(lat>=latgrid(i)-latstep/2.0 & lat<latgrid(i)+latstep/2.0);
  if isempty(lat) continue; end
  %gdata(i,:)=mean(data(ireg(ilat),itime),1);   
  areasum=sum(area(ilat));
  gdata(i,:)=sum(data(ireg(ilat),itime).*repmat(area(ilat),1,ntime),1)/areasum;
  
end


%% plot map
figure(varid); 
clf reset;
cmap=colormap('hotcold');
set(varid,'DoubleBuffer','on');    
set(varid,'PaperType','A4');
hold on;

ncol=length(cmap);  

minmax=double([min(min(min(gdata))),max(max(max(gdata)))]);
ilim=find(isfinite(lim));
minmax(ilim)=lim(ilim);

resvar=round(((gdata-minmax(1)))./(minmax(2)-minmax(1))*(length(cmap)-1))+1;
resvar(resvar>length(cmap))=length(cmap);

 
titletext=description;
ht=title(titletext,'interpreter','none');
 

contourf(time,latgrid,resvar)
xlabel('Time (calendar year)');
ylabel('Latitude');


cb=colorbar;
if length(units)>0 
  switch (units)
        case 'unknown', units='A.U.';
        case '1', units='A.U.';
        otherwise ; 
  end
  title(cb,units); 
end

%set(gcf,'Position',[271   233   860   451])    
obj=findall(gcf,'-property','FontSize');
set(obj,'FontSize',16);

yt=get(cb,'YTick');
yr=minmax(2)-minmax(1);
ytl=scale_precision(yt/ncol*yr+minmax(1),3)';
set(cb,'YTickLabel',num2str(ytl));

xt=get(gca,'XTick');
i0=find(xt==0);
if ~isempty(i0)
  xtl=get(gca,'XTickLabel');
  len=length(xtl(i0,:));
  xtl(i0,1:len)=' ';
  if len<4 xtl(i0,1)='1';
  else xtl(i0,1:4)='1 AD';
  end
  set(gca,'XTickLabel',xtl);
end
    
    
    
    set(gcf,'UserData',cl_get_version);
 
    %% write map to file
    
    fdir=fullfile(d.plot,'variable',varname);
    if ~exist('fdir','dir') system(['mkdir -p ' fdir]); end
  
  bname=[varname '_time_lat_' num2str(nreg)];
  
  
  plot_multi_format(gcf,fullfile(fdir,bname));

end















