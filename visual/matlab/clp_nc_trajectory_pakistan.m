function clp_nc_trajectory_pakistan(varargin)

%Woodland area
%  {'latlim',[30 50]},...
%  {'lonlim',[-108 -60]},...


arguments = {...
  {'latlim',[-inf inf]},...
  {'lonlim',[-inf inf]},...
  {'xcoord','lon'},...
  {'ycoord','lat'},...
  {'timelim',[-inf,-inf]},...
  {'lim',[-inf,inf]},...
  {'reg','all'},...
  {'discrete',0},...
  {'variables','var4'},...
  {'scale','absolute'},...
  {'figoffset',0},...
  {'timeunit','BP'},...
  {'timestep',1},...
  {'sce',''},...
  {'mult',1},...
  {'div',1},...
  {'file','/Users/lemmen/Downloads/Pakistantotprec_0_11_ANM.nc'},...
  {'nosum',0}
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

[d,f]=get_files;

% Choose 'emea' or 'China' or 'World'
%[regs,nreg,lonlim,latlim]=find_region_numbers(reg);
if isnumeric(reg) 
  ireg=reg; nreg=length(reg); lali=latlim; loli=lonlim;
else
[ireg,nreg,loli,lali]=find_region_numbers(reg);
end

if ~exist(file,'file')
    error('File does not exist');
end
ncid=netcdf.open(file,'NC_NOWRITE');


[ndim nvar natt udimid] = netcdf.inq(ncid); 
for varid=0:nvar-1
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
  if strcmp(varname,ycoord), lat=netcdf.getVar(ncid,varid); end
  if strcmp(varname,xcoord), lon=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'latitude'), latit=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'longitude'), lonit=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'area'), area=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'region'), region=netcdf.getVar(ncid,varid); end
end

lat = [24.91993, 30.45755, 35.99508];
% 19.38223, 24.91993, 30.45755, 35.99508, 41.53246, 

lon = [56.25, 61.875, 67.5, 73.125];
% 56.25, 61.875, 67.5, 73.125, 78.75, 


varname=variables; varid=netcdf.inqVarID(ncid,varname);
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

if isnumeric(mult) data=data .* mult; 
else
  ffactor=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,mult)));    
  data = data .* repmat(ffactor,size(data)./size(ffactor));
end

if isnumeric(div) data=data ./ div; 
else
  ffactor=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,div)));    
  data = data ./ repmat(ffactor,size(data)./size(ffactor));
end


% Find time dimension
ntime=1;
if numel(data)>length(data)
  idimid=find(udimid==dimids);
  tid=netcdf.inqVarID(ncid,netcdf.inqDim(ncid,udimid));
  time=netcdf.getvar(ncid,tid);
  ntime=length(time);
  if isfinite(timelim) itime=find(time>=timelim(1) & time<=timelim(2));
  else itime = 1:ntime;
  end    
  if isempty(itime)
      error('Not data in specified time range')
  end
  itime=itime([1:timestep:length(itime)]);
  
  time=time(itime);
  ntime=length(time);
end


netcdf.close(ncid);
time=round(time/10000);
data=data*365.25;

if ~exist('area','var') area=ones(length(lat),1); end

ilim=find(~isfinite(latlim));
latlim(ilim)=lali(ilim);
ilim=find(~isfinite(lonlim));
lonlim(ilim)=loli(ilim);

latlim=[23,37]
lonlim=[60,75];

minmax=[min(min(min(data))),max(max(max(data)))];
minmax(1)=0;
ilim=find(isfinite(lim));
minmax(ilim)=lim(ilim);

figure(1);
clf reset;

lgray=0.8*ones(1,3);


titletext=description;
ht=title(titletext,'interpreter','none');
timelim=[min(time),max(time)];

a2=axes('Color','none');
hold on;

nlat=length(lat);
nlon=length(lon);

description='PANM (mm)'

for ilat=1:nlat
  for ilon=1:nlon
  subplot(nlat,nlon,(nlat-ilat)*nlon+ilon);

  v=squeeze(data(ilon,ilat,:));
  plot(time,v,'k');
  m=movavg(time,v,500);
  hold on;
  plot(time,m,'b','linew',4);
  
  
  set(gca,'Xlim',timelim,'Ylim',minmax);
  xlabel('Year (sim/BP)?');
  ylabel(description);
  text(400,minmax(2)*0.8,sprintf('%.1fE %.1fN',lon(ilon),lat(ilat)),'color','r');
  end
end
  
  
hold on;

% dump ascii table
%fprintf('%d %d %d\n',[time' ; mdata ; log(2)./mdata])

%% Print to file
fdir=fullfile(d.plot,'variable',varname);
if ~exist('fdir','dir') system(['mkdir -p ' fdir]); end  
bname=['trajectory_pakistan_' varname ];
if length(sce)>0 bname=[bname '_' sce]; end
plot_multi_format(gcf,fullfile(fdir,bname));


end















