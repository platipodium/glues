function clp_events(varargin)

arguments = {...
  {'basedir','../../examples/setup/685'},...
  {'reg','lbk'},... 
  {'timelim',[3 11]},...
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


%regevents=load('../../eventregtime.tsv','-ascii');
%regevents(regevents<0)=NaN;


if(1==2)
  holodir='/h/lemmen/projects/glues/m/holocene';
  datafile=fullfile(holodir,'proxysites.csv');
  evinfo = read_textcsv(datafile, ';','"');
  evseries=load(fullfile(basedir,'EvSeries.dat'),'-ascii');
  evseries(evseries<0)=NaN;
  evradius=load(fullfile(basedir,'EventInRad.dat'),'-ascii');
  evregion=load(fullfile(basedir,'EventInReg.dat'),'-ascii');
else
  holodir='';
  basedir=holodir;
  datafile=fullfile(holodir,'proxydescription_265_134.mat');
  load(datafile);
  evseries=load(fullfile(basedir,'EventSeries_134.tsv'),'-ascii');
  evseries(evseries<0)=NaN;
  evradius=load(fullfile(basedir,'EventInRad_134_685.tsv'),'-ascii');
  evregion=load(fullfile(basedir,'EventInReg_134_685.tsv'),'-ascii');
end  
  
evcolors=jet(8);
evcolors=0.5*evcolors;
    hsv=rgb2hsv(evcolors);
    %brightcolors=brighten(evcolors,0.99);
    hsv(:,2)=0.06;
    hsv(:,3)=1;
    brightcolors=hsv2rgb(hsv);


evseries=evseries(:,1:end-2);

reg='lbk'; [ireg,nreg,loli,lali]=find_region_numbers(reg);
lonlim=loli; latlim=lali;

try close(2); catch; end
figure(2); clf reset;
pos=get(gcf,'Position');
set(gcf,'position',pos+[0 -pos(2) 0 pos(4)]);

figure(1); clf reset;
pos=get(gcf,'Position');
clp_basemap('latlim',latlim,'lonlim',lonlim,'nocoast',1,'nogrid',1);
%clp_relief;
%m_grid('color','y');
ax0=get(gca);
pos0=get(gca,'Position');

dg=repmat(0.4,1,3);
lg=repmat(0.85,1,3);
mg=repmat(0.65,1,3);
fw=repmat(0.99,1,3);
m_coast('patch',lg,'EdgeColor','none');
c=get(gca,'Children');
set(c,'FaceColor',lg);
set(c(end),'FaceColor',fw);
set(c(15),'FaceColor',fw);


for ir=39:1:39%length(ireg)

     % cl_print('name',sprintf('events_map_%03d',ireg(ir)),'ext','pdf');

    figure(1);
  [h,llimit,llimit,rlon,rlat]=clp_regionpath('reg',ireg(ir));
  [lon lat rlon rlat]=cl_regionpath('reg',ireg(ir));
  set(gca,'FontName','Times');
  set(h,'FaceColor',lg,'EdgeColor','k','LineWidth',2);
  pt(ir)=m_text(rlon,rlat,num2str(ireg(ir)),'FontSize',16,...
      'FontWeight','bold','Color','w','Vertical','middle','Horizontal','center','visible','off');
  
  ph(ir)=h; 
  pm(ir)=m_plot(rlon,rlat,'k*','visible','off');
  esd=cl_esd(lon,lat);
  
  
  evids=evregion(ireg(ir),:)
  evids=evids(evids>0);
 
  mrad=1:max(evradius(ireg(ir),:))+1;
  for ie=1:length(mrad)
    pr{ie}=m_range_ring(rlon,rlat,mrad(ie)*esd/2);
    set(pr{ie},'Color',mg,'Linestyle','--','linewidth',2);
  end
  
  %evids(evids>25)=evids(evids>25)+1;
  evids=sort(evids);
  for ie=1:length(evids)
    %ps(ie)=m_plot([evinfo.Longitude(evids(ie)) rlon],[evinfo.Latitude(evids(ie)) rlat],...
    %    'k--','Color',dg,'LineWidth',2);
    pl(ie)=m_plot([evinfo.Longitude(evids(ie))],[evinfo.Latitude(evids(ie))],'rv','MarkerSize',...
        11,'MarkerFaceColor',brightcolors(ie,:),'MarkerEdgeColor',evcolors(ie,:));
    xpos(ie)=get(pl(ie),'XData');
    ypos(ie)=get(pl(ie),'YData');
  end
  
  for ie=1:length(evids)
     isame=find(xpos(ie)==xpos & ypos(ie)==ypos);
     nsame=numel(isame);
     if nsame>1
       [xc,yc]=distribute_around(xpos(ie(1)),ypos(ie(1)),nsame,0.005);
       for is=1:nsame
         set(pl(isame(is)),'XData',xc(is),'YData',yc(is));
       end
     end
  end
  
  
  uistack(ph(ir),'top');
  uistack(pt(ir),'top');
  uistack(pl,'top');
  
  figure(2); 
  
  nevids=length(evids);
  %if rlon>(lonlim(2)-lonlim(1))/2
    %set(ax1,'Position',[0.15 pos0(2)+0.1 width height*nevids],'YAxisLocation','left');
  %end
  hold on;
  %for ie=1:sum(isfinite(regevents(ireg(ir),:)))
    %plot(repmat(regevents(ireg(ir),ie)/1000,2,1),[0 1],'r-');
  %end  
  set(gca,'Xlim',timelim,'XDir','reverse','YLim',[0 1],'color','none','box','off','YTick',[]);
  ax1=gca;
  pos0=get(ax1,'Position');
  width=pos0(3)/2.2;
  height=0.8*pos0(4)/(nevids-1);
  %ax1=axes('Position',[0.5 pos0(2)+0.1 width height*nevids],'YAxisLocation','right');
  
  cl_xticktitle('ka BP');

  %thresh=2;%1.5.^[-1 0 1 2];
  
  for ie=1:nevids
    figure(3); clf;
    if size(evseries,1)==124
      data=clp_single_timeseries_trend(evids(ie),'timelim',[0 12],'highpass',0.050,'lowpass',2.0,'file','proxydescription.mat');
    elseif size(evseries,1)==123
      data=clp_single_timeseries_trend(evids(ie),'timelim',[0 12],'highpass',0.050,'lowpass',2.0,'file','proxydescription.mat');
    elseif size(evseries,1)==128
      data=clp_single_timeseries_trend(evids(ie),'timelim',[0 12],'highpass',0.050,'lowpass',2.0,'file','proxydescription_258_128.mat');
    elseif size(evseries,1)==135
      data=clp_single_timeseries_trend(evids(ie),'timelim',[0 12],'highpass',0.050,'lowpass',2.0,'file','proxydescription_265_135.mat');
    elseif size(evseries,1)==134
      data=clp_single_timeseries_trend(evids(ie),'timelim',[0 12],'highpass',0.050,'lowpass',2.0,'file','proxydescription_265_134.mat');
    elseif size(evseries,1)==139
      data=clp_single_timeseries_trend(evids(ie),'timelim',[0 12],'highpass',0.050,'lowpass',2.0,'file','/h/lemmen/projects/glues/glues/glues-1.1.1/visual/matlab/holodata.mat');
    end
    
    % Adaptive threshold needed? 
    thresh=norminv(1-1/length(data.ut));
    
    clf; hold on;
    data.norm=cl_normalize(data.m50-data.m2000);
    plot(data.ut,data.norm,'b-');
    peakindex=cl_findpeaks(data.norm,thresh);
    peakindex=peakindex(isfinite(peakindex));
    plot(data.ut(peakindex),data.norm(peakindex),'rv');
    figure(2); 

    ax(ie)=axes('Position',[pos0(1) 0.03+pos0(2)+height*(8.0-ie) pos0(3) height],...
        'XDir','reverse','Xlim',timelim);
    hold on;
  
    
    patch([timelim,fliplr(timelim)],2*thresh*[1 1 -1 -1],'r','EdgeColor','none',...
        'FaceColor',brightcolors(ie,:));
    data.norm=2*data.norm;
    
    %plot(data.ut,cl_normalize(data.m50-data.m2000),'k-');
    pll(ie)=plot(data.ut,data.norm,'k-','Color',evcolors(ie,:),'LineWidth',1.5);
    %plot(data.ut(peakindex),data.norm(peakindex),'r.');
    %plot(evseries(evids(ie),:),max(data.norm),'ko','MarkerFaceColor',evcolors(ie,:),'MarkerSize',5);
    nie=sum(isfinite(evseries(evids(ie),:)));
    for iie=1:nie
      %iut=find(data.ut<evseries(evids(ie),iie)+0.175 & data.ut>evseries(evids(ie),iie)-0.175); 
      %patch([data.ut(iut) fliplr(data.ut(iut))],[data.norm(iut)' 0*data.norm(iut)'],'r-',...
      %    'FaceColor',evcolors(ie,:),'EdgeColor','none');
      %patch([data.ut(iut) fliplr(data.ut(iut))],[0*data.norm(iut)' data.norm(iut)' ],'r-',...
      %    'FaceColor',evcolors(ie,:),'EdgeColor','none');
      [mut iut]=min(abs(data.ut-evseries(evids(ie),iie)));
      pms(ie,iie)=plot(data.ut(iut),data.norm(iut),'ko','MarkerFaceColor','y','MarkerSize',10,...
          'Color',evcolors(ie,:),'MarkerEdgeColor','none');
     % uistack(pms(ie,iie),'down');
      
    end
    
    uistack(pll(ie),'top');
    
    set(gca,'color','none','box','off','YTick',[],'YAxisLocation','right','Ylim',1.01*cl_minmax(data.norm));
    if ie>0 axis off; end  
    
    
    %evtext=sprintf('%s (%s %s)',evinfo.Plotname{evids(ie)},evinfo.Datafile{evids(ie)},evinfo.Proxy{evids(ie)});
    
    
    evtext=sprintf('%s (%s)',evinfo.Plotname{evids(ie)},evinfo.Proxy{evids(ie)});
    evtext=strrep(evtext,'ö','\"o');
    xlimit=get(gca,'Xlim');
    ptt(ie)=text(xlimit(1)+1,max(data.norm)*1.2,evtext,'vertical','bottom','Horizontal','right','FontSize',12,'Interpreter','latex','color',evcolors(ie,:));
    %text(xlimit(1)-0.5,0,num2str(evinfo.No(evids(ie))),'Horizontal','left','FontSize',9,'Interpreter','none');
    uistack(ptt(ie),'top');
    ppt(ie)=text(xlimit(1)-0.1,0,sprintf('p=.%3d',round(1000*(1-1/length(data.ut)))),'Rotation',90,...
        'VerticalAlignment','top','HorizontalAlignment','center');
    
  end
  
  % Manual tweaking for region 236
  if ireg(ir)==236
     set(ax(1),'Position',get(ax(1),'Position')+[0 +0.075 0 0]);
     set(ax(2),'Position',get(ax(2),'Position')+[0 +0.07 0 0]);
     set(ax(3),'Position',get(ax(3),'Position')+[0 +0.05 0 0]);
     set(ax(4),'Position',get(ax(4),'Position')+[0 +0.040 0 0]);
     set(ax(5),'Position',get(ax(5),'Position')+[0 +0.020 0 0]);
     set(ax(6),'Position',get(ax(6),'Position')+[0 +0.010 0 0]);
     set(ax(7),'Position',get(ax(7),'Position')+[0 -0.0 0 0]);
     set(ax(8),'Position',get(ax(8),'Position')+[0 -0.015 0 0]);
     set(ptt(8),'Position',[ 7.2304   -4.5997   17.3205]);
     set(ptt(7),'Position',[ 7.7650    2.0842   17.3205]);
     set(ptt(6),'Position',[ 5.5899    2.7725   17.3205]);
     set(ptt(5),'Position',[ 6.7327   -3.9104   17.3205]);
     set(ptt(4),'Position',[ 6.4009    1.8139   17.3205]);
     set(ptt(3),'Position',[4.7972    2.7589   17.3205]);
     set(ptt(2),'Position',[ 5.6636    3.1629   17.3205]);
     set(ptt(1),'Position',[4.7235    3.5717   17.3205 ]);
     %get(ptt(3),'Position')
      
  end
  
  figure(1);
  cl_print('name',sprintf('events_map_%03d',ireg(ir)),'ext','pdf');
  
  figure(2);
  cl_print('name',sprintf('events_series_%03d',ireg(ir)),'ext','pdf');
  
  try delete(pr{:}); catch; end
  try delete(ph(ir),pt(ir)); catch; end
  try delete(pm(ir)); catch; end
  try delete(ax1,ax(:)); catch; end
  try delete(ps,pl); catch; end
   
end
return
end