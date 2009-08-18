function plot_timeseries_anomaly_publication

cl_register_function();

  figure(1);
  clf reset;
  
  lstyles=['k-.';'r--';'b-.';'b--'];
  
  % Get solar proxies
  %p(1)=find_proxy('14c','Datafile');
  %p(2)=find_proxy('Be10','Datafile');
  p(1)=find_proxy('sunspot','Datafile');
  
  axes('position',[0.1 0.1 0.8 0.22]);
  t1=plot_single_timeseries_anomaly(p(1).No,'NoTitle','NoArrow');
  t=text(11,-1.5,'Sunspot number','FontSize',17,'HorizontalAlignment','right');

  %axes('position',[0.1 0.25 0.8 0.15]);
  %t2=plot_single_timeseries_anomaly(p(2).No,'NoTitle','NoXTicks','LineStyle',lstyles);
  
  % Get selected proxies
  p(2)=find_proxy('sajama_d18','Datafile');
  p(3)=find_proxy('holo_Dry_SouthChina','Datafile');
  p(4)=find_proxy('SE Europe','Plotname');
  %p(6)=find_proxy('holo_d18O_ice','Datafile');
 
  for i=2:4
    axes('position',[0.1 0.1+(i-1)*0.22 0.8 0.22]);
    plot_single_timeseries_anomaly(p(i).No,'NoTitle','NoXTicks','NoArrow','LineStyle',lstyles);
    t=text(11,-1.5,[ p(i).Plotname ; p(i).Proxy],'FontSize',17,'HorizontalAlignment','right')
  end
  
  plot_multi_format(gcf,'timeseries_anomaly_publication');
    
  return
