function clp_nc_variable_lon_time(varargin)

arguments = {...
  {'latlim',[-60 80]},...
  {'lonlim',[-180 180]},...
  {'timelim',[-9500,-1000]},...
  {'lim',[-inf,inf]},...
  {'reg','all'},...
  {'discrete',0},...
  {'vars','migration_density'},...
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
lonstep=10;
lonlim=[min(lon)-0.5 max(lon)+0.5];
longrid=linspace(lonlim(1),lonlim(2),floor((lonlim(2)-lonlim(1))/lonstep));
nlon=length(longrid);
gdata=zeros(nlon,ntime)+NaN;
for i=1:nlon
  ilon=find(lon>=longrid(i)-lonstep/2.0 & lon<longrid(i)+lonstep/2.0);
  if isempty(lon) continue; end
  %gdata(i,:)=mean(data(ireg(ilon),itime),1);   
  areasum=sum(area(ilon));
  gdata(i,:)=sum(data(ireg(ilon),itime).*repmat(area(ilon),1,ntime),1)/areasum;
  
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
 

contourf(longrid,time,resvar')
ylabel('Time (calendar year)');
xlabel('lonitude');


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

yt=get(gca,'YTick');
i0=find(yt==0);
if ~isempty(i0)
  ytl=get(gca,'YTickLabel');
  len=length(ytl(i0,:));
  ytl(i0,1:len)=' ';
  if len<4 ytl(i0,1)='1';
  else ytl(i0,1:4)='1 AD';
  end
  set(gca,'YTickLabel',ytl);
end
    
    
    
    set(gcf,'UserData',cl_get_version);
 
    %% write map to file
    
    fdir=fullfile(d.plot,'variable',varname);
    if ~exist('fdir','dir') system(['mkdir -p ' fdir]); end
  
  bname=[varname '_lon_time_' num2str(nreg)];
  
  
  plot_multi_format(gcf,fullfile(fdir,bname));

end















