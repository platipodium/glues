function clp_nc_variable(varargin)

arguments = {...
  {'latlim',[-60 80]},...
  {'lonlim',[-180 180]},...
  {'timelim',[1,12]},...
  {'lim',[-inf,inf]},...
  {'reg','all'},...
  {'discrete',0},...
  {'vars','area'},...
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
  {'showsites',0}
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

[d,f]=get_files;

% Choose 'emea' or 'China' or 'World'
%[regs,nreg,lonlim,latlim]=find_region_numbers(reg);
[regs,nreg,~,~]=find_region_numbers(reg);


ncfile='../../src/test/regions.nc';
if ~exist(ncfile,'file')
    error('File does not exist');
end
ncid=netcdf.open(ncfile,'NC_NOWRITE');

[ndim nvar natt udimid] = netcdf.inq(ncid); 

varname='latitude'; varid=netcdf.inqVarId(ncid,varname);
lat=netcdf.getVar(ncid,varid);

varname='region'; varid=netcdf.inqVarId(ncid,varname);
region=netcdf.getVar(ncid,varid);

varname='longitude'; varid=netcdf.inqVarId(ncid,varname);
lon=netcdf.getVar(ncid,varid);

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

ireg=find(lat>=latlim(1) & lat<=latlim(2) & lon>=lonlim(1) & lon<=lonlim(2));
nreg=length(ireg);
region=region(ireg);
lat=lat(ireg);
lon=lon(ireg);

switch (varname)
    case 'region_neighbour', data=(data==0) ;
    otherwise ;
end

minmax=double([min(min(min(data(ireg,:)))),max(max(max(data(ireg,:))))]);
ilim=find(isfinite(lim));
minmax(ilim)=lim(ilim);


seacolor=0.7*ones(1,3);
landcolor=0.8*ones(1,3);  
cmap=colormap('hotcold');
rlon=lon;
rlat=lat;

for itime=1:ntime
  
  resvar=round(((data(ireg,itime)-minmax(1)))./(minmax(2)-minmax(1))*(length(cmap)-1))+1;
  resvar(resvar>length(cmap))=length(cmap);

  if (discrete>0)
    [b,i,j]=unique(resvar);
    resvar=resvar(i);
    rlat=lat(i);
    rlon=lon(i);
  end

  
  % plot map
  figure(varid); 
  clf reset;
  cmap=colormap('hotcold');
  set(varid,'DoubleBuffer','on');    
  set(varid,'PaperType','A4');
  hold on;
  pb=clp_basemap('lon',lonlim,'lat',latlim);
  if (marble>0)
    pm=clp_marble('lon',lonlim,'lat',latlim);
    if pm>0 alpha(pm,marble); end
  
  else
    m_coast('patch',landcolor);
    % only needed for empty (non-marble background) to get rid of lakes
    c=get(gca,'Children');
    ipatch=find(strcmp(get(c(:),'Type'),'patch'));
    npatch=length(ipatch);
    if npatch>0
      iwhite=find(sum(cell2mat(get(c(ipatch),'FaceColor')),2)==3);
      if ~isempty(iwhite) set(c(ipatch(iwhite)),'FaceColor',seacolor);
      end
    end
  
  end
 
  titletext=description;
  if (ntime>1) titletext=[titletext ' ' num2str(time(itime))]; end
  ht=title(titletext,'interpreter','none');
  
 
  %m_plot(lon,lat,'rs','MarkerSize',0.1);
  ncol=length(colormap);
  for i=1:ncol
    if i==1 j=find(resvar<=1);
    elseif i==ncol j=find(resvar>=ncol);
    else j=find(resvar==i);
    end
    
    if isempty(j) continue; end
    p(i)=m_plot(rlon(j),rlat(j),'rs','MarkerSize',0.1,'Color',cmap(i,:));  
  end
  
  cb=colorbar;
  if length(units)>0 title(cb,units); end
  yt=get(cb,'YTick');
  yr=minmax(2)-minmax(1);
  ytl=scale_precision(yt*yr+minmax(1),3)';
  set(cb,'YTickLabel',num2str(ytl));
  
  set(gcf,'UserData',cl_get_version);
 
  fdir=fullfile(d.plot,'variable',varname);
  if ~exist('fdir','dir') system(['mkdir -p ' fdir]); end
      
  bname=[varname '_' num2str(nreg)];
  if (ntime>1) bname = [bname '_' num2str(time(itime))]; end
  plot_multi_format(gcf,fullfile(fdir,bname));
end
end















