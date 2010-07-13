function [retdata,basename]=clp_nc_variable(varargin)

arguments = {...
  {'latlim',[-60 80]},...
  {'lonlim',[-180 180]},...
  {'timelim',[-9000,1960]},...
  {'lim',[-inf,inf]},...
  {'reg','all'},...
  {'discrete',0},...
  {'variables','npp'},...
  {'scale','absolute'},...
  {'figoffset',0},...
  {'timeunit','BP'},...
  {'timestep',20},...
  {'marble',0},...
  {'seacolor',0.7*ones(1,3)},...
  {'landcolor',.8*ones(1,3)},...
  {'transparency',1},...
  {'snapyear',1000},...
  {'movie',1},...
  {'mult',1},...
  {'div',1},...
  {'showsites',0},...
  {'file','../../test.nc'},...
  {'retdata',NaN},...
  {'basename','variable'},...
  {'nocolor',0},...
  {'ncol',19},...
  {'nogrid',0}
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

[d,f]=get_files;

% Choose 'emea' or 'China' or 'World'
%[regs,nreg,lonlim,latlim]=find_region_numbers(reg);
[ireg,nreg,~,~]=find_region_numbers(reg);


if ~exist(file,'file')
    error('File does not exist');
end
ncid=netcdf.open(file,'NC_NOWRITE');

varname='region'; varid=netcdf.inqVarID(ncid,varname);
region=netcdf.getVar(ncid,varid);

[ndim nvar natt udimid] = netcdf.inq(ncid); 
for varid=0:nvar-1
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
  if strcmp(varname,'lat') lat=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'lon') lon=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'latitude') latit=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'longitude') lonit=netcdf.getVar(ncid,varid); end
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
  factor=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,mult)));    
  data = data .* repmat(factor,size(data)./size(factor));
end

if isnumeric(div) data=data ./ div; 
else
  factor=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,div)));    
  data = data ./ repmat(factor,size(data)./size(factor));
end

if length(timelim)==1 timelim(2)=timelim(1); end


% Find time dimension
ntime=1;
if numel(data)>length(data)
  idimid=find(udimid==dimids);
  tid=netcdf.inqVarID(ncid,netcdf.inqDim(ncid,udimid));
  time=netcdf.getvar(ncid,tid);
  itime=find(time>=timelim(1) & time<=timelim(2));
  if isempty(itime)
      error('Not data in specified time range')
  end
  itime=itime([1:timestep:length(itime)]);
  
  time=time(itime);
  ntime=length(time);
end

netcdf.close(ncid);

%ireg=find(lat>=latlim(1) & lat<=latlim(2) & lon>=lonlim(1) & lon<=lonlim(2));
%nreg=length(ireg);
region=region(ireg);
lat=lat(ireg);
lon=lon(ireg);

switch (varname)
    case 'region_neighbour', data=(data==0) ;
    otherwise ;
end

minmax=double([min(min(min(data(ireg,itime)))),max(max(max(data(ireg,itime))))]);
ilim=find(isfinite(lim));
minmax(ilim)=lim(ilim);


seacolor=0.7*ones(1,3);
landcolor=0.8*ones(1,3);  


if (nocolor==0) cmap=colormap(jet(ncol));
else cmap=colormap(flipud(gray(ncol)));
end
rlon=lon;
rlat=lat;

  % plot map
  figure(varid); 
  clf reset;
  if (nocolor==0) cmap=colormap(jet(ncol));
  else cmap=colormap(flipud(gray(ncol)));
  end
  set(varid,'DoubleBuffer','on');    
  set(varid,'PaperType','A4');
  hold on;
  pb=clp_basemap('lon',lonlim,'lat',latlim,'nogrid',nogrid);
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

ncol=length(colormap);



  %% Invisible plotting of all regions
  hp=clp_regionpath('lat',latlim,'lon',lonlim,'draw','patch','col',landcolor,'reg',reg);  
  ival=find(hp>0);
  %alpha(hp(ival),0);
  

%% Time loop

for it=1:ntime
  
  resvar=round(((data(ireg,itime(it))-minmax(1)))./(minmax(2)-minmax(1))*(length(cmap)-1))+1;
  resvar(resvar>length(cmap))=length(cmap);

  if (discrete>0)
    [b,i,j]=unique(resvar);
    resvar=resvar(i);
    rlat=lat(i);
    rlon=lon(i);
  end
  
  titletext=description;
  if (ntime>1) titletext=[titletext ' ' num2str(time(it))]; end
  ht=title(titletext,'interpreter','none');

 
  %m_plot(lon,lat,'rs','MarkerSize',0.1);
  for i=1:ncol
    if i==1 j=find(resvar<=1);
    elseif i==ncol j=find(resvar>=ncol);
    else j=find(resvar==i);
    end
    
    if isempty(j) continue; end
    for ij=1:length(j)
      h=hp(j(ij));
      if isnan(h) || h==0 continue; end
      greyval=0.15+0.35*sqrt(i./ncol);
      %alpha(h,greyval);
      set(h,'FaceColor',cmap(i,:));
    end
  end

  if (it==1)
    cb=colorbar('FontSize',15);
    if length(units)>0 title(cb,units); end
    yt=get(cb,'YTick');
    yr=minmax(2)-minmax(1);
    ytl=scale_precision(yt*yr+minmax(1),3)';
    set(cb,'YTickLabel',num2str(ytl));
  
    set(gcf,'UserData',cl_get_version);
 
    fdir=fullfile(d.plot,'variable',varname);
    if ~exist('fdir','dir') system(['mkdir -p ' fdir]); end
  end
  
  obj=findall(gcf,'-property','FontSize');
  set(obj,'FontSize',15);
  
  bname=[varname '_' num2str(nreg)];
  
  if (ntime>1) bname = [bname '_' num2str(time(it))]; end
  plot_multi_format(gcf,fullfile(fdir,bname));
  %pause(0.05);
end
end















