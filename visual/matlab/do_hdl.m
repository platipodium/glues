% do_hdl
% Creates plots for graduate school talk



file='../../euroclim_0.4.nc';

reg='eur';
movtime=-7500:50:-3500;
nmovtime=length(movtime);
for it=1:-nmovtime
  [d,b]=clp_nc_variable('var','farming','reg',reg,'marble',3,'transparency',1,'nocolor',0,...
      'showstat',0,'lim',[0 1],'timelim',movtime(it),'nocbar',1,...
      'file',file,'figoffset',0,'sce',['euroclim_0.4_' sprintf('%03d_%05d',it,movtime(it))],'noprint',1,'cmap','hotcold');
  m_coast('color','k');
  m_grid('box','fancy','linestyle','none');
  title('GLUES agropastoral activity');
  %cb=findobj(gcf,'tag','colorbar')
  %ytl=get(cb,'YTickLabel');
  %ytl=num2str(round(100*str2num(ytl)));
  %set(cb,'YTickLabel',ytl);
  %title(cb,'%');
  %cm=get(cb,'Children');
  %cmap=get(cm,'CData');
  
  cl_print('name',b,'ext','png','res',100);
end

% Command line postprocessing
%mencoder mf://farming_chi_44_euroclim_0.4_-*_-*.png  -mf w=800:h=600:fps=5:type=png -ovc lavc -lavcopts vcodec=mpeg4:mbd=2:trell -oac copy -o output.avi
%mencoder mf://population_density_chi_44_euroclim_0.4_-*_-*.png  -mf w=800:h=600:fps=5:type=png -ovc lavc -lavcopts vcodec=mpeg4:mbd=2:trell -oac copy -o movie_1_600.avi
 



ireg=121; 
lg=repmat(0.7,1,3);

%ts=clp_nc_trajectory('file',file,'reg',121,'var','population_sizse','nosum',0,'showmap',0);
%cl_print(gcf,'name','euroclim_04_trajectory_population_size_121','ext','pdf');
tp=clp_nc_trajectory('file',file,'reg',ireg,'var','population_size','nosum',0,'showmap',0);
set(gca,'Box','off');
c=get(gca,'Children');
gb=findobj(c,'Color','b');
set(gb,'Color','r');
ylabel('Population size');
set(gca,'Xcolor',lg,'YColor',lg');
set(gca,'XLim',[-11500,2000],'YLim',[5E3 5E6]);
cl_print(gcf,'name','euroclim_04_trajectory_population_size_121','ext','pdf');


tp=clp_nc_trajectory('file',file,'reg','eur','div',2,'var','population_size','nosum',0,'showmap',0);
set(gca,'Box','off');
c=get(gca,'Children');
gb=findobj(c,'Color','b');
set(gb,'Color','r');
ylabel('Female population size');
set(gca,'Xcolor',lg,'YColor',lg','yscale','log','ylim',[5E3 5E6]);
set(gca,'XLim',[-11500,2000],'YLim',[5E3 5E6]);
cl_print(gcf,'name','euroclim_04_trajectory_population_size_eur','ext','pdf');



timeunit='days since 2000-01-01 00:00:00';
time=cl_time2yearAD(cl_diagnostics('file',file,'var','time'),timeunit);
si=cl_diagnostics('file',file,'var','subsistence_intensity');
p=cl_diagnostics('file',file,'var','population_density');
t=cl_diagnostics('file',file,'var','technology');
q=cl_diagnostics('file',file,'var','farming');
e=cl_diagnostics('file',file,'var','economies');
ep=cl_diagnostics('file',file,'var','economies_potential');
l=cl_diagnostics('file',file,'var','lossterm');
g=cl_diagnostics('file',file,'var','growthterm');
a=cl_diagnostics('file',file,'var','actual_fertility');
o=cl_diagnostics('file',file,'var','artisans');
s1=cl_diagnostics('file',file,'var','subsistence_intensity');
s2=cl_diagnostics('file',file,'var','subsistence_intensity','recalculate',1);
r1=cl_diagnostics('file',file,'var','relative_growth_rate');
r2=cl_diagnostics('file',file,'var','relative_growth_rate','recalculate',1);
m=cl_diagnostics('file',file,'var','migration_density');
%mq=cl_diagnostics('file',file,'var','farming_spread_by_people');

tsm=cl_diagnostics('file',file,'var','technology_spread_by_people');
tsi=cl_diagnostics('file',file,'var','technology_spread_by_information');
esm=cl_diagnostics('file',file,'var','economies_spread_by_people');
esi=cl_diagnostics('file',file,'var','economies_spread_by_information');

st=cl_diagnostics('file',file,'var','suitable_temperature');
ss=cl_diagnostics('file',file,'var','suitable_species');

c=g./l;
pdiff=[0 diff(p(ireg,:))]*5;
tdiff=[0 diff(t(ireg,:))]*5;


figure(1); clf reset; hold on
plot(time,t(ireg,:),'r-');
plot(time,cumsum(tsm(ireg,:)),'b-');
plot(time,cumsum(tsi(ireg,:)),'m-');


figure(2); clf reset; hold on
plot(time,e(ireg,:),'r-');
plot(time,cumsum(esm(ireg,:)),'b-');
plot(time,cumsum(esi(ireg,:)),'m-');

figure(3); clf reset; hold on
plot(time,p(ireg,:),'r-');
plot(time,10*cumsum(r1(ireg,:).*p(ireg,:)),'b-');
plot(time,10*cumsum(m(ireg,:)),'m-');


plot(time,p(ireg,:),'r-');
hold on;
plot(time,t(ireg,:),'b-');
plot(time,10*q(ireg,:),'b:');
plot(time,e(ireg,:),'b--');
plot(time,10*a(ireg,:),'g--');
plot(time,10*o(ireg,:),'g:');

plot(time,100*l(ireg,:),'r--');
plot(time,100*g(ireg,:),'r:');

plot(time,1*c(ireg,:),'m-');
%plot(time,1*m(ireg,:),'c-');

figure(2); clf reset; hold on;
plot(time,.1*s1(ireg,:),'b-');
plot(time,.1*s2(ireg,:),'r-');

return




d=clp_nc_variable('file',file,'reg','eur','var','region','marble',0,'showvalue',1,...
    'noaxes',1,'showstat',0)
%c=get(gcf,'Children');
%c=findobj(c,'type','axes');
%set(c,'XColor',repmat(.5,1,3),'YColor',repmat(.5,1,3));

v=find(d.handle>0);
set(d.handle(v),'FAceColor','none','EdgeColor','k');
cl_print(gcf,'name','euroclim_04_map_region_number_eur','ext','pdf');

clp_nc_trajectory('file',file,'reg','eur','var','population_density','nosum',1,'showmap',0);
cl_print(gcf,'name','euroclim_04_trajectory_population_density_eur','ext','pdf');

clp_nc_trajectory('file',file,'reg','eur','var','farming','nosum',1,'showmap',0);
cl_print(gcf,'name','euroclim_04_trajectory_farming_eur','ext','pdf');

tf=clp_nc_trajectory('file',file,'reg',121,'var','farming','nosum',1,'showmap',0);
c=get(gca,'Children');
gb=findobj(c,'Color','b');
set(gb,'Color','r');
cl_print(gcf,'name','euroclim_04_trajectory_farming_121','ext','pdf');
%ts=clp_nc_trajectory('file',file,'reg',121,'var','population_sizse','nosum',0,'showmap',0);
%cl_print(gcf,'name','euroclim_04_trajectory_population_size_121','ext','pdf');
tp=clp_nc_trajectory('file',file,'reg',121,'var','population_density','nosum',1,'showmap',0);
c=get(gca,'Children');
gb=findobj(c,'Color','b');
set(gb,'Color','r');
cl_print(gcf,'name','euroclim_04_trajectory_population_density_121','ext','pdf');

file='../../euroclim_0.0.nc';
clp_nc_trajectory('file',file,'reg','eur','var','population_density','nosum',1,'showmap',0);
cl_print(gcf,'name','euroclim_00_trajectory_population_density_eur','ext','pdf');

clp_nc_trajectory('file',file,'reg','eur','var','farming','nosum',1,'showmap',0);
cl_print(gcf,'name','euroclim_00_trajectory_farming_eur','ext','pdf');

tf=clp_nc_trajectory('file',file,'reg',121,'var','farming','nosum',1,'showmap',0);
c=get(gca,'Children');
gb=findobj(c,'Color','b');
set(gb,'Color','r');
cl_print(gcf,'name','euroclim_00_trajectory_farming_121','ext','pdf');



