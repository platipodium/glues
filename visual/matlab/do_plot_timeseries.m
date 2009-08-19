function do_plot_timeseries
% DO_PLOT_TIMESERIES

% requires 
% * get_files.m
% * plot_single_timeseries.m

cl_register_function();

[d,f]=get_files;

d.proxies=fullfile(d.proxies,'redfit/data');
d.raw=fullfile(d.proxies,'eleven');
d.detrended=fullfile(d.proxies,'detrended');
d.normalised=fullfile(d.proxies,'normalised');
d.deevented=fullfile(d.proxies,'deevented');
d.disturbed=fullfile(d.proxies,'d0.15');
d.plot=fullfile(d.proxies,'plot');

f=dir(d.raw);
clear files
j=0;
for i=1:length(f)
  file=fullfile(d.raw,f(i).name);
  [p,n,e,v]=fileparts(file);
  if strcmp(e,'.dat')
     j=j+1;
     files{j}=f(i).name;
  end
end

n=j;
% Select time series here, if not continue with all
%n=1;


% directories from which to plot
pdirs={d.raw,d.detrended,d.normalised,d.deevented,d.disturbed};
nd=length(pdirs);

figure(1);
%set(gcf,'Position');

for i=1:n
  clf reset;
  [d1,name,d2,d3]=fileparts(files{i});
  plotfile=fullfile(d.plot,['timeseries_' name ]);
  %if exist([plotfile '.eps'],'file') continue; end
  
  for id=1:nd
    %if ~exist(pdirs{id},'file') continue; end
    file=fullfile(pdirs{id},files{i})
    data=load(file);
    pfiles{id}=file;
    switch pdirs{id}
        case d.raw, t.raw=data(:,1); y.raw=data(:,1);
        case d.detrended, y.detrended=data(:,2);
        case d.normalised, y.normalised=data(:,2);
        case d.deevented, y.deevented=data(:,2);
        case pdirs{5}, t.disturbed=data(:,1);
    end
  end
  
  id=1; dx=0.5*(1-mod(id,2)); dy=0.5*(1-floor((id-1)/2));
  axes('Position',[dx+0.05,dy+0.02,0.44,0.44]);
  plot_single_timeseries(pfiles{id},'Title','Raw data','NoXTicks');
 
  id=2; dx=0.5*(1-mod(id,2)); dy=0.5*(1-floor((id-1)/2));
  axes('Position',[dx+0.05,dy+0.02,0.44,0.44]);
  plot_single_timeseries(pfiles{3},'Title','Detrended/normalised + deevented + disturbed','NoLowPass','NoXTicks');
  hold on
  plot(t.raw,movavg(t.raw,y.deevented,0.05),'b-');
  plot(t.disturbed,movavg(t.disturbed,y.deevented,0.05),'m-');
  legend('Normalised','Running mean', 'Deevented','Disturbed');
  
  id=3; dx=0.5*(1-mod(id,2)); dy=0.5*(1-floor((id-1)/2));
  axes('Position',[dx+0.05,dy+0.05,0.44,0.44]);
  plot(t.raw,'r-');
  hold on;
  plot(t.disturbed,'b-');
  title(sprintf('Sampling of time (n=%d, \\tau=%d)',length(t.raw),round(1000*(max(t.raw)-min(t.raw))/length(t.raw))));
  xlabel('Sample number');
  ylabel('Time (ka BP)');
  text(2,mean(t.raw),name,'FontSize',20,'Interpreter','none','HorizontalAlignment','left');
  
  id=4;  dx=0.5*(1-mod(id,2)); dy=0.5*(1-floor((id-1)/2));
  axes('Position',[dx+0.05,dy+0.05,0.44,0.44]);
  pl(1)=plot_powerspectrum(t.raw,y.deevented);
  hold on;
  pl(2)=plot_powerspectrum(t.raw,y.detrended);
  set(pl(2),'color','k');
  pl(3)=plot_powerspectrum(t.raw,y.normalised);
  set(pl(3),'color','m');
  pl(4)=plot_powerspectrum(t.disturbed,y.deevented);
  set(pl(4),'color','r');
  legend('Deevented','Detrended','Normalised','Disturbed');
 
  plot_multi_format(1,plotfile);
  
  
  end

end

