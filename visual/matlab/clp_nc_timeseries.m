function retdata=clp_nc_timeseries(varargin)

%  {'latlim',[35,37]},...
%  {'lonlim',[62,64]},...
arguments = {...
  {'latlim',[3]},...
  {'lonlim',[4]},...
  {'tcoord','time'},...
  {'xcoord','x'},...
  {'ycoord','y'},...
  {'timelim',[3000 5000]},...
  {'lim',[-inf,inf]},...
  {'variables','var4'},...
  {'scale','absolute'},...
  {'figoffset',0},...
  {'timestep',1},...
  {'timeunit','month'},...
  {'file','data/Pakistantotprec_0_11k_JJAS.nc'},...
  {'mult',1},...
  {'div',1},...
  {'nosum',1},...
  {'nomean',1},...
  {'nearest',0},...
  {'nobar',0}
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

%[d,f]=get_files;

if ~exist(file,'file')
    error('File does not exist');
end
ncid=netcdf.open(file,'NC_NOWRITE');

[ndim nvar natt udimid] = netcdf.inq(ncid); 
for varid=0:nvar-1
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
  if strcmp(varname,ycoord)
    lat=netcdf.getVar(ncid,varid);
    latdimid=dimids;
  end
  if strcmp(varname,xcoord) 
    lon=netcdf.getVar(ncid,varid); 
    londimid=dimids;
  end
  if strcmp(varname,tcoord)
    time=netcdf.getVar(ncid,varid);
    timedimid=dimids;
    try tunit=netcdf.getAtt(ncid,varid,'units'); catch tunit=''; end
    if findstr('since',tunit) 
      unitstr=textscan(tunit,'%s %s %s');
      jstimeoffset=datenum(unitstr{3});
      timescale=lower(unitstr{1});
      switch (timescale{1})
        case 'months'
          jstime=jstimeoffset+datenum(0.0,double(time)+1,-1.0);
          if isinf(timelim) timelim=[min(time),max(time)]; end
          jstimelim=jstimeoffset+datenum(0.0,double(timelim)+1,-1.0);
        case 'days'
          jstime=jstimeoffset+datenum(0.0,0.0,double(time));
          if isinf(timelim) timelim=[min(time),max(time)]; end
          jstimelim=jstimeoffset+datenum(0.0,0.0,double(timelim));
        %case 'years',jstime=jstimeoffset+datenum(double(time));
      end
      tunit=timescale{1};
    elseif strcmp(tunit,'day as %Y%m%d.%f')
      year = floor(time/10000);
      month = floor(mod(time,10000)/100);
      day = floor(time/1000000);
      time=year+month/12.0+day/365.25;
      timeunit='year';
    end
    
  end
end

%% now treat case of non-coordinate variables for lat/lon 
% Todo: for time
for dimid=0:ndim-1
  [dimname,dimlen]=netcdf.inqDim(ncid,dimid);
  if strcmp(dimname,xcoord) && ~exist('londimid','var')
    lon=1:dimlen;
    londimid=dimid;
  elseif strcmp(dimname,ycoord) && ~exist('latdimid','var')
    lat=1:dimlen;
    latdimid=dimid;
  elseif strcmp(dimname,tcoord) && ~exist('timedimid','var')
    time=1:dimlen;
    timedimid=dimid;
  end
end

varname=variables; 
varid=netcdf.inqVarID(ncid,varname);
[varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);

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

% If data is organized along time dimension
if any(dimids==timedimid) && length(time)>1
  itime=find(time>=timelim(1) & time<=timelim(2));
  if isempty(itime)
      error('No data in specified time range')
  end
  itime=itime([1:timestep:length(itime)]);
  time=time(itime);
  if exist('jstime','var')  
    jstime=jstime(itime);
    time=jstime;
    timelim=jstimelim;
  end
  ntime=length(time);
else
  ntime=1;
end

% If data is organized along lat dimension
if length(latlim)==1 latlim(2)=latlim(1); end
if length(lonlim)==1 lonlim(2)=lonlim(1); end

if any(dimids==latdimid) && length(lat)>1
  ilat=find(lat>=latlim(1) & lat<=latlim(2));
  if isempty(ilat)
      error('No data in specified latitude range')
  end
  lat=lat(ilat);
  nlat=length(lat);
else
  nlat=1;
end


if all(lon>=0) && any(lon>180)
  islonpos=1;
  lon(lon>180)=lon(lon>180)-360;
  [lon,sortlon]=sort(lon);
  lonlen=length(lon);
else islonpos=0;
end

% If data is organized along lon dimension
if any(dimids==londimid) && length(lon)>1
  ilon=find(lon>=lonlim(1) & lon<=lonlim(2));
  if isempty(ilon)
      error('No data in specified longitude range')
  end
  lon=lon(ilon);
  nlon=length(lon);
else
  nlon=1;
end

if (~islonpos & dimids==[londimid latdimid timedimid])
  start=[ilon(1) ilat(1) itime(1)]-1;
  count=[nlon nlat ntime];
  stride=[1 1 timestep];
elseif (islonpos & dimids==[londimid latdimid timedimid])
  start=[1 ilat(1) itime(1)]-1;
  count=[lonlen nlat ntime];
  stride=[1 1 timestep];    
else
  error('Not implemented');
end

data=double(netcdf.getVar(ncid,varid,start,count,stride));

if islonpos
   data=data(sortlon,:,:);
   data=data(ilon,:,:);
end

if isnumeric(mult) data=data .* mult; 
else
  ffactor=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,mult),start,count,stride));    
  data = data .* repmat(ffactor,size(data)./size(ffactor));
end

if isnumeric(div) data=data ./ div; 
else
  ffactor=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,div)),start,count,stride);    
  data = data ./ repmat(ffactor,size(data)./size(ffactor));
end

netcdf.close(ncid);

%ilim=find(~isfinite(latlim));
%latlim(ilim)=lali(ilim);
%ilim=find(~isfinite(lonlim));
%lonlim(ilim)=loli(ilim);

if ~exist('area','var') area=ones(nlon,nlat,1); end
areasum=sum(sum(area));
area=repmat(area,[1,1],ntime);

minmax=double([min(min(min(data(:,:,:)))),max(max(max(data(:,:,:))))]);

ilim=find(isfinite(lim));
minmax(ilim)=lim(ilim);

%rlon=lon;
%rlat=lat;


figid=varid+figoffset;
figure(figid); 
clf reset;

set(figid,'DoubleBuffer','on');    
set(figid,'PaperType','A4');
hold on;

sdata=squeeze(sum(sum(data.*area,1),2));
mdata=sdata/areasum; 

lgray=0.8*ones(1,3);
a1=gca;

dlat=max([1,0.1*(latlim(2)-latlim(1))]);
dlon=max([1,0.1*(lonlim(2)-lonlim(1))]);

m_proj('miller','lat',latlim+[-dlat dlat],'lon',lonlim + [-dlon dlon]);
hold on;
set(a1,'YTick',[],'XTick',[]);

titletext=description;
ht=title(titletext,'interpreter','none');

if exist('jstime','var') 
  time=jstime; 
end

a2=axes('Color','none');
hold on;
for i=1:nlat 
  for j=1:nlon 
    if nobar
      pij(i,j)=plot(time,squeeze(data(j,i,:)),'c'); 
    else
      minmax(1)=0;
      pij(i,j)=bar(time,squeeze(data(j,i,:)),'c');
    end
  end
end
set(gca,'Ylim',minmax);


if isinf(timelim(1)) timelim(1)=time(1)-0.025*(time(end)-time(1)); end
if isinf(timelim(2)) timelim(2)=time(end)+0.025*(time(end)-time(1)); end
if exist('jstime','var')
    datetick(gca);
else
  if strcmp(timeunit,'year') & any(time<0) cl_year_one(gca); end
  xlabel(timeunit);
end
set(gca,'XLim',timelim);
ylabel(description);

hold on;
if length(data)>length(mdata)
  p1=plot(time,mdata,'b','Linewidth',2);
end

% Plot annual mean
if exist('jstime','var')
  [year,month,day]=datevec(jstime);
  uyear=unique(year);
  nyear=length(uyear);
  for i=1:nyear
    iy=find(year==uyear(i));
    annual(i)=sum(mdata(iy));
  end
  pannual=plot(datenum(uyear,1,1),annual,'r-','LineWidth',5);
end


if 1==0 %% only for SI / qfarming
  threshold=1/3.0;
  fdata=data;
  fdata(ffactor(ireg,itime)<threshold)=0;
  fmdata=sum(fdata.*area,1)/areasum;
  
  fdata(ffactor(ireg,itime)<threshold)=NaN;
  p2=plot(time,fdata','g')
  p3=plot(time,fmdata,'r:','linewidth',5);
end
  

if (~nosum)
  a3=axes('Color','none','YAxisLocation','right');
  hold on;
  % For SAA paper
  %p2=plot(time,sdata/1E6,'r--','Linewidth',5);
  %set(a3,'XTick',[],'Ylim',[0 10.5],'XLim',timelim);
  plot(time,sdata,'r--','Linewidth',5);
  ylabel('Size');

  %l=legend([p1,p2],'Mean','Total','Location','NorthWest');
  %set(l,'color','w');
end

% dump ascii table
%fprintf('%d %d %d\n',[time' ; mdata ; log(2)./mdata])

%% Print to file
fdir=fullfile('../plot','variable',varname);
if ~exist('fdir','dir') system(['mkdir -p ' fdir]); end  
bname=['timeseries_' varname];
plot_multi_format(gcf,fullfile(fdir,bname));

%fprintf('Total %d million at %d on area of %d million sqkm.\n',...
%    sdata(ntime)/1E6, time(ntime), areasum);

if nargout>0 retdata=squeeze(data); end

end
















