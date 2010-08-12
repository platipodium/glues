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
ybp=d(:,1);
year=d(:,2);
depth=d(:,3);
thick=d(:,4); % varve thickness

figure(1);
clf reset;
hold on

bar(1929,2,2,'y','EdgeColor','none');
nyear=length(year);

plot(year,thick,'m-','LineWidth',2);
title(['Indus discharge from core SO90-56KA/39KG']);
ylabel('Varve thickness');
xlabel('Year');
set(gca,'XLim',[year(end)-1,year(1)+1],'Ylim',[0 2]);

print('-dpng',['indus_varves']);


end















