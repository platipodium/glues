function [retdata,basename,currentaxis]=clp_nc_trajectory(varargin)

%Woodland area
%  {'latlim',[30 50]},...
%  {'lonlim',[-108 -60]},...


arguments = {...
%  {'latlim',[-60 80]},...
 % {'lonlim',[-180 180]},...
  {'latlim',[-inf inf]},...
  {'lonlim',[-inf inf]},...
  {'dlat',0.3},...
  {'xcoord','lon'},...
  {'ycoord','lat'},...
  {'timelim',[-9000,-1000]},...
  {'lim',[-inf,inf]},...
  {'reg','all'},...
  {'discrete',0},...
  {'variables','population_density'},...
  {'scale','absolute'},...
  {'figoffset',0},...
  {'timeunit','BP'},...
  {'timestep',1},...
  {'sce',''},...
  {'mult',1},...
  {'div',1},...
  {'file','../../euroclim_0.4.nc'},...
  {'nosum',0},...
  {'showmap',2},...
  {'nocolor',0},...
  {'retdata',NaN},...
  {'basename','trajectory'},...
  {'nearest',0},...
  {'noprint',0},...
  {'axiscolor',[0.8 0.8 0.8]},...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

[d,f]=get_files;

% Color selection
if (nocolor==0)
  lc={'c' 'b' 'g' 'r'};
  ls='---:';
  lw=[1 5 5 5];
else
  lc={repmat(0.4,3,1) 'k' 'k' 'k'};
  ls='---:';
  lw=[1 5 5 5];
end


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

if ~exist('region','var')
  region=1:length(lat);
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


if ischar(variables)
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
elseif isnumeric(variables)
  data=variables;
  description='1';
  units='';
  varname='1';
end


if isnumeric(mult) 
  data=data .* mult;
  if (mult~=1) varname=[varname '_mult_' num2str(mult)]; end
else
  ffactor=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,mult)));    
  if (length(data)>1) data = data .* repmat(ffactor,size(data)./size(ffactor));
  else data = data .* ffactor;
  end
  varname=[varname '_mult_' mult];  
end


if isnumeric(div) 
  data=data ./ div; 
  if (div~=1) varname=[varname '_div_' num2str(div)]; end
else
  ffactor=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,div)));    
  if (length(data)>1) data = data ./ repmat(ffactor,size(data)./size(ffactor));
  else data=data ./ ffactor;
  end
  varname=[varname '_div_' div];
end


% Find time dimension
ntime=1;
if numel(data)>length(data)
  idimid=find(udimid==dimids);
  tid=netcdf.inqVarID(ncid,netcdf.inqDim(ncid,udimid));
  time=netcdf.getVar(ncid,tid);
  timeunit=netcdf.getAtt(ncid,tid,'units');
  time=cl_time2yearAD(time,timeunit);
  itime=find(time>=timelim(1) & time<=timelim(2));
  if isempty(itime)
      error('Not data in specified time range')
  end
  itime=itime([1:timestep:length(itime)]);
  
  time=time(itime);
  ntime=length(time);
end

netcdf.close(ncid);

if ~exist('area','var') area=ones(length(lat),1); end

ilim=find(~isfinite(latlim));
latlim(ilim)=lali(ilim);
ilim=find(~isfinite(lonlim));
lonlim(ilim)=loli(ilim);

inbounds=find(lat(ireg)>=latlim(1) & lat(ireg)<=latlim(2) & lon(ireg)>=lonlim(1) & lon(ireg)<=lonlim(2));
if isempty(inbounds) && (nearest==1)
  error('Not Implemented yet');
else ireg=ireg(inbounds);
end
nreg=length(ireg);
region=region(ireg);
lat=lat(ireg);
lon=lon(ireg);
areasum=sum(area(ireg));
area=repmat(area(ireg),1,ntime);

switch (varname)
    case 'region_neighbour', data=(data==0) ;
    otherwise ;
end

%data=data*0.04;

minmax=double([min(min(min(data(ireg,itime)))),max(max(max(data(ireg,itime))))]);
ilim=find(isfinite(lim));
minmax(ilim)=lim(ilim);
if numel(minmax)==1  minmax=minmax.*[0.99,1.01]; end;
if minmax(1)==minmax(2) minmax=minmax.*[0.99,1.01]; end

rlon=lon;
rlat=lat;

%% Figure creation
% Create new figure
  varid=varid+figoffset;
  figure(varid); 
  clf reset;

  set(varid,'DoubleBuffer','on');    
  set(varid,'PaperType','A4');
  
hold on;

data=data(ireg,itime);
sdata=sum(data.*area,1);
mdata=sdata/areasum; 

lgray=0.8*ones(1,3);
if (showmap>0)
  a1=gca;
  mlim=dlat*(max(latlim(2)-latlim(1),lonlim(2)-lonlim(1))*[-1 1]);
  mlatlim=[max([latlim(1)+mlim(1),-90]),min([latlim(2)+mlim(2),90])];
  mlonlim=[max([lonlim(1)+mlim(1),-180]),min([lonlim(2)+mlim(2),180])];
  m_proj('miller','lat',mlatlim,'lon',mlonlim);
  m_coast('patch',lgray,'facealpha',0.3,'edgecolor','none');
  m_line(lonlim([1 2 2 1 1]),latlim([1 1 2 2 1]),'Color','r','LineStyle','--');
  hold on;
  xl=get(gca,'Xlim');
  yl=get(gca,'Ylim');
  set(a1,'YTick',[],'XTick',[],'FontSize',15);
  set(a1,'Xlim',xl,'Ylim',yl);
  a2=axes;
else
  a2=gca;
end

axes(a2);
set(gca,'Color','none','XColor',axiscolor,'YColor',axiscolor);

hold on;
p0=plot(time,data','k-','Color',lc{1},'LineStyle',ls(1),'LineWidth',lw(1));
set(gca,'Xlim',timelim,'Ylim',minmax,'FontSize',15);
cl_year_one(gca);
xlabel('Calendar year','FontSize',15);
ylabel('Density','FontSize',15);
titletext=description;
ht=title(titletext,'interpreter','none');

hold on;
p1=plot(time,mdata,'k-','Color',lc{2},'LineStyle',ls(2),'Linewidth',lw(2));

if (showmap==2)
  pos=get(a2,'position');
  pscale=0.3;
  set(a1,'position',[pos(1)+(1-pscale)*pos(3) pos(2)+(1-pscale)*pos(4) pscale*pos(3) pscale*pos(4)])    
    
end

if 1==0 %% only for SI / qfarming
  threshold=1/3.0;
  fdata=data;
  fdata(ffactor(ireg,itime)<threshold)=0;
  fmdata=sum(fdata.*area,1)/areasum;
  
  fdata(ffactor(ireg,itime)<threshold)=NaN;
  p2=plot(time,fdata','k-','Color',lc{3},'LineStyle',ls(3));
  p3=plot(time,fmdata,'k-','Color',lc{4},'LineStyle',ls(4),'linewidth',5);
end
  

if (~nosum)
  a3=axes('Color','none','YAxisLocation','right','FontSize',15,'Xcolor',axiscolor,'YColor',axiscolor);

  hold on;
  % For SAA paper
  p2=plot(time,sdata/1E6,'k-','Color',lc{4},'Linewidth',5,'LineStyle','--');
  set(a3,'XTick',[],'Ylim',[0 10.5],'XLim',timelim,'FontSize',15);
  ylabel('Size','FontSize',15);

  %l=legend([p1,p2],'Mean','Total','Location','NorthWest');
  %set(l,'color','w');
end

obj=findall(gcf,'-property','FontSize');
set(obj,'FontSize',15,'Color',axiscolor);

% dump ascii table
%fprintf('%d %d %d\n',[time' ; mdata ; log(2)./mdata])

%% print to file
fdir=fullfile(d.plot,'variable',varname);
if ~exist('fdir','dir') system(['mkdir -p ' fdir]); end  
bname=['trajectory_' varname '_' num2str(nreg)];
if length(sce)>0 bname=[bname '_' sce]; end
if ~noprint
  cl_print('name',fullfile(fdir,bname),'ext','pdf');
end
  
fprintf('Total %d million at %d on area of %d million sqkm.\n',...
    sdata(ntime)/1E6, time(ntime), areasum);

if nargout>2 currentaxis=a2; end
if nargout>1 basename=fullfile(fdir,bname); end
if nargout>0 retdata=data; end

end















