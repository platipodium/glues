function [retdata,basename]=clp_varves(varargin)


arguments = {...
  {'timelim',[-2500,2010]},...
  {'lim',[-inf,inf]},...
  {'scale','absolute'},...
  {'figoffset',0},...
  {'nosum',0},...
  {'nocolor',0},...
  {'retdata',NaN},...
  {'nearest',0}
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end


filename=fullfile('data','datasets','SO90-39KG-56KA_varve_stack.tsv');
if ~exist(filename,'file') error('File does not exist'); end

d=load(filename,'-ascii');
year=d(:,2);
itime=find(year>=timelim(1) & year<=timelim(2));
year=year(itime);
ybp=d(itime,1);
depth=d(itime,3);
thick=d(itime,4); % varve thickness

figure(2);
clf reset;
hold on

bar(1929,2,2,'y','EdgeColor','none');
nyear=length(year);

plot(year,thick,'m-','LineWidth',2);
title(['Indus discharge from core SO90-56KA/39KG']);
ylabel('Varve thickness');
xlabel('Year');
if isinf(lim) lim=[0 2]; end
set(gca,'XLim',[year(end)-1,year(1)+1],'Ylim',lim);

retdata.year=year;
retdata.thick=thick;

print('-dpng',['indus_varves']);


end















