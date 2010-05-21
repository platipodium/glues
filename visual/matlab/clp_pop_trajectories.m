function rdata=clp_pop_trajectories(varargin)

global ivar nvar figoffset;

arguments = {...
  {'regions','all'},...
  {'vars','Density'},...
  {'scale','absolute'},...
  {'figoffset',0},...
  {'ylim',[-Inf,Inf]},...
  {'timelim',[12000 500]},...
  {'timeunit','BP'},...
  {'timestep',100},...
};


cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

[d,f]=get_files;

% Choose 'emea' or 'China' or 'World'
%[regs,nreg,lonlim,latlim]=find_region_numbers(reg);
[regs,nreg,~,~]=find_region_numbers(regions);

resultfilename='results';
  
if exist([resultfilename '.mat'],'file') load(resultfilename); else 
    fprintf('Cannot find file %s\n',resultfilename);
    error('No result file read')
    return; 
end

infix=strrep(resultfilename,'results','');
if length(infix)>0
  while infix(1)=='_' infix=infix(2:end); end
end

ntime=size(r.Density,2);
 
nvar=1; 
m=strmatch(vars,r.variables,'exact');
if isempty(m)
  error('Variable Density not found in result file. Exited.');
else dovar=m; 
end
 
if ~exist('dovar','var') return; end;

dovar=dovar(find(dovar>0));
nvar=length(dovar);

isbp=1;
if all(r.time>=0)
  toffset=500;
  tstart=min([r.tend+toffset,timelim(1)]);
  tend=max([r.tstart+toffset,timelim(2)]);
  r.time=r.time+toffset;
else
  tstart=max([r.tstart,2000-timelim(1)]);
  tend=min([r.tend,2000-timelim(2)]);
  timeunit='AD';
  isbp=0;
end


%% Read area from netcdf file
ncid=netcdf.open('../../src/test/regions_11k_685.nc','NOWRITE');
varid=netcdf.inqVarId(ncid,'area');
area=netcdf.getVar(ncid,varid);
netcdf.close(ncid);


%% Read arve region mapping
arvefile='/h/lemmen/projects/glues/tex/2010/holopop/arve/popregions6.nc';
ncid=netcdf.open(arvefile,'NOWRITE');

aid=netcdf.getVar(ncid,netcdf.inqVarId(ncid,'z'));
alat=netcdf.getVar(ncid,netcdf.inqVarId(ncid,'lat'));
alon=netcdf.getVar(ncid,netcdf.inqVarId(ncid,'lon'));


arvekey='/h/lemmen/projects/glues/tex/2010/holopop/arve/pop_region_key2.txt';
fid = fopen(arvekey);
C = textscan(fid, '  %d %s');
key = C{1};
name = C{2};
fclose(fid);

%%

time=r.time;
    
[tmax,itend]=min(abs(time-tend));
[tmin,itstart]=min(abs(time-tstart));

timespan=abs(time(itstart)-time(itend));
ntime=ceil(timespan/timestep);
itime=itstart:ceil((itend-itstart)/ntime):itend;
if itime(end)~=itend itime=[itime itend]; end
time=time(itime);

retdata=zeros(nvar,itend-itstart+1,length(regs))+NaN;

ivar=dovar(1);
data=eval(['r.' r.variables{ivar}]);

data=data.*repmat(area,1,size(data,2));

retdata(1,:,:)=data(squeeze(regs),itstart:itend)';

ydata=sum(data(regs,itstart:itend),1);
xdata=r.time(itstart:itend);
minmax=[min(min(ydata)),max(max(ydata))];
  
resvar=data;

  
regions={'sam','nam','old','afr','emea','chi','sea','med','eur','ind'};
regions={'all'};
nregions=length(regions);

cmap=colormap(jet(nregions));


tmin=min(r.time(itstart:itend));
tmax=max(r.time(itstart:itend));

% Plot timeseries
figure(1); 
clf reset;
   
  hold on;
  if isbp set(gca,'XDir','reverse'); end
  set(gca,'YLim',minmax);
  xlabel('Time / year AD');
  ylabel('Total population / million');
  set(gca,'Yscale','log');

  for iregion=1:nregions

  [ifound,nfound,lonlim,latlim]=find_region_numbers(regions{iregion});

  p(iregion)=plot(r.time(itstart:itend),squeeze(sum(data(ifound,itstart:itend),1)));
  l=legend(regions,'location','northwest');
  
  if strcmp(regions{iregion},'nam') 
      %% Read Peros data
      fperos='/h/lemmen/projects/glues/tex/2010/saa/Peros2010_population.tsv';
      peros=dlmread(fperos,',',8,0);
      peros(:,1)=2000-peros(:,1);
      peros=sortrows(peros,1);
      hold on;
      pp=plot(peros(:,1),peros(:,2)*1E6,'k--','linewidth',4);
      minmax=[min([min(min(ydata));peros(:,2)*1E6]),max(max(ydata))];
      set(gca,'YLim',minmax);
      
      pu=patch([1350,1550,1550,1350],[1.2E6,1.2E6,2.4E6,2.4E6],'y');
     px=plot([-1000,-1000],minmax,'k:');
        hold off;
      l=legend([regions,'Peros (2010)'],'location','northwest');
      
      
  end
  
  set(gca,'Xlim',[tmin,tmax]);
 
  set(p(iregion),'Tag',regions{iregion},'LineWidth',4,'color',cmap(iregion,:));
 
  
  %% Make figure more readable
  obj=findall(gcf,'-property','FontSize');
  for i=1:length(obj)
    set(obj(i),'FontSize',16);
  end
  
  xt=get(gca,'XTick');
  i0=find(xt==0);
  if ~isempty(i0)
    xt(i0)=1;
    xtl=get(gca,'XTickLabel');
    xtl(i0,:)=strrep(xtl(i0,:),'0','1');
    set(gca,'XTickLabel',xtl,'XTick',xt);
  end
  
  %% Remove all background
  set([gca,l],'Color','none');
  
  
  fd=fullfile(d.plot,'variable');
  if ~exist(fd,'file') mkdir(fd); end
  
  fd=fullfile(fd,strrep(r.variables{ivar},' ',''));
  if ~exist(fd,'file') mkdir(fd); end
  
  plotname=fullfile(fd,'pop_trajectories_population');
  plot_multi_format(gcf,plotname);
  end  


% Plot density timeseries
data=eval(['r.' r.variables{ivar}]);


ydata=mean(data(regs,itstart:itend),1);
xdata=r.time(itstart:itend);
minmax=[min(min(ydata)),max(max(ydata))];

figure(2); clf reset;
hold on;
if isbp set(gca,'XDir','reverse'); end

set(gca,'YLim',minmax,'Yscale','log');
xlabel('Time / year AD');
ylabel('Population density / km^{-2}');

for iregion=1:nregions

  [ifound,nfound,lonlim,latlim]=find_region_numbers(regions{iregion});

  p(iregion)=plot(xdata,ydata);
  l=legend(regions,'location','northwest');
  
  if strcmp(regions{iregion},'nam') 
      %% Read Peros data
      fperos='/h/lemmen/projects/glues/tex/2010/saa/Peros2010_density.tsv';
      peros=dlmread(fperos,',',7,0);
      peros(:,1)=2000-peros(:,1);
      peros=sortrows(peros,1);
      hold on;
      pp=plot(peros(:,1),peros(:,2)/100,'k--','linewidth',4);
      minmax=[min([min(min(ydata));peros(:,2)/100]),max(max(ydata))];
      set(gca,'YLim',minmax);
      pu=patch([1350,1550,1550,1350],[1.2E6,1.2E6,2.4E6,2.4E6]/20E6,'y');
      % Engelbrech 1987 Iroquois 16th century 2/sqmile
      pe=patch([1350,1550,1550,1350],[1.2E6,1.2E6,2.4E6,2.4E6]/20E6,'y');
      px=plot([-1000,-1000],minmax,'k:');
      hold off;
      l=legend([p(iregion),pp],[regions,'Peros (2010)'],'location','northwest');
  end
  
  set(gca,'Xlim',[tmin,tmax]);
 
  set(p(iregion),'Tag',regions{iregion},'LineWidth',4,'color',cmap(iregion,:));
 
  
  %% Make figure more readable
  obj=findall(gcf,'-property','FontSize');
  for i=1:length(obj)
    set(obj(i),'FontSize',16);
  end
  
  xt=get(gca,'XTick');
  i0=find(xt==0);
  if ~isempty(i0)
    xt(i0)=1;
    xtl=get(gca,'XTickLabel');
    xtl(i0,:)=strrep(xtl(i0,:),'0','1');
    set(gca,'XTickLabel',xtl,'XTick',xt);
  end
  
  %% Remove all background
  set([gca,l],'Color','none');
  
  
  fd=fullfile(d.plot,'variable');
  if ~exist(fd,'file') mkdir(fd); end
  
  fd=fullfile(fd,strrep(r.variables{ivar},' ',''));
  if ~exist(fd,'file') mkdir(fd); end
  
  plotname=fullfile(fd,'pop_trajectories_density');
  plot_multi_format(gcf,plotname);
  end  

  
  
if nargout>0 
  rdata=retdata;
end

return;
end

