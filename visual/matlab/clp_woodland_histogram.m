function rdata=clp_nc_woodland_histogram(varargin)

arguments = {...
  {'latlim',[30 50]},...
  {'lonlim',[-108 -60]},...
  {'timelim',[-4000,1500]},...
  {'reg','all'},...
  {'variables','farming'},...
  {'threshold',0.5},...
  {'scale','absolute'},...
  {'figoffset',0},...
  {'ylimit',[-Inf,Inf]},...
  {'timeunit','BP'},...
  {'timestep',1},...
  {'marble',0},...
  {'seacolor',0.7*ones(1,3)},...
  {'landcolor',.8*ones(1,3)},...
  {'transparency',1},...
  {'snapyear',1000},...
  {'movie',1},...
  {'cmap',0},...
  {'projection','miller'},...
  {'showsites',0},...
  {'notitle',0}...
  {'nocbar',0}...
  {'file','../../test.nc'}
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

[d,f]=get_files;

% Choose 'emea' or 'China' or 'World'
%[regs,nreg,lonlim,latlim]=find_region_numbers(reg);
[ireg,nreg,loli,lali]=find_region_numbers(reg);


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


varname=variables; varid=netcdf.inqVarId(ncid,varname);
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
  itime=itime([1:timestep:length(itime)]);
  
  time=time(itime);
  ntime=length(time);
end

netcdf.close(ncid);




%% Make directory for plots and prepare files  
  
fd=fullfile(d.plot,'variable');
if ~exist(fd,'file') mkdir(fd); end
  
fd=fullfile(fd,'timing');
if ~exist(fd,'file') mkdir(fd); end
   
   
figure(1+figoffset); 
clf reset;
set(gcf,'DoubleBuffer','on','ActivePositionProperty','outerposition');    
set(gcf,'PaperType','A4');
hold on;
  
%% Add title and determine time units
titletext=['Time of farming > ' num2str(threshold) ];
if ~notitle ht=title(titletext,'interpreter','none'); end
 
ireg=ireg(find(lat>=latlim(1) & lat <=latlim(2) & lon>=lonlim(1) & lon<=lonlim(2))); 
nreg=length(ireg);  

data=data(ireg,itime);

for i=1:nreg
  ftime=find(data(i,:)>=threshold);
  if isempty(ftime) timing(i)=NaN; else timing(i)=time(min(ftime)); end
end
 
minmax=[min(timing),max(timing)];
ylimit(~isfinite(ylimit))=minmax(~isfinite(ylimit));
 
ivalid=find(isfinite(timing));
edges=[timelim(1)-100:500:timelim(2)+100];
[n,bin]=histc(timing(ivalid),edges);
p2=bar(edges,n/max(n),'histc');
set(p2,'FaceAlpha',0.7);
set(gca,'Xlim',[timelim(1)-100 timelim(2)+100],'Ylim',[0 1.1]);
cl_year_one(gca);

fprintf('Model data max %d of %d\n',max(n), sum(n));


obj=findall(gcf,'-property','FontSize');
set(obj,'FontSize',15);

plotname=fullfile(fd,['woodland_histogram_']);
plotname=[plotname sprintf('%03d_%03d_',latlim(1),latlim(2))];      

file=['/h/lemmen/projects/glues/tex/2010/saa/card/table_Woodland.csv'];
  
  fid = fopen(file);
  site = textscan(fid, '%s%s%s%s%s%f%f','Delimiter',';','HeaderLines',1,'CommentStyle','#');
  fclose(fid);
  age=site{6};
  
  q=quantile(age,[0 0.05 0.5 0.95 1]);
  qr=round(q);
  %age=age(age>q(2) & age < q(4));
  
  mi=min(age);
  ma=max(age);
  
 wedges=[timelim(1)-100:100:timelim(2)+100];

 [nw,bin]=histc(1950-age,wedges);
 hold on;
 p4=bar(wedges,nw/max(nw),'histc');
 set(p4,'Facecolor','r','FaceAlpha',0.7);
 
 p5=bar(edges,n/max(n),'histc');
 set(p5,'Facecolor','none','LineWidth',4,'EdgeColor','b');
 

fprintf('Site data max %d of %d\n',max(nw),sum(nw));


plot_multi_format(gcf,plotname);
  
hold off;

return;
end

