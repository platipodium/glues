function clp_ivc_city_and_bricks

clear all

%% Read city information
citynames={'Tstart','Tend','Mehrgarh','Amri','Kotdiji','Harappa',...
    'Mohenjodaro','Lothal','Dholavira','Kalibangan','Ganweriwala',...
    'Rakhigarhi','Nagoor','TharoWaroDaro','Lakhueenjodaro','Nindowari'};
citydata=[
  [4300,3800,60,10, 10,  0,  0, 0, 0,  0, 0, 0, 0, 0, 0, 0];...
  [3800,3300,50,30, 50, 10,  0, 0, 0,  0, 0, 0, 0, 0, 0, 0];...
  [3300,2600,25,20, 40, 50, 20, 0, 0,  0, 0, 0, 0, 0, 0, 0];...
  [2600,2250, 0,20,100,120, 50,80,30,100,40,40,40,40,40,40];...
  [2250,1900, 0, 0,  0,150,150,50,90, 40,70,80,60,60,50,50];...
  [1900,1300, 0, 0,  0,  0,  0,50, 0, 30, 0,60,20,20,20,20]...
];


%% Read brick tchnology information
bricks=[[7000,1,0];
[5000,1,0];
[4000,7,0];
[3000,7,3];
[1800,5,6];
[1000,2,0]];
%[600,2,1]]

%% Create figure and plot
lg=repmat(0.7,1,3);
vlg=repmat(0.9,1,3);
dg=repmat(0.5,1,3);
fs=15;
xlim=[500,5400];
fn='Times';
sc=50;

time=mean(citydata(:,1:2),2);
area=sum(citydata(:,3:end),2);
clf reset; hold on;


pc=cl_patchbar(time,area,abs(citydata(:,2)-citydata(:,1))-30);
set(pc,'EdgeColor','none','FaceColor',lg);
ylim=get(gca,'Ylim');
ylim=[ylim(2)/1000.0 ylim(2)-0.01*ylim(2)];
set(gca,'XDir','reverse','xlim',xlim,'ylim',ylim,'color','none');

pb=cl_patchbar(bricks(:,1),bricks(:,2:3)*sc,70);
ipb1=find(pb(:,1)>0);
ipb2=find(pb(:,2)>0);
set(pb(ipb1,1),'EdgeColor',dg,'FaceColor','none','LineWidth',2);
set(pb(ipb2,2),'EdgeColor',dg,'FaceColor','none','Linestyle','--','LineWidth',2);

xlabel('Time (year BC)','FontSize',fs,'FontName',fn);
ylabel('Total urban area (ha)','FontSize',fs,'FontName',fn);

ax1=gca;
ax2=axes('position',get(ax1,'Position'),'box','on','color','none');
set(ax2,'Xlim',xlim,'XDir','reverse','YAxisLocation','right','XTick',[]);
set(ax2,'Ylim',ylim/sc);
ylabel('Number of sites with bricks','FontSize',fs,'FontName',fn);

axes(ax1);
r=load('randall_periods_sites_areas');
ps=plot(r.ptimestairs,r.snrstairs/10,'k-','LineWidth',2);


pl=legend(ax1,[pc(1),pb(4,1),pb(4,2),ps],'Urban area','Mud brick sites','Baked brick sites','Artifact sites');
set(pl,'location','Northwest');

p=findobj(gcf,'-property','Fontsize');
set(p,'FontSize',fs,'FontName',fn);

cl_print(gcf,'name','ivc_city_and_bricks','ext','pdf');


end