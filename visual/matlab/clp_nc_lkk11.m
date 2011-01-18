function clp_nc_lkk11(varargin)
% This function takes glues results for glues regions, maps them to a 
% half-degree grid and aggregates over the ARVE population regions.

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
h=[-10000 1 10; -8000 5 10; -6500 5 10 ; -5000 5 20; ...
    -4000 7 NaN; -3000 14  NaN ; -2000 27 NaN ; -1000 50 NaN; ...
    -500 100 NaN; -400 162 NaN ; -200 150 231 ; 1 170 400; ...
    200 190 256 ; 400 190 206; 500 190 206; 600 200 206;  ...
    700 207 210; 800 220 224; 900 226 240; 900 226 240; ...
    1000 254 345 ; 1100 301 320; 1200 360 450; 1250 400 416; ...
    1300 360 432; 1340 443 NaN; 1400 350 374; 1500 425 540; ...
    1600 545 479; 1650 470 545; 1700 600 679; 1750 629 961; ...
    ];
p=polyfit(h([4,10],1),log(h([4,11],3)),1);
inan=find(isnan(h(:,3)));
h(inan,3)=exp(p(1).*h(inan,1)+p(2));

kl=load('../../data/lower_bound.dat','-ascii');
ku=load('../../data/upper_bound.dat','-ascii');
km=load('../../data/Global_pop_8k.dat','-ascii');
hl=load('../../data/low_bound_hyde.dat','-ascii');
hm=load('../../data/hyde_world_pop_2.dat','-ascii');
hu=load('../../data/up_bound_hyde.dat','-ascii');

figure(1); clf reset; hold on;

gray=repmat(0.5,1,3);
fs=14;

p1=patch([h(:,1);flipud(h(:,1))],[h(:,2);flipud(h(:,3))],[0.9 0.9 0.6],'edgecolor','none','visible','on');

p2h=plot(hl(:,1),hl(:,2),'g--','Linewidth',1,'visible','on');
p3h=plot(hm(:,1),hm(:,2),'g-','Linewidth',5);
p4h=plot(hu(:,1),hu(:,2),'g--','Linewidth',1,'visible','on');
xlabel('Time (Year AD)','FontSize',fs);
ylabel('Population size (1E6)','FontSize',fs);
set(gca,'XLim',[-8000,1750],'FontSize',fs);
set(gca,'XLim',[-8000,1750],'YLim',[0,1000]);
set(gca,'color','none','xcolor',gray,'ycolor',gray);
l=legend([p1,p3h],'US Census Bureau','Hyde');
set(l,'Location','Northwest','color','w','FontSize',fs);
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
set(gca,'XLim',[-8000,1750],'YLim',[0,1000]);
set(gca,'color','none');
l=legend([p1,p3k],'US Census Bureau','KK10');
set(l,'Location','Northwest','color','w','FontSize',16);

plot_multi_format(gcf,['lkk11_world_kk10']);


set([p2h,p3h,p4h],'visible','on');

l=legend([p3h,p3k,p1],'Hyde','KK10','US Census Bureau');
set(l,'Location','Northwest','color','w','FontSize',16);
set(gca,'XLim',[-8000,1750],'YLim',[0,1000]);
plot_multi_format(gcf,['lkk11_world_hyde+kk10']);

i0=find(time==-1000);
p5=plot(time(1:i0),sum(glues(:,1:i0),1),'b-','LineWidth',5)
l=legend([p3h,p3k,p1,p5],'Hyde','KK10','US Census Bureau','GLUES');
set(l,'Location','Northwest','color','w','FontSize',16);
set(gca,'XLim',[-8000,1750],'YLim',[0,1000]);
plot_multi_format(gcf,['lkk11_world_hyde+kk10+glues']);


set([p2h,p3h,p4h,p3k,p2k,p4k],'visible','off');
l=legend([p1,p5],'US Census Bureau','GLUES');
set(l,'Location','Northwest','color','w','FontSize',16);
set(gca,'XLim',[-8000,1750],'YLim',[0,1000]);
plot_multi_format(gcf,['lkk11_world_glues']);

set([p2h,p3h,p4h],'visible','on');
l=legend([p1,p5,p3h],'US Census Bureau','GLUES','Hyde');
set(l,'Location','Northwest','color','w','FontSize',16);
set(gca,'XLim',[-8000,1750],'YLim',[0,1000]);
plot_multi_format(gcf,['lkk11_world_glues+hyde']);


set([p2h,p3h,p4h,p3k,p2k,p4k],'visible','on');
skk=sum(kk10,1); sg=sum(glues,1);

factor=skk(i0+1)./sg(i0+1);

p6=plot(time(1:i0),sum(glues(:,1:i0),1)*factor,'b--','LineWidth',5)
l=legend([p3h,p3,p1,p5],'Hyde','KK10','US Census Bureau','GLUES');
set(l,'Location','Northwest','color','w','FontSize',16);
set(gca,'XLim',[-8000,1750],'YLim',[0,1000]);
plot_multi_format(gcf,['lkk11_world_4a']);

set(p6,'visible','off');
set([p3k,p2k,p4k],'visible','off');
set([p3,p2,p4],'visible','on');
set(gca,'XLim',[-8000,1750],'YLim',[0,1000]);
plot_multi_format(gcf,['lkk11_world_4']);

p7=plot(time,sum(lkk11,1),'m-','LineWidth',5)
l=legend([p3h,p3,p1,p5,p7],'Hyde','KK10','US Census Bureau','GLUES','LKK11');
set(l,'Location','Northwest','color','w','FontSize',16);
set(gca,'XLim',[-8000,1750],'YLim',[0,1000]);
plot_multi_format(gcf,['lkk11_world_all']);

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