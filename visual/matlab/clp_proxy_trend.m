function clp_proxy_trend(varargin)

% This function plots temperature and precipitation trends from the proxies
% used in the PPP paper proxies are

cl_register_function();

arguments = {...
  {'latlim',[-90 90]},...
  {'lonlim',[-180 180]},...
  {'timelim',[-6000,0]},...
  {'fontsize',16}
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end


if ~exist('holodata.mat','file')
  printf('The file holodata.mat is required\n');
  return;
end

if ~exist('m_proj') addpath('~/matlab/m_map'); end;

[dirs,files]=get_files;
dirs.plot=fullfile(dirs.plot,'proxy_trend');

load('holodata.mat');
n=length(holodata.No);
  
lat=holodata.Latitude;
lon=holodata.Longitude;
ny=holodata.CutoffFreq;
pdf=holodata.SourcePDF;
src=holodata.Source;
comment=holodata.Comment;
no=holodata.No;
nosort=holodata.No_sort;
datafile=holodata.Datafile;
name=holodata.Plotname;
proxy=holodata.Proxy;

pt=strfind(proxy,'P');
pt{:}=1;
j=0;
for i=1:length(pt) if ~isempty(pt{i}) 
  %if strmatch(proxy{i},'TOC') continue; end
  %if strmatch(proxy{i},'Ti') continue; end
  j=j+1;
  ptv(j)=double(pt{i});
  itv(j)=i;
end, end

ntv=length(itv);

for k=1:ntv
  i=itv(k);
  figure(i);
  clf reset;

  m_proj('miller','lat',latlim,'lon',lonlim);
  m_coast('color',[0.6 0.6 0.8]);
  hold on;
  m_grid('box','fancy','tickdir','in');

  axpos(1,:)=get(gca,'Position');
  %% Put the timeseries to the right or left
  if lon(i)<0 
    axpos(2,:)=axpos(1,:).*[1 1 0.35 0.3]+[0.57*axpos(1,3) 0.33*axpos(1,4) 0 0];
  else
    axpos(2,:)=axpos(1,:).*[1 1 0.35 0.3]+[0.05*axpos(1,3) 0.33*axpos(1,4) 0 0];
  end
  
  a1=gca;
  axes('Position',axpos(2,:));
  a2=gca;
  trend=clp_single_timeseries_trend(i,'FontSize',fontsize,'no_title',1,'no_legend',1);
  
  infotext=sprintf('%s %.2fE %.2fN\n%s (%s)\n',name{i},lon(i),lat(i),proxy{i},src{i});
  title(infotext,'background','w');
  
  axes(a1);
  trendtext=sprintf('%.1f ± %.1f',trend)
  set(gca,'color','none');
  if (lon(i)>-90 & lon(i)<0) | (lon(i)>90)
    textoff=-7;
    textalign='right';
  else
    textoff=7;
    textalign='left';
  end
  ht=m_text(lon(i)+textoff,lat(i),trendtext,'color','r','fontsize',15,...
      'background','w','Horizontal',textalign);
  hp=m_line(lon(i),lat(i),'Color','red','MarkerSize',8,'Marker','o','markerfacecolor','r');
 if trend(1)<0 set([ht,hp],'color','b'); end
 if trend(1)<0 set([hp],'markerfacecolor','b'); end
 
  axes(a2);
  %plot_multi_format(20,fullfile(dirs.plot,['proxy_trend_p_' num2str(i)]));
  
  clf reset;
  trend=clp_single_timeseries_trend(i,'FontSize',fontsize,'no_title',1,'no_legend',1);
   title(infotext,'background','w');
 plot_multi_format(20,fullfile(dirs.plot,['proxy_trend_' num2str(i) '_' name]));

  
end  


% 37 Pf
% 103 P
% 26 P 
% 38 P (AC
% 46 P
% 80 P diatom
