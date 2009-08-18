function plot_timeseries_publication

cl_register_function();

  figure(1);
  clf reset;
  
  lstyles=['k-.';'r--';'b-.';'b--'];
  
  % Get solar proxies
  p(1)=find_proxy('14c','Datafile');
  p(2)=find_proxy('Be10','Datafile');
  
 for i=1
  axes('position',[0.1 0.1 0.8 0.15]);
  plot_single_timeseries(p(i).No,'NoTitle','NoLegend');
     yl=get(gca,'Ylim');
     
    yt=get(gca,'YTick')
    yt([1,length(yt)])=[];
    set(gca,'YTick',yt);
    t=text(4,yl(1)+0.2*(yl(2)-yl(1)),p(i).Plotname,'FontSize',18,'HorizontalAlignment','left')
end

for i=2
  axes('position',[0.1 0.25 0.8 0.15]);
  plot_single_timeseries(p(i).No,'NoTitle','NoXTicks','NoLegend','LineStyle',lstyles);
      yl=get(gca,'Ylim');
    yt=get(gca,'YTick')
    yt([1,length(yt)])=[];
    set(gca,'YTick',yt);
    t=text(4,yl(1)+0.7*(yl(2)-yl(1)),p(i).Plotname,'FontSize',18,'HorizontalAlignment','left')
end
  
  % Get selected proxies
  p(3)=find_proxy('sajama_d18','Datafile');
  p(4)=find_proxy('holo_Dry_SouthChina','Datafile');
  p(5)=find_proxy('SE Europe','Plotname');
  
  ptmp=find_proxy('holo_d18O_ice','Datafile');
 p(6)=ptmp(1);
 
 
  for i=[3,5,6]
    axes('position',[0.1 0.1+(i-1)*0.15 0.8 0.15]);
    plot_single_timeseries(p(i).No,'NoTitle','NoXTicks','NoLegend');
    yl=get(gca,'Ylim');
    yt=get(gca,'YTick')
    yt([1,length(yt)])=[];
    set(gca,'YTick',yt);
    t=text(4,yl(1)+0.2*(yl(2)-yl(1)),p(i).Plotname,'FontSize',18,'HorizontalAlignment','left')
  end
  for i=[4]
    axes('position',[0.1 0.1+(i-1)*0.15 0.8 0.15]);
    plot_single_timeseries(p(i).No,'NoTitle','NoXTicks');
    yl=get(gca,'Ylim');
    yt=get(gca,'YTick')
    yt([1,length(yt)])=[];
    set(gca,'YTick',yt);
    t=text(4,yl(1)+0.8*(yl(2)-yl(1)),p(i).Plotname,'FontSize',18,'HorizontalAlignment','left')
  end

  plot_multi_format(gcf,'timeseries_publication');
    
  return
