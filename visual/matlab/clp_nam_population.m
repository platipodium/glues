function clp_nam_population(varargin)

arguments = {...
  {'file','lkk11_0.1_20110105.nc'},...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end


%% Read results file
if ~exist(file,'file') error('File does not exist'); end
ncid=netcdf.open(file,'NC_NOWRITE');

[ndim nvar natt udimid] = netcdf.inq(ncid); 
for varid=0:nvar-1
  [varname,xtype,dimids,natts]=netcdf.inqVar(ncid,varid);
  if strcmp(varname,'time') time=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'population_size_glues') glues=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'population_size_kk10') kk10=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'population_size_kk10lower') kk10l=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'population_size_kk10upper') kk10u=netcdf.getVar(ncid,varid); end
  if strcmp(varname,'population_size_lkk11') lkk11=netcdf.getVar(ncid,varid); end
end

netcdf.close(ncid);

% Read region names
fid=fopen(strrep(file,'.nc','_key.txt'),'r');
keys=textscan(fid,'%d %s');
fclose(fid);
for i=1:length(keys{1}) regname{i}=keys{2}(i); end

% Gather historic estimates
% Compilation by Thornton 2001, Table 1

% North America = Northern Mexico, US, Canada, Greenland
fid=fopen('../../data/nam_population.tsv','r');
d=textscan(fid,'%s %f %f %f %f','CommentStyle','%');
data=[d{2} d{3} d{4} d{5}];
data(:,2:3)=data(:,2:3)/1000;

figure(1); clf reset; hold on;



npub=length(d{2});

for i=1:npub
   bar(i,data(i,4),'c');
   bar(i,data(i,3),'b');
   text(i,6,num2str(data(i,1),'color','k','angle',90);
end
   
xlabel('Publication year');
ylabel('Population size (million)');



return




gray=repmat(0.5,1,3);


xlabel('Time (Year AD)');
ylabel('Population size (1E6)');
set(gca,'XLim',[-8000,1750]);
set(gca,'color','none');
l=legend([p1,p3h],'census.gov','Hyde');
set(l,'Location','Northwest','color','w','FontSize',16);

plot_multi_format(gcf,['lkk11_world_hyde']);

set([p2h,p3h,p4h],'visible','off');
p2=plot(time,sum(kk10l,1),'r--','Linewidth',1,'visible','off');
p3=plot(time,sum(kk10,1),'r-','Linewidth',5,'visible','off');
p4=plot(time,sum(kk10u,1),'r--','Linewidth',1,'visible','off');
p2k=plot(kl(:,1),kl(:,2),'r-.');
p3k=plot(km(:,1),km(:,2),'r-','Linewidth',5);
p4k=plot(ku(:,1),ku(:,2),'r-.');
xlabel('Time (Year AD)');
ylabel('Population size (1E6)');
set(gca,'XLim',[-8000,1750]);
set(gca,'color','none');
l=legend([p1,p3k],'census.gov','KK10');
set(l,'Location','Northwest','color','w','FontSize',16);

plot_multi_format(gcf,['lkk11_world_kk10']);


set([p2h,p3h,p4h],'visible','on');

l=legend([p3h,p3k,p1],'Hyde','KK10','census.gov');
set(l,'Location','Northwest','color','w','FontSize',16);
plot_multi_format(gcf,['lkk11_world_1']);

i0=find(time==-1000);
p5=plot(time(1:i0),sum(glues(:,1:i0),1),'b-','LineWidth',5)
l=legend([p3h,p3k,p1,p5],'Hyde','KK10','census.gov','GLUES');
set(l,'Location','Northwest','color','w','FontSize',16);
plot_multi_format(gcf,['lkk11_world_2']);

%set([p5],'LineWidth',1);
skk=sum(kk10,1); sg=sum(glues,1);

factor=skk(i0+1)./sg(i0+1);

p6=plot(time(1:i0),sum(glues(:,1:i0),1)*factor,'b--','LineWidth',5)
l=legend([p3h,p3,p1,p5],'Hyde','KK10','census.gov','GLUES');
set(l,'Location','Northwest','color','w','FontSize',16);

plot_multi_format(gcf,['lkk11_world_4a']);

set(p6,'visible','off');
set([p3k,p2k,p4k],'visible','off');
set([p3,p2,p4],'visible','on');

plot_multi_format(gcf,['lkk11_world_4']);

p7=plot(time,sum(lkk11,1),'m-','LineWidth',5)
l=legend([p3h,p3,p1,p5,p7],'Hyde','KK10','census.gov','GLUES','LKK11');
set(l,'Location','Northwest','color','w','FontSize',16);
plot_multi_format(gcf,['lkk11_world_5']);

figure(2); clf reset; hold on;

nreg=size(lkk11,1);
j=1:nreg;
for i=1:nreg
  figure(i+2); clf reset; hold on;
  %plot(time,kk10l(j(i),:),'r--','Linewidth',1);
  %plot(time,kk10u(j(i),:),'r--','Linewidth',1);
  plot(time,lkk11(j(i),:),'m-','LineWidth',5);
  set(gca,'color','none','XLim',[-8000,1750]);
  l=legend(regname{j(i)});
  set(l,'Location','Northwest','color','w','FontSize',16,'Interpreter','none');
  plot_multi_format(gcf,sprintf('%s_%s','lkk11',char(regname{j(i)})));
end







return;
end