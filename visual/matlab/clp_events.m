function clp_events(varargin)

arguments = {...
  {'basedir','../../examples/setup/685'},...
  {'reg','lbk'},... 
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  lv=length(a.value{i});
  if (lv>1 & iscell(a.value{i}))
    for j=1:lv
      eval( [a.name{i} '{' num2str(j) '} = ''' char(clp_valuestring(a.value{i}(j))) ''';']);         
    end
  else
    eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
  end
end


regevents=load('../../eventregtime.tsv','-ascii');
regevents(regevents<0)=NaN;

holodir='/h/lemmen/projects/glues/m/holocene';
datafile=fullfile(holodir,'proxysites.csv');
evinfo = read_textcsv(datafile, ';','"');

evseries=load(fullfile(basedir,'EvSeries.dat'),'-ascii');
evseries(evseries<0)=NaN;
evradius=load(fullfile(basedir,'EventInRad.dat'),'-ascii');
evregion=load(fullfile(basedir,'EventInReg.dat'),'-ascii');
evcolors=jet(8);

reg='lbk'; [ireg,nreg,loli,lali]=find_region_numbers(reg);
lonlim=loli; latlim=lali;

figure(1); clf reset;
clp_basemap('latlim',latlim,'lonlim',lonlim);
clp_relief;
%m_grid('color','y');
ax0=get(gca);
pos0=get(gca,'Position');



for ir=20:5:length(ireg)
  [h,llimit,llimit,rlon,rlat]=clp_regionpath('reg',ireg(ir));
  pt(ir)=m_text(rlon,rlat,num2str(ireg(ir)),'FontSize',16,'FontWeight','bold','Color','m');
  
  ph(ir)=h; 
  pm(ir)=m_plot(rlon,rlat,'k*');
    
  evids=evregion(ireg(ir),:)
  evids=evids(evids>0);
  for ie=1:length(evids)
    ps(ie)=m_plot([evinfo.Longitude(evids(ie)) rlon],[evinfo.Latitude(evids(ie)) rlat],'k-');
    pl(ie)=m_plot([evinfo.Longitude(evids(ie))],[evinfo.Latitude(evids(ie))],'ro','MarkerSize',...
        10-evradius(ireg(ir),ie),'MarkerFaceColor',evcolors(ie,:),'MarkerEdgeColor',evcolors(ie,:));
  end
  
  nevids=length(evids);
  width=pos0(3)/2;
  height=0.8*pos0(4)/nevids;
  ax1=axes('Position',[0.5 pos0(2)+0.1 width height*nevids]);
  hold on;
  for ie=1:sum(isfinite(regevents(ireg(ir),:)))
    plot(repmat(regevents(ireg(ir),ie)/1000,2,1),[0 1],'r-');
  end  
  set(gca,'Xlim',[3 12],'XDir','reverse','YLim',[0 1],'color','none','box','off','YTick',[]);

  thresh=2;%1.5.^[-1 0 1 2];
  
  for ie=1:1:nevids
    figure(2); clf;
    data=clp_single_timeseries_trend(evids(ie),'timelim',[0 12],'highpass',0.050,'lowpass',2.0);
    clf; hold on;
    data.norm=cl_normalize(data.m50-data.m2000);
    plot(data.ut,data.norm,'b-');
    peakindex=cl_findpeaks(data.norm,thresh);
    peakindex=peakindex(isfinite(peakindex));
    plot(data.ut(peakindex),data.norm(peakindex),'rv');;
    figure(1);

    ax(ie)=axes('Position',[0.5 pos0(2)+0.1+height*(ie-1.0) width height],...
        'XDir','reverse','Xlim',[3 12]);
    hold on;
    %plot(data.ut,cl_normalize(data.m50-data.m2000),'k-');
    plot(data.ut,data.norm,'k-');
    plot(data.ut(peakindex),data.norm(peakindex),'r.');
    plot(evseries(evids(ie),:),1,'kv','MarkerFaceColor',evcolors(ie,:),'MarkerSize',7);
    
    set(gca,'color','none','box','off','YTick',[]);
    if ie>0 axis off; end  
    
    evtext=sprintf('%s (%s %s)',evinfo.Plotname{evids(ie)},evinfo.Datafile{evids(ie)},evinfo.Proxy{evids(ie)});
    text(11.8,4.5,evtext,'Horizontal','left','FontSize',7,'Interpreter','none');
    text(12.1,0,num2str(evinfo.No(evids(ie))),'Horizontal','right','FontSize',9,'Interpreter','none');
  end
  
  cl_print('name',sprintf('events_map_%03d',ireg(ir)),'ext','pdf');
  
  delete(ph(ir),pt(ir));
  delete(pm(ir));
  delete(ax1,ax);
  delete(ps,pl);
  
end
return
end