function cl_world_trajectory(varargin)

cl_register_function;

arguments = {...
  {'latlim',[-inf inf]},...
  {'lonlim',[-inf inf]},...
  {'timelim',[-8500,-1000]},...
  {'reg','all'},...
  {'variables','population_density'},...
  {'file','/Users/lemmen/devel/glues/eurolbk_base.nc'},...
};
[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

%%

if ~exist(file,'file')
    error('File does not exist');
end
ncid=netcdf.open(file,'NC_NOWRITE');


[ndim nvar natt udimid] = netcdf.inq(ncid); 
varid=netcdf.getConstant('GLOBAL');
modelversion=netcdf.getAtt(ncid,varid,'model_version');

for varid=0:nvar-1
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
  if strcmp(varname,'latitude'), lat=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'longitude'), lon=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'area'), area=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'region'), region=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'time')
    timeunit=netcdf.getAtt(ncid,varid,'units');
    time=netcdf.getVar(ncid,varid);
    time=cl_time2yearAD(time,timeunit);
  end
end

if ischar(variables) variables={variables}; end
nvar=length(variables);

for ivar=1:nvar
  try
    varid=netcdf.inqVarID(ncid,variables{ivar});
  catch 
    continue;
  end
  var(ivar).varid=varid;
  var(ivar).value=netcdf.getVar(ncid,varid);
  var(ivar).unit=netcdf.getAtt(ncid,varid,'units');
  var(ivar).name=netcdf.inqVar(ncid,varid);
end

%%

ntime=length(time);
nreg=length(region);
carea=repmat(area,[1 ntime]);

for ivar=1:nvar
  s=sum(var(ivar).value.*carea);
  if strfind(var(ivar).unit,'km-2')
    var(ivar).sum=s;
  else
    var(ivar).mean=s/nreg;
  end
end

outtable=zeros(ntime,nvar+1);
outtable(:,1)=time';
for ivar=1:nvar
  outtable(:,ivar+1)=var(ivar).sum/1E6;
end

itime=find(time>=timelim(1) & time<=timelim(2));
outtable=outtable(itime,:);
ntime=length(itime);
    
filename='Lemmen2011_worldpopulation';
%filename='Lemmen2010_worldpopulation';
fid=fopen([filename '.csv'],'wt');
%fid=1; % stdout
fprintf(fid,'# Global average/sum from GLUES model output\n');
fprintf(fid,'# Carsten Lemmen, <carsten.lemmen@hzg.de>\n');
fprintf(fid,'# Output produced: \t%s\n',datestr(now));
fprintf(fid,'# Model version: \t%s\n',modelversion);
fprintf(fid,'# Reference: \tLemmen et al. 2011, J. Archaeol. Sci\n');
%fprintf(fid,'# Reference: \tLemmen 2010, Geomorphologie\n');
fprintf(fid,'# File name: \t%s\n',file);
fprintf(fid,'# Number of columns: \t%d\n',nvar+1);
fprintf(fid,'# Column 1: time(year_AD)\n');
fprintf(fid,'# Column 2: global_population(million)\n');
fprintf(fid,'# Time;Population\n');
fprintf(fid,'%5d;%.2f\n',outtable');
if (fid~=1) fclose(fid); end

fs=15;
figure(1); clf reset;
set(gca,'FontSize',fs);
plot(outtable(:,1),outtable(:,2),'r-','LineWidth',4);
set(gca,'Xlim',cl_minmax(timelim)+[-200 200],'Ylim',[0 150]);
ylabel('World population (million)');
xlabel('Time (calendar year BC/AD)');
cl_year_one;
cl_bcad;
s=findobj('-property','FontSize');
set(s,'FontSize',fs);
text(-8500,120,'Lemmen et al., J. Archeol. Sci 2011','Color','r','FontSize',15);
%text(-8500,120,'Lemmen, Géomorphologie 2010','Color','r','FontSize',15);
cl_print('name',filename,'ext','pdf');


return;
end