function plot_timeseries_anomaly_redfit_publication

cl_register_function();

  figure(1);
  clf reset;
  set(gcf,'Position',[478 129 748 555]);
  
  lstyles=['k-.';'r--';'b-.';'b--'];
  
  % Get solar proxies
  %p(1)=find_proxy('14c','Datafile');
  %p(2)=find_proxy('Be10','Datafile');
  p(1)=find_proxy('sunspot','Datafile');
  
  f=0.28;
  ax(1)=axes('position',[0.05 0.1 0.5 f]);
  t1=plot_single_timeseries_anomaly(p(1).No,'NoTitle','NoArrow');
  t=text(8.8,-1.7,'Sunspot number','FontSize',12,'HorizontalAlignment','right');

  %axes('position',[0.1 0.25 0.8 0.15]);
  %t2=plot_single_timeseries_anomaly(p(2).No,'NoTitle','NoXTicks','LineStyle',lstyles);
  
  % Get selected proxies
  p(2)=find_proxy('sajama_d18','Datafile');
  %p(3)=find_proxy('holo_Dry_SouthChina','Datafile');
  %p(3)=find_proxy('SE Europe','Plotname');
  %p(6)=find_proxy('holo_d18O_ice','Datafile');
   p(3)=find_proxy('Holo_d18O_Soreq','Datafile');

  
  for i=2:3
    ax(i)=axes('position',[0.05 0.1+(i-1)*f 0.5 f]);
    plot_single_timeseries_anomaly(p(i).No,'NoTitle','NoXTicks','NoArrow','LineStyle',lstyles);
    t=text(8,-1.7,[ p(i).Plotname ; p(i).Proxy],'FontSize',12,'HorizontalAlignment','right')
  end
  
  for i=1:1
    ax(3+i)=axes('position',[0.64 0.1+(i-1)*f 0.34 f]);
    plot_single_replacemany(p(i).Datafile,'NoShade','NoLegend','Extra','eleven');
  end
  for i=2:2
    ax(3+i)=axes('position',[0.64 0.1+(i-1)*f 0.34 f]);
    plot_single_replacemany(p(i).Datafile,'NoXTicks','NoLegend','NoShade','Extra','eleven');
  end
  for i=3:3
    ax(3+i)=axes('position',[0.64 0.1+(i-1)*f 0.34 f]);
    plot_single_replacemany(p(i).Datafile,'NoXTicks','NoShade','Extra','eleven');
  end
  
  % Cosmetic changes
  %set(ax(6),'Ylim',[-55,-5]);
  %set(ax(5),'Ylim',[-60,-5]);
  %set(ax(4),'Ylim',[5,45]);
  %legend(ax(6),'Location','NorthEast');
  
  plot_multi_format(gcf,'timeseries_anomaly_redfit_publication');
    
  return
