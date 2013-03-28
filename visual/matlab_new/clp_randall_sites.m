function [sitetimes, sitenumbers]=clp_randall_sites(varargin)

datafile='/Users/lemmen/projects/glues/tex/2013/indusreview/site_chronology.csv';

data=load(datafile);
[~,isort]=sort(data(:,3),'descend');
data=data(isort,:);

% Area in fifth column, default -999 to 1 ha
ismall=find(data(:,5)<0);
data(ismall,5)=2.5;

a=data(:,1)+10*data(:,2)+data(:,3)+10*data(:,4);
[au,ia]=unique(a);
b=data(:,1)+10*data(:,2);
[bu,ib]=unique(b);

[sitetimes,sitenumbers,siteareas]=sitecountarea(data(ia,3:5));

if (nargin>0) return; end

fs=15;
mg=repmat(0.5,1,3);
figure(2); clf reset;

[sx,sy]=cl_stairs(sitetimes,sitenumbers);

subplot(2,2,1); 
ax1=gca; hold on;
set(ax1,'XDir','reverse','Xlim',[-1000,8000],'FontSize',fs);
ps=plot(sx,sy,'k-','LineWidth',2);
yl=get(gca,'YLim');
plot([3200 3200 NaN 2600 2600 NaN 1900 1900 NaN 1300 1300],yl([1 2 1 1 2 1 1 2 1 1 2]),'k--','color',mg);
set(ax1,'XDir','reverse','Xlim',[-1000,8000],'FontSize',fs);
xlabel('Time (year BC)');
ylabel('Area of coexistent sites');

subplot(2,2,2); 
ax2=gca; hold on;
for i=1:length(data(:,1))
  p1(i)=plot(data(i,4:-1:3),repmat(i,1,2),'k-');
end
set(ax2,'XDir','reverse','Xlim',[-1000,8000],'Ylim',[0 length(isort)+1],'FontSize',fs);
yl=get(gca,'YLim');
plot([3200 3200 NaN 2600 2600 NaN 1900 1900 NaN 1300 1300],yl([1 2 1 1 2 1 1 2 1 1 2]),'k--','color',mg);
xlabel('Time (year BC)');
ylabel('Site rank (by first date)');

figure(3);
%subplot(2,2,3); 
ax2=gca; hold on;
m_proj('equidistant','lat',[21 37],'lon',[61,79]);
m_coast;
m_grid;
m_plot(data(:,1),data(:,2),'k.');
set(ax2,'FontSize',fs);

lon=data(:,1);
lat=data(:,2);

g1=13.0/3*lon-277;
g2=5*lon-312;
g3=-lon/9.7+40.11;
g4=4/10.7*lon+2.58;
g5=10/13.7*lon-25.46;
g6=-1.0*lon+100.

mg=repmat(0.5,1,3);
m_plot(lon,g1,'r-','color',mg,'linewidth',0.1);
m_plot(lon,g2,'r-','color',mg,'linewidth',0.1);
m_plot(lon,g3,'r-','color',mg,'linewidth',0.1);
m_plot(lon,g4,'r-','color',mg,'linewidth',0.1);
m_plot(lon,g5,'r-','color',mg,'linewidth',0.1);
m_plot(lon,g6,'r-','color',mg,'linewidth',0.1);

%	? all sites on the left of line through 66E and 70E in a


isocial=find(lat>g4 & lat<g2 & lon<=74 & lat>g6);
iflood=find(lat<g2 & lat>g1 & lat<g4&lat>g5);
itrade=find(lat<g1 & lat<g5 & lon<74 & lat < g6);
idry=find(lat<g4 & lat>g5 & lat<g1 & lon <=74);
ibaluch=find(lat<g6 & lat>g2);
ieast=find(lon>74);

indices={idry,isocial,iflood,itrade,ibaluch,ieast};
colors={'y','r','b','c','m','g'};

for i=1:length(colors)
  m_plot(data(indices{i},1),data(indices{i},2),'r.','color',colors{i});
end

figure(4);%subplot(2,2,4);
ax4=gca; hold on;
set(ax1,'XDir','reverse','Xlim',[-1000,8000],'FontSize',fs);

for i=1:length(colors)
  [sitetimes,sitenumbers,siteareas]=sitecountarea(data(indices{i},3:5));
  [sx,sy]=cl_stairs(sitetimes,siteareas);
  pss(i)=plot(sx,sy,'y-','LineWidth',2,'color',colors{i});
end

set(ax4,'XDir','reverse','Xlim',[-1000,8000],'FontSize',fs);
xlabel('Time (year BC)','color',mg);
ylabel('Area of coexistent sites');

set(gca,'Xlim',[700,5500],'Xcolor',mg,'YColor',mg,'color','none','Ylim',[-1 2000]);
for i=1:length(colors)
    xdata=get(pss(i),'XData');
    ydata=get(pss(i),'YData');
    set(pss(i),'XData',xdata-10+5*i)
    set(pss(i),'YData',ydata-5+2.5*i)
    
end




subplot(2,2,2);
n=length(data);
d=[data(:,4:-1:3),repmat(NaN,n,1),[1:n]'];
for i=1:length(colors)
  plot(d(indices{i},1:3),d(indices{i},[4,4,3]),'m-','color',colors{i});
end






cl_print('name','randall_sites_by_area','ext','pdf');

return
end


function [sitetimes,sitenumbers,siteareas]=sitecountarea(data)
% data is a nx3 matrix with columns start time, end time, area
  sitetimes=unique([data(:,1);data(:,2)]);
  sitenumbers=sitetimes+NaN;
  siteareas=sitenumbers;
  for i=1:length(sitetimes)-1
    sitenumbers(i)=sum(data(:,1)>=sitetimes(i+1) & data(:,2)<=sitetimes(i));
    siteareas(i)=sum((data(:,1)>=sitetimes(i+1) & data(:,2)<=sitetimes(i)).*data(:,3));
  end
  return
end







