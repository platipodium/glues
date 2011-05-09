% Run script to produce the figures for the american antiquity paper presented
% Carsten Lemmen
% 2011-02-09

% Figures in this paper
% 1. world_timing_map
% 2. world density map for different scenarios
% 3. Europe density maps
% 4. NAM density maps
% 5. base trajectories
% 6. nospread trajectories
% 7. woodland historgram

% select which figures to plot
doplot=[6];

% Lon/lat limits for both regions EUR+NAM
blatlim=[25 60];
blonlim=[-110 30];
elatlim=[35 blatlim(2)];
elonlim=[-10 blonlim(2)];
nlatlim=[blatlim(1) 50];
nlonlim=[blonlim(1) -70];


%% Figure comparison (US+NAM) maps
% Figure 1: natural realm and usage in GLUES
if any(doplot==1)
   [d,b]=clp_nc_variable('var','natural_fertility','timelim',[-9500],'latlim',blatlim,'lonlim',blonlim,...
     'marble',0,'transpar',0,'nogrid',1,'file','../../amant_nofluc.nc','lim',[0 1],'showtime',0,'showstat',0);
   [d,b]=clp_nc_variable('var','economies_potential','timelim',[-9500],'latlim',blatlim,'lonlim',blonlim,...
     'marble',0,'transpar',0,'nogrid',1,'file','../../amant_nofluc.nc','flip',0,'showtime',0,'showstat',0,'lim',[0 6]);
   [d,b]=clp_nc_variable('var','suitable_species','timelim',[-9500],'latlim',blatlim,'lonlim',blonlim,...
     'marble',0,'transpar',0,'nogrid',1,'file','../../amant_nofluc.nc','flip',0,'lim',[0 1],'showtime',0,'showstat',0); 
   [d,b]=clp_nc_variable('var','suitable_temperature','timelim',[-9500],'latlim',blatlim,'lonlim',blonlim,...
     'marble',0,'transpar',0,'nogrid',1,'file','../../amant_nofluc.nc','lim',[0 1],'showtime',0,'showstat',0);
   [d,b]=clp_nc_variable('var','npp','timelim',[-9500],'latlim',blatlim,'lonlim',blonlim,...
     'marble',0,'transpar',0,'nogrid',1,'file','../../amant_nofluc.nc','lim',[0 1000],'showtime',0,'showstat',0);
   [d,b]=clp_nc_variable('var','temperature_limitation','timelim',[-9500],'latlim',blatlim,'lonlim',blonlim,...
     'marble',0,'transpar',0,'nogrid',1,'file','../../amant_nofluc.nc','lim',[0 1],'showtime',0,'showstat',0);
end

%% Figure comparison (US+NAM) maps
% Figure 2: timing of transtion
if any(doplot==2)
   [d,b]=clp_nc_variable('var','farming','timelim',[-7000,1500],'latlim',blatlim,'lonlim',blonlim,...
     'marble',0,'transpar',0,'nogrid',1,'threshold',0.5,'file','../../amant_nofluc.nc','flip',1,'showtime',0,'showstat',0);
   %[d,b]=clp_nc_variable('var','population_density','timelim',[1490],'latlim',blatlim,'lonlim',blonlim,...
   %  'marble',0,'transpar',0,'nogrid',1,'file','../../amant_nofluc.nc','flip',0,'showtime',0,'showstat',0,'lim',[0 5]);
end

%% Figure 3 Europe density maps
if any(doplot==3)
  euletter='abcdef';
  eutime=[-8000 -6000 -5000 -4000 -3000 -1000];
  for i=1:length(eutime)
    scenario=sprintf('amant_base_%d',eutime(i));
    [d,b]=clp_nc_variable('var','population_density','timelim',eutime(i),'latlim',elatlim,'lonlim',elonlim,...
        'marble',0,'transpar',0,'lim',[0 6],'nogrid',1,'showtime',0,'showstat',0,'sce',scenario,'file','../../amant_nofluc.nc');
    %ax=get(gcf,'Children');
    %axes(ax(2));
    %bcad='BC';
    %text(0.5,01.46,sprintf('%d %s',abs(eutime(i)),bcad),'Vertical','top','Horizontal','right',...
    %  'FontSize',13,'FontWeight','bold','background','w');
    %[d,n,e]=fileparts(b);
    %cl_print('name',fullfile(d,['lemmen_fig3' euletter(i) '_color']));
  end
end

%% Figure 4 US density maps
if any(doplot==4)
  ustime=[-4000 -3000 -2000 -1000 0 500 750 1000 1490];
  for i=1:length(ustime)
    scenario=sprintf('amant_base_%d',ustime(i));
  [d,b]=clp_nc_variable('var','population_density','timelim',ustime(i),'latlim',nlatlim,'lonlim',nlonlim,...
        'marble',0,'transpar',0,'lim',[0 1.5],'nogrid',1,'showtime',0,'showstat',0,...
        'file','../../amant_nofluc.nc','sce',scenario);
  end
end


% Find regions for europe/us
ereg=find_region_numbers('latlim',elatlim,'lonlim',elonlim);
ereg=ereg(ereg<277 & ereg>90);
usreg=find_region_numbers('latlim',nlatlim,'lonlim',nlonlim);
usreg=usreg(usreg>180 & usreg<371);

    %% Figure 5 Trajectories for different variables
if any(doplot==51)

    % Map figure for europe
    %clp_nc_variable('var','region','reg',ereg,'noprint',1,'latlim',elatlim,'lonlim',elonlim,...
    %'showvalue',1,'showstat',0);
    figure(51); clf reset; hold on;
    clp_basemap('latlim',elatlim,'lonlim',elonlim);
    m_coast('patch','r','FaceColor',0.85*[1 1 1],'EdgeColor','none');
    hdl=clp_regionpath('reg',ereg);
    set(hdl,'FaceColor',0.7*[1 1 1],'EdgeColor','none');
    hdl=findobj(gcf,'LineStyle',':');
    delete(hdl);
    pname=sprintf('europe_map_highlight');
    cl_print('name',pname,'ext','pdf');

    % Map figure for europe
    %clp_nc_variable('var','region','reg',usreg,'noprint',1,'latlim',nlatlim,'lonlim',nlonlim,...
    %'showvalue',1,'showstat',0);
    figure(52); clf reset; hold on;
    clp_basemap('latlim',nlatlim,'lonlim',nlonlim);
    m_coast('patch','r','FaceColor',0.85*[1 1 1],'EdgeColor','none');
    hdl=clp_regionpath('reg',usreg);
    hdl=hdl(hdl>0);
    set(hdl,'FaceColor',0.7*[1 1 1],'EdgeColor','none');
    hdl=findobj(gcf,'LineStyle',':');
    delete(hdl);
    pname=sprintf('usa_map_highlight');
    cl_print('name',pname,'ext','pdf');

end


etimelim=[-7500 -1000];
ustimelim=[-5000 1500];

if any(doplot==5)
  % Figure 5 trajectories in Europe and NAM
  file='../../amant_nofluc.nc';
  ncid=netcdf.open(file,'NOWRITE');
  time=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'time'));
  area=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'area'));
  population_density=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'population_density'));
  population_size=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'population_size'));
  economies=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'economies'));
  economies_potential=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'economies_potential'));
  farming=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'farming'));
  netcdf.close(ncid);
  
  figure(53); clf reset; hold on;
  itime=find(time>=etimelim(1) & time<=etimelim(2));
  ax(1)=gca;
  ax(2)=axes;
  axes(ax(1));
  set(ax,'FontSize',18);
  p1a=plot(time(itime),population_density(ereg,itime),'k-','Linewidth',1.5,'Color',...
      0.7*[1 1 1]);
  p1b=plot(time(itime),mean(population_density(ereg,itime)),'k-','LineWidth',5);
  axes(ax(2));
  p2=plot(time(itime),sum(population_size(ereg,itime))/1E6,'k-');
  set(ax(1),'YAxisLocation','left','XLim',etimelim,'box','on','Ylim',[0 10],'color','none');
  set(ax(2),'YAxisLocation','right','XLim',etimelim,'box','off','Ylim',[0 15],...
      'color','none','YColor','r');
  set(p2,'LineWidth',4,'color','r','Linestyle','--');
  pname=sprintf('trajectory_amant_nofluc_%s_%d','population_density',length(ereg));
  set(p1a,'visible','off');
  set(findobj('-property','fontsize'),'FontSize',18);
  cl_bcad(ax(1));
  cl_bcad(ax(2));
  cl_fixticklabel(ax(2),'b');
  cl_print('name',pname,'ext','pdf');  
  
  figure(54); clf reset; hold on;
  itime=find(time>=ustimelim(1) & time<=ustimelim(2));
  ax(1)=gca;
  ax(2)=axes;
  set(ax,'FontSize',18);
  axes(ax(1));
  p1a=plot(time(itime),population_density(usreg,itime),'k-','Linewidth',1.5,'Color',...
      0.7*[1 1 1]);
  p1b=plot(time(itime),mean(population_density(usreg,itime)),'k-','LineWidth',5);
  axes(ax(2));
  p2=plot(time(itime),sum(population_size(usreg,itime))/1E6,'k-');
  set(ax(1),'YAxisLocation','left','XLim',ustimelim,'box','on','Ylim',[0 2],'color','none');
  set(ax(2),'YAxisLocation','right','XLim',ustimelim,'box','off','Ylim',[0 4],...
      'color','none','YColor','r');
  set(p2,'LineWidth',4,'color','r','Linestyle','--');
  pname=sprintf('trajectory_amant_nofluc_%s_%d','population_density',length(usreg));
  set(p1a,'visible','off');
  cl_bcad(ax(1));
  cl_bcad(ax(2));
  cl_fixticklabel(ax(1),'b');
  cl_print('name',pname,'ext','pdf');  
 
  figure(55); clf reset; hold on;
  itime=find(time>=etimelim(1) & time<=etimelim(2));
  set(gca,'FontSize',18);
  p1a=plot(time(itime),economies(ereg,itime),'k-','Linewidth',1.5,'Color',...
      0.7*[1 1 1]);
  p1b=plot(time(itime),mean(economies(ereg,itime)),'k-','LineWidth',5);
  set(gca,'YAxisLocation','left','XLim',etimelim,'box','on','Ylim',[0 6.5],'color','none');
  pname=sprintf('trajectory_amant_nofluc_%s_%d','economies',length(ereg));
  set(p1a,'visible','off');
  cl_fixticklabel(gca,'b');
  cl_bcad;
  cl_print('name',pname,'ext','pdf');  

  figure(56); clf reset; hold on;
  set(gca,'FontSize',18);
  itime=find(time>=ustimelim(1) & time<=ustimelim(2));
  p1a=plot(time(itime),economies(usreg,itime),'k-','Linewidth',1.5,'Color',...
      0.7*[1 1 1]);
  p1b=plot(time(itime),mean(economies(usreg,itime)),'k-','LineWidth',5);
  set(gca,'YAxisLocation','left','XLim',ustimelim,'box','on','Ylim',[0 6.5],'color','none');
  pname=sprintf('trajectory_amant_nofluc_%s_%d','economies',length(usreg));
  set(p1a,'visible','off');
  cl_fixticklabel(gca,'l');
  cl_bcad;
  cl_print('name',pname,'ext','pdf');  

  figure(57); clf reset; hold on;
  set(gca,'FontSize',18);
  itime=find(time>=etimelim(1) & time<=etimelim(2));
  p1a=plot(time(itime),farming(ereg,itime),'k-','Linewidth',1.5,'Color',...
      0.7*[1 1 1]);
  p1b=plot(time(itime),mean(farming(ereg,itime)),'k-','LineWidth',5);
  set(gca,'YAxisLocation','left','XLim',etimelim,'box','on','Ylim',[0 1],'color','none');
  pname=sprintf('trajectory_amant_nofluc_%s_%d','farming',length(ereg));
  set(p1a,'visible','off');
  cl_percent;
  cl_fixticklabel(gca,'b');
  cl_bcad;
  cl_print('name',pname,'ext','pdf');  

  figure(58); clf reset; hold on;
  set(gca,'FontSize',18);
  itime=find(time>=ustimelim(1) & time<=ustimelim(2));
  p1a=plot(time(itime),farming(usreg,itime),'k-','Linewidth',1.5,'Color',...
      0.7*[1 1 1]);
  p1b=plot(time(itime),mean(farming(usreg,itime)),'k-','LineWidth',5);
  set(gca,'YAxisLocation','left','XLim',ustimelim,'box','on','Ylim',[0 1],'color','none');
  pname=sprintf('trajectory_amant_nofluc_%s_%d','farming',length(usreg));
  set(p1a,'visible','off');
  cl_percent;
  cl_fixticklabel(gca,'l');
  cl_bcad;
  cl_print('name',pname,'ext','pdf');  
  
  figure(59); clf reset; hold on;
  set(gca,'FontSize',18);
  itime=find(time>=etimelim(1) & time<=etimelim(2));
  p1a=plot(time(itime),economies(ereg,itime)./economies_potential(ereg,itime),'k-','Linewidth',1.5,'Color',...
      0.7*[1 1 1]);
  p1b=plot(time(itime),mean(economies(ereg,itime)./economies_potential(ereg,itime)),'k-','LineWidth',5);
  set(gca,'YAxisLocation','left','XLim',etimelim,'box','on','Ylim',[0 1],'color','none');
  pname=sprintf('trajectory_amant_nofluc_%s_%d','qeconomies',length(ereg));
  set(p1a,'visible','off');
  cl_percent;
  cl_bcad;
  cl_print('name',pname,'ext','pdf');  

  figure(60); clf reset; hold on;
  set(gca,'FontSize',18);
  itime=find(time>=ustimelim(1) & time<=ustimelim(2));
  p1a=plot(time(itime),economies(ereg,itime)./economies_potential(ereg,itime),'k-','Linewidth',1.5,'Color',...
      0.7*[1 1 1]);
  p1b=plot(time(itime),mean(economies(ereg,itime)./economies_potential(ereg,itime)),'k-','LineWidth',5);
  set(gca,'YAxisLocation','left','XLim',ustimelim,'box','on','Ylim',[0 1],'color','none');
  pname=sprintf('trajectory_amant_nofluc_%s_%d','qeconomies',length(usreg));
  set(p1a,'visible','off');
  cl_percent;
  cl_bcad;
  cl_fixticklabel(gca,'b');
  cl_print('name',pname,'ext','pdf');  
  
  figure(51); clf reset; hold on;
  set(gca,'FontSize',18);
  itime=find(time>=etimelim(1) & time<=etimelim(2));
  p1a=plot(time(itime),economies_potential(ereg,itime),'k-','Linewidth',1.5,'Color',...
      0.7*[1 1 1]);
  p1b=plot(time(itime),mean(economies_potential(ereg,itime)),'k-','LineWidth',5);
  set(gca,'YAxisLocation','left','XLim',etimelim,'box','on','Ylim',[0 6.5],'color','none');
  pname=sprintf('trajectory_amant_nofluc_%s_%d','economies_potential',length(ereg));
  set(p1a,'visible','off');
  cl_bcad;
  cl_fixticklabel(gca,'l');
  cl_print('name',pname,'ext','pdf');  

  figure(52); clf reset; hold on;
  set(gca,'FontSize',18);
  itime=find(time>=ustimelim(1) & time<=ustimelim(2));
  p1a=plot(time(itime),economies_potential(usreg,itime),'k-','Linewidth',1.5,'Color',...
      0.7*[1 1 1]);
  p1b=plot(time(itime),mean(economies_potential(usreg,itime)),'k-','LineWidth',5);
  set(gca,'YAxisLocation','left','XLim',ustimelim,'box','on','Ylim',[0 6.5],'color','none');
  pname=sprintf('trajectory_amant_nofluc_%s_%d','economies_potential',length(usreg));
  set(p1a,'visible','off');
  cl_bcad;
  cl_print('name',pname,'ext','pdf');  
  
  
end
  

if any(doplot==6)
    
    etimelime=[-7000 1000];
    ustimelim=etimelim;
  % Figure 5 trajectories in Europe and NAM
  file='../../amant_nospread.nc';
  ncid=netcdf.open(file,'NOWRITE');
  time=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'time'));
  area=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'area'));
  population_density=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'population_density'));
  population_size=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'population_size'));
  economies=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'economies'));
  economies_potential=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'economies_potential'));
  farming=netcdf.getVar(ncid,netcdf.inqVarID(ncid,'farming'));
  netcdf.close(ncid);
  
  figure(53); clf reset; hold on;
  itime=find(time>=etimelim(1) & time<=etimelim(2));
  ax(1)=gca;
  ax(2)=axes;
  axes(ax(1));
  set(ax,'FontSize',18);
  p1a=plot(time(itime),population_density(ereg,itime),'k-','Linewidth',1.5,'Color',...
      0.7*[1 1 1]);
  p1b=plot(time(itime),mean(population_density(ereg,itime)),'k-','LineWidth',5);
  axes(ax(2));
  p2=plot(time(itime),sum(population_size(ereg,itime))/1E6,'k-');
  set(ax(1),'YAxisLocation','left','XLim',etimelim,'box','on','Ylim',[0 10],'color','none');
  set(ax(2),'YAxisLocation','right','XLim',etimelim,'box','off','Ylim',[0 15],...
      'color','none','YColor','r');
  set(p2,'LineWidth',4,'color','r','Linestyle','--');
  pname=sprintf('trajectory_amant_nospread_%s_%d','population_density',length(ereg));
  set(p1a,'visible','off');
  set(findobj('-property','fontsize'),'FontSize',18);
  cl_bcad(ax(1));
  cl_bcad(ax(2));
  cl_fixticklabel(ax(2),'b');
  cl_print('name',pname,'ext','pdf');  
  
  figure(54); clf reset; hold on;
  itime=find(time>=ustimelim(1) & time<=ustimelim(2));
  ax(1)=gca;
  ax(2)=axes;
  set(ax,'FontSize',18);
  axes(ax(1));
  p1a=plot(time(itime),population_density(usreg,itime),'k-','Linewidth',1.5,'Color',...
      0.7*[1 1 1]);
  p1b=plot(time(itime),mean(population_density(usreg,itime)),'k-','LineWidth',5);
  axes(ax(2));
  p2=plot(time(itime),sum(population_size(usreg,itime))/1E6,'k-');
  set(ax(1),'YAxisLocation','left','XLim',ustimelim,'box','on','Ylim',[0 2],'color','none');
  set(ax(2),'YAxisLocation','right','XLim',ustimelim,'box','off','Ylim',[0 4],...
      'color','none','YColor','r');
  set(p2,'LineWidth',4,'color','r','Linestyle','--');
  pname=sprintf('trajectory_amant_nospread_%s_%d','population_density',length(usreg));
  set(p1a,'visible','off');
  cl_bcad(ax(1));
  cl_bcad(ax(2));
  cl_fixticklabel(ax(1),'b');
  cl_print('name',pname,'ext','pdf');  
 
  figure(55); clf reset; hold on;
  itime=find(time>=etimelim(1) & time<=etimelim(2));
  set(gca,'FontSize',18);
  p1a=plot(time(itime),economies(ereg,itime),'k-','Linewidth',1.5,'Color',...
      0.7*[1 1 1]);
  p1b=plot(time(itime),mean(economies(ereg,itime)),'k-','LineWidth',5);
  set(gca,'YAxisLocation','left','XLim',etimelim,'box','on','Ylim',[0 6.5],'color','none');
  pname=sprintf('trajectory_amant_nospread_%s_%d','economies',length(ereg));
  set(p1a,'visible','off');
  cl_fixticklabel(gca,'b');
  cl_bcad;
  cl_print('name',pname,'ext','pdf');  

  figure(56); clf reset; hold on;
  set(gca,'FontSize',18);
  itime=find(time>=ustimelim(1) & time<=ustimelim(2));
  p1a=plot(time(itime),economies(usreg,itime),'k-','Linewidth',1.5,'Color',...
      0.7*[1 1 1]);
  p1b=plot(time(itime),mean(economies(usreg,itime)),'k-','LineWidth',5);
  set(gca,'YAxisLocation','left','XLim',ustimelim,'box','on','Ylim',[0 6.5],'color','none');
  pname=sprintf('trajectory_amant_nospread_%s_%d','economies',length(usreg));
  set(p1a,'visible','off');
  cl_fixticklabel(gca,'l');
  cl_bcad;
  cl_print('name',pname,'ext','pdf');  

  figure(57); clf reset; hold on;
  set(gca,'FontSize',18);
  itime=find(time>=etimelim(1) & time<=etimelim(2));
  p1a=plot(time(itime),farming(ereg,itime),'k-','Linewidth',1.5,'Color',...
      0.7*[1 1 1]);
  p1b=plot(time(itime),mean(farming(ereg,itime)),'k-','LineWidth',5);
  set(gca,'YAxisLocation','left','XLim',etimelim,'box','on','Ylim',[0 1],'color','none');
  pname=sprintf('trajectory_amant_nospread_%s_%d','farming',length(ereg));
  set(p1a,'visible','off');
  cl_percent;
  cl_fixticklabel(gca,'b');
  cl_bcad;
  cl_print('name',pname,'ext','pdf');  

  figure(58); clf reset; hold on;
  set(gca,'FontSize',18);
  itime=find(time>=ustimelim(1) & time<=ustimelim(2));
  p1a=plot(time(itime),farming(usreg,itime),'k-','Linewidth',1.5,'Color',...
      0.7*[1 1 1]);
  p1b=plot(time(itime),mean(farming(usreg,itime)),'k-','LineWidth',5);
  set(gca,'YAxisLocation','left','XLim',ustimelim,'box','on','Ylim',[0 1],'color','none');
  pname=sprintf('trajectory_amant_nospread_%s_%d','farming',length(usreg));
  set(p1a,'visible','off');
  cl_percent;
  cl_fixticklabel(gca,'l');
  cl_bcad;
  cl_print('name',pname,'ext','pdf');  
  
  
end


%% Figure 7 histogram of timing
if any(doplot==7)
  [d,b]=clp_woodland_histogram('file','../../amant_nospread.nc','sce','nospread','fig',2);
  [d,b]=clp_woodland_histogram('file','../../amant_nofluc.nc','sce','nofluc','fig',1);
  [d,b]=clp_woodland_histogram('file','../../amant_base.nc','sce','base','fig',0);
end

return

