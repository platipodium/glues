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

% p(1)={1 'N Atlantic' 'SST' [1 11] 'Sarnthein 2003'};
% p(2)={7 'N Norway' 'T' [1 8] 'Husum 2004'};
% p(3)={13 'NW Alaska' 'Mg/Ca T' [0 11] 'Hu 1998'};
% p(4)={25 'Swiss Alpes' 'T7' [0 9] 'Wick 2003'};
% p(5)={39 'Marmara Sea' 'Uk SST' [0 11] 'Herzschuh 2004'};
% p(6)={53 'E China Sea' 'SST' [0 11] 'Fengming 2008'};
% p(7)={54 'E China Sea' 'SST' [1 11] 'Sun 2005'};
% p(8)={81 'Arabian Sea' 'SSTW' [0 11] 'Schulz 1995'};
% p(9)={85 'CAriaco Basin' 'SST' [0 11] 'Lea 2003'};
% p(10)={111 'Angola Basin' 'Uk SST' [0 11] 'Kim 2003'};
% p(11)={117 'Chilean Coast' 'SST' [0 8] 'Lamy 2001'};
% p(12)={10 'N Finland' 'T' [1 8] 'Husum 2004'};
% p(13)={13 'NW Europe' 'dT' [0 11] 'Davis 2003'};
% p(14)={32 'C Italy' 'MgCa T' [1 7] 'Drysdale 2006'};
% p(15)={42 'SW Europe' 'dT' [0 11] 'Davis 2003'};
% p(16)={44 'SE Europe' 'dT' [0 11] 'Davis 2003'};
% p(17)={64 'Trop Atlantic' 'SST' [011] 'deMenocal 2000'};
% p(18)={32 'C Italy' 'MgCa T' [1 7] 'Drysdale 2006'};
% p(15)={42 'SW Europe' 'dT' [0 11] 'Davis 2003'};
% p(16)={44 'SE Europe' 'dT' [0 11] 'Davis 2003'};
% p(17)={64 'Trop Atlantic' 'SST' [011] 'deMenocal 2000'};
% 
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

for i=1:1
  figure(i);
  clf reset;

  m_proj('miller','lat',latlim,'lon',lonlim);
  m_coast('color',[0.8 0.8 1]);
  m_grid('box','fancy','tickdir','in');
  m_line(lon(i),lat(i),'Color','red','MarkerSize',8,'Marker','diamond','LineWidth',2);
  m_line(lon(i),lat(i),'Color','red','MarkerSize',1,'Marker','+');

  axpos(1,:)=get(gca,'Position');
  %% Put the timeseries to the right or left
  if lon(i)<0 
    axpos(2,:)=axpos(1,:).*[1 1 0.35 0.3]+[0.57*axpos(3) 0.33*axpos(4) 0 0];
  end
  
  a1=gca;
  axes('Position',axpos(2,:));
  a2=gca;
  trend=clp_single_timeseries_trend(i,'FontSize',fontsize,'no_title',1,'no_legend',1);
  
  infotext=sprintf('%s %.2fE %.2fN\n%s (%s)\n',name{i},lon(i),lat(i),proxy{i},src{i});
  title(infotext);
  
  axes(a1);
  m_text(lon(i)+5,lat(i),num2str(trend))
 
  %plot_multi_format(20,fullfile(dirs.plot,['proxy_overview_' num2str(i)]));
end  


% 37 Pf
% 103 P
% 26 P 
% 38 P (AC
% 46 P
% 80 P diatom
