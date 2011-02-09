function cl_nc_combine_arve_glues_india(varargin)
% This function takes glues results for glues regions, maps them to a 
% half-degree grid and aggregates over the ARVE population regions.

arguments = {...
  {'timelim',[-6000,1850]},...
  {'file','arveaggregate_eurolbk_events.mat'},...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end

glues=load(file);

file='../../data/Pop_estimates.nc';
ncid=netcdf.open(file,'NOWRITE');
varid=netcdf.inqVarID(ncid,'time');
time=netcdf.getVar(ncid,varid);
%varid=netcdf.inqVarID(ncid,'regname');
%regname=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'regnum');
regnum=netcdf.getVar(ncid,varid);
varid=netcdf.inqVarID(ncid,'population');
best=netcdf.getVar(ncid,varid);
netcdf.close(ncid);
ncid=netcdf.open('../../data/Lower_bound_pop_data.nc','NOWRITE');
varid=netcdf.inqVarID(ncid,'population');
lower=netcdf.getVar(ncid,varid);
netcdf.close(ncid);
ncid=netcdf.open('../../data/Upper_bound_pop_data.nc','NOWRITE');
varid=netcdf.inqVarID(ncid,'population');
upper=netcdf.getVar(ncid,varid);
netcdf.close(ncid);

glues.value=glues.arvedensity;
ntime=size(glues.value,2);
area=repmat(glues.garea',1,ntime);

% From Kristen's population paper super regions
file='../../data/pop_region_key2.txt';
fid=fopen(file,'r');
keys=textscan(fid,'%d %s');
fclose(fid);
for i=1:length(keys{1})
  eval([strrep(char(keys{2}(i)),'-','_') ' = ' num2str(keys{1}(i)) ';']);
  regname{i}=strrep(char(keys{2}(i)),'-','_');
end

india=[Pakistan_India_Bangladesh Nepal Bhutan];
nar=max(glues.index);
for i=1:nar
  ia=find(glues.index==i);
  if ~isempty(ia) 
      aindex(i)=ia; 
  else aindex(i)=NaN; 
  end
end

area=glues.garea;

% calculate total area of superreigions
ar(3)=sum(area(aindex(india)));
area=glues.garea;

% Remove countries for which we don't have numbers in GLUES (area=inf)
india=india(isfinite(area(aindex(india))));

arc(3)=sum(area(aindex(india)));
arc(:)=1;
ar(:)=1;


glues.value=glues.arvedensity;
ntime=size(glues.value,2);
area=repmat(glues.garea',1,ntime);

pop=area(aindex(india),:).*glues.value(aindex(india),:);

tpop=sum(pop);

c='rgbcmkrgbcmkr';
ls='------::::::-';
sregions={'NAM','SAM','india','FSU','SW Asia','N Afr','Subsah Afr','India',...
    'China','Japan','SE Asia','Oceania'};

isindia=[];

for i=india isindia=[isindia find(regnum==i)]; end


for i=3 
  switch (i)
      case 3,idx=isindia;
  end
  kk10(i,:)=sum(best(idx,:),1);
  kk10upper(i,:)=sum(upper(idx,:),1);
  kk10lower(i,:)=sum(lower(idx,:),1);
end
  
itime=find(time>=timelim(1) & time<=timelim(2));
ntime=min(glues.time):max(time);


%% Total india
% For india, trust the data (which have low uncertainty, only adust the
% data between -1000 and -1500 in a gradual transition, assume data constant
% before -1000
tpop=tpop/1E6;
pop=pop/1E6;

figure(1); clf reset;
i=3;
plot(glues.time,tpop,'b-','LineWidth',2); hold on;
plot(time(itime),kk10(i,itime),'r-','LineWidth',2);
plot(time(itime),kk10lower(i,itime),'r--');
plot(time(itime),kk10upper(i,itime),'r--');
set(gca,'XLim',[-6500,1900],'YLim',[0 ceil(max(kk10upper(i,itime)/10))*10],'YScale','linear');
title(sregions{i});
xlabel('Time (year AD)');
ylabel('Population size (1E6)'); 

i1=find(time==-1000);
l1=find(ntime==time(i1));
l2=find(ntime==-1500);
i0=find(time==0);
l0=find(ntime==time(i0));

% Assing GLUES to whole new time series
lkk(i,:)=spline(glues.time,tpop,ntime);
% Assign KK10 from -1000
lkk(i,l1:end)=kk10(i,i1:end);
% Assign linear weighting between 0-1500 and -1000 betwwen GLUES and KK10
w=[0:l1-l2];
w=w./max(w);
lkk(i,l2:l1)=lkk(i,l2:l1).*(1-w)+kk10(i,i1).*w;
eur=lkk(i,:);

p=plot(ntime,lkk(i,:),'k--','LineWidth',3);
legend('GLUES','KK10','LKK11');

%% Single regions of india

nindia=length(india)
lkk=zeros(nindia,length(ntime));

for i=1:nindia
  j=find(india(i)==regnum);
  lkk(i,:)=spline(glues.time,pop(i,:),ntime);
  lkk(i,l1:end)=best(j,i1:end);
  lkk(i,l2:l1)=lkk(i,l2:l1).*(1-w)+best(j,i1).*w;  
end

pop=pop*1E3;
lkk=lkk*1E3;
upper=upper*1E3;
best=best*1E3;
lower=lower*1E3;

for i=1:nindia
  j=find(india(i)==regnum);
  m=mod(i+5,6);
  if (m==0) figure(i+1); clf reset; hold on; end
  subplot(2,2,m+1);
  p(i,1)=plot(glues.time,pop(i,:),'b-','LineWidth',2); hold on;
  p(i,2)=plot(time,best(j,:),'r-','LineWidth',2);
  p(i,3)=plot(time,lower(j,:),'r--');
  p(i,4)=plot(time,upper(j,:),'r--');
  set(gca,'XLim',timelim,'YLim',[0 ceil(max(upper(j,itime)/100))*100],'YScale','linear');
  title(regname{j},'Interpreter','none');
  %xlabel('Time (year AD)');
  %ylabel('Population size (1E3)'); 
  p(i,5)=plot(ntime,lkk(i,:),'k--','LineWidth',3);
  %legend(p(i,[1,2,5]),'GLUES','KK10','LKK11','Location','NorthWest');
end

end