function hdl=clp_radiocarbon_sites(dataset)

  figure(1); clf reset;
  m_proj('equidistant','lat',[min(dataset.latitude)-0.5 max(dataset.latitude)+0.5],...
      'lon',[min(dataset.longitude)-0.5 max(dataset.longitude)+0.5]);
  hold on;
  m_coast;
  m_grid;
  dt=250;
  time=1950-dataset.age_cal_bp;
  method='calibrated';
  if all(isnan(time)) time=1950-dataset.age_uncal_bp; method='uncalibrated'; end
  mintime=floor(min(time)/1000);
  maxtime=ceil(max(time)/1000);
  edges=mintime*1000:dt:maxtime*1000;
  nedge=length(edges);
  colors=hsv(nedge);
  for itime=1:nedge-1
    ivalid=find(time>=edges(itime) & time<=edges(itime+1));
    if isempty(ivalid) continue; end
    p(itime)=m_plot(dataset.longitude(ivalid),dataset.latitude(ivalid),'kd','color',colors(itime,:));
  end
  ax1=gca;

  ax2=axes('position',[0.60 0.62 0.25 0.25]);
  h=histc(time,edges);
  bar(edges,h,'histc');
  set(ax2,'Xlim',[mintime*1000 maxtime*1000],'color','none',...
      'YaxisLocation','right','position',[0.61 0.61 0.25 0.25]);
  hold on;
  for itime=1:nedge-1
    ivalid=find(time>=edges(itime) & time<=edges(itime+1));
    if isempty(ivalid) continue; end
    h=histc(time(ivalid),edges);
    ph(itime)=bar(edges,h,'histc');
    set(ph(itime),'FaceColor',colors(itime,:));
    xlabel('year AD');
  end

  
  title(ax1,sprintf('Radiocarbon dates (%s) from %s (n=%d)',method,dataset.filename,length(time)),'Interpreter','none');
  

return
end