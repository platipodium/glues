function clp_nc_region_dat(varargin)

arguments = {...
  {'latlim',[20 60]},...
  {'lonlim',[-10 30]},...
  {'lim',[-inf,inf]},...
  {'reg','eur'},...
  {'discrete',0},...
  {'vars','area'},...
  {'scale','absolute'},...
  {'figoffset',0},...
  {'marble',0},...
  {'seacolor',0.7*ones(1,3)},...
  {'landcolor',.8*ones(1,3)},...
  {'transparency',1},...
  {'snapyear',1000},...
  {'movie',1},...
  {'showsites',0},...
  {'file','../../src/test/regions_11k_685.nc'}
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

[d,f]=get_files;
[regs,nreg,~,~]=find_region_numbers(reg);


if ~exist(file,'file')
    error('File does not exist');
end
ncid=netcdf.open(file,'NC_NOWRITE');

varname='region'; varid=netcdf.inqVarID(ncid,varname);
region=netcdf.getVar(ncid,varid);
varname='region_neighbour'; varid=netcdf.inqVarID(ncid,varname);
neigh=netcdf.getVar(ncid,varid);
varname='number_of_neighbours'; varid=netcdf.inqVarID(ncid,varname);
nneigh=netcdf.getVar(ncid,varid);


%% print debug neighbour relationships
if (0)
  for i=1:length(region)
    fprintf('%d %d',i,nneigh(i));
    for j=1:nneigh(i)
      fprintf(' %d',neigh(i,j));
    end
    fprintf('\n');
  end
end

%% Read all variables from netcdf file

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


varname=vars; varid=netcdf.inqVarID(ncid,varname);
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

netcdf.close(ncid);

ireg=find(lat>=latlim(1) & lat<=latlim(2) & lon>=lonlim(1) & lon<=lonlim(2));
nreg=length(ireg);
region=region(ireg);
%lat=lat(ireg);
%lon=lon(ireg);

minmax=double([min(min(min(data(ireg)))),max(max(max(data(ireg))))]);
ilim=find(isfinite(lim));
minmax(ilim)=lim(ilim);

seacolor=0.7*ones(1,3);
landcolor=0.8*ones(1,3);  
cmap=colormap('hotcold');
cmap=colormap('jet');
rlon=lon;
rlat=lat;

  % plot map
figure(varid); 
clf reset;
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
    if ~isempty(iwhite) set(c(ipatch(iwhite)),'FaceColor',seacolor); end
  end
end

%% plot region centers and neighbour relations
%pr=m_plot(lon(ireg),lat(ireg),'rs','MarkerSize',2);  
nreg=length(region);
[x,y]=m_ll2xy(lon(ireg),lat(ireg));
rlat=lat+NaN;rlat(ireg)=lat(ireg);
rlon=lon+NaN;rlon(ireg)=lon(ireg);
for i=1:nreg 
  %text(x(i),y(i),num2str(region(i)));
  %m_text(lon(i),lat(i)+0.2,num2str(region(i)),'HorizontalAlignment','center');
  %m_text(lon(i),lat(i)+0.2,num2str(region(i)));
  for j=1:nneigh(region(i))
    in=neigh(region(i),j);
    if in<1 continue; end
    m_plot(rlon([region(i),in]),rlat([region(i),in]),'r-');
  end
  
end



%% overplot variable
lon=lon(ireg); rlon=lon;
lat=lat(ireg); rlat=lat;
ncol=length(colormap);

resvar=round(((data(ireg)-minmax(1)))./(minmax(2)-minmax(1))*(length(cmap)-1))+1;
resvar(resvar>length(cmap))=length(cmap);

if (discrete>0)
    [b,i,j]=unique(resvar);
    resvar=resvar(i);
    rlat=lat(i);
    rlon=lon(i);
  end

  
 
  titletext=description;
  ht=title(titletext,'interpreter','none');
  
  for i=1:ncol
    if i==1 j=find(resvar<=1);
    elseif i==ncol j=find(resvar>=ncol);
    else j=find(resvar==i);
    end
    
    if isempty(j) p(i)=NaN; continue; end
    p(i)=m_plot(rlon(j),rlat(j),'rs','MarkerSize',100/abs(lonlim(2)-lonlim(1)),'Color',cmap(i,:));  
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
  
  plot_multi_format(gcf,fullfile(fdir,bname));

end















