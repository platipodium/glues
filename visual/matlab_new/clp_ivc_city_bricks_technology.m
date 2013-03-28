function clp_ivc_city_bricks_technology

clear all

%% Read brick tchnology information
bricks=cl_read_brick_technologies('/Users/lemmen/projects/glues/tex/2013/indusreview/brick_locations.tsv')

%% Create figure and plot
g6=repmat(0.6,1,3);
g85=repmat(0.85,1,3);
g8=repmat(0.8,1,3);
g7=repmat(0.7,1,3);
g4=repmat(0.4,1,3);
g5=repmat(0.5,1,3);

fs=15;
xlim=[600,7300];
fn='Times';
sc=50;

xgrid=[3200,2600,1900,1300];

clf reset; hold on;
fpos=get(gcf,'Position');
if fpos(3)>fpos(4) 
  set(gcf,'Position',get(gcf,'Position') .* [1 1 1 3.5]);
end


%% First plot with technologies
file='technology.csv';
sep='!';
fid=fopen(file,'r');
d=textscan(fid,'%s%f%f%f%f%s%s','Delimiter',sep,'HeaderLines',1);
fclose(fid);

tech=d{1};t0=d{2};t00=abs(t0);d0=d{3};t1=d{4};t11=abs(t1);d1=d{5};
n=length(d0);
bw=0.4; % bar width
al=500;

% Sort by starting time
[ts,is]=sort(t0);t0=t0(is);t00=t00(is);t1=t1(is);t11=t11(is);d1=d1(is);tech=tech(is);
cdefinite=[.9 .9 .9];
cpossible=[.95 .95 .95];
t0=abs(t0);
t1=abs(t1);

%tech1(1)={' '}; %VB
%% Three Bars for Harappan age
ylim=[0.2 n+2.0];
ybw=0.40;
yc=ylim(2)-.10-ybw;
subplot(3,1,1);
ax0=gca;
chrono(1)=akp_bar(2600,yc,3200-2600,ybw,g7,'k',0);
% text(-3050,yc*.95,'E','fontsize',13 );
pte=text(2950,yc+ybw/3,'early','fontsize',9 ,'HorizontalAlignment','center','VerticalAlignment','middle');
chrono(2)=akp_bar(1900,yc,2600-1900,ybw,g85,'k',0);
ptm=text(2350,yc+ybw/3,'mature','fontsize',9 );
chrono(3)=akp_bar(1300,yc,1900-1300,ybw,g7,'k',0);
ptl=text(1650,yc+ybw/3,'late','fontsize',9);
set(chrono,'EdgeColor','none');
set(gca,'Xlim',xlim,'XDir','reverse','ylim',ylim,'color','w');
set(gca,'XAxisLocation','top');
xlabel('Time (year BC)','FontSize',fs,'FontName',fn);
%pg=clp_xgrid(gca,[5000,4300,3800,3200,2600,1900,1300],'k--','color',mg);


for i=1:n
  if isinf(t1(i))
    hdl(i,2)=akp_bar(t0(i),n+1-i,xlim(1)+al+300-t0(i),bw,g85,'k',-al);
  else
    hdl(i,2)=akp_bar(t0(i),n+1-i,t1(i)-t0(i),bw,g85,'k',0);
  end
  
  % Plot right-hand whisler
  if (d1(i)>0)
    %hdl(i,3)=akp_whisker(t1(i),n+1-i,2*d1(i),0.5*bw,'k');
  end

  if (d0(i)>0)
    %hdl(i,1)=akp_bar(t0(i)-d0(1),n+1-i,2*d0(i),bw,cpossible,'k',0);
    %hdl(i,2)=akp_whisker(t0(i),n+1-i,2*d0(i),0.5*bw,'k');
  end

  if isinf(t1(i))
    hdl_t(i)=text((t0(i)-min([t1(i) xlim(1)]))/2,n+1-i,tech(i),'HorizontalAlignment','center','FontName','Times');     
  elseif 200*length(tech{i})< min([xlim(1) t0(i)])-t1(i)
    hdl_t(i)=text((t0(i)-min([t1(i) xlim(1)]))/2,n+1-i,tech(i),'HorizontalAlignment','center','FontName','Times');
  else 
    hdl_t(i)=text(t0(i)+3*d0(i),n+1-i,tech(i),'HorizontalAlignment','right','FontName','Times');
  end    
  tech1(n+2-i)=tech(i);
  set(hdl_t,'VerticalAlignment','middle');  
end
%tech1(n+2)={' '};%VB
text(xlim(1)+180,7.5,'Continued','fontsize',18 ,'Rotation',90,'HorizontalAlignment','center','color',[1 1 1]*.6,'FontName','Times');
set(gca,'YTick',[]); 
set(gca,'Box','on','YColor','k','Color','none');
hdl_bar=findobj(hdl,'-property','FaceAlpha');
set(hdl_bar,'FaceAlpha',1);
hold on;
pg1=clp_xgrid(gca,xgrid,'k-','color',g5);


%% Second plot with urban area and site #
citydata=load('/Users/lemmen/projects/glues/tex/2013/indusreview/urbanarea_summed.tsv');
time=mean(citydata(:,1:2),2);
area=citydata(:,3);

sc=2;
subplot(3,1,2);
pc=cl_patchbar(time,area,abs(citydata(:,2)-citydata(:,1))-2);
pc=pc(pc>0);
set(pc,'EdgeColor','none','FaceColor',g7);
ylim=get(gca,'Ylim');
ylim=[ylim(2)/1000.0 ylim(2)-0.01*ylim(2)];
set(gca,'XDir','reverse','xlim',xlim,'ylim',ylim,'color','none','XTIckLabel',[],'XAxisLocation','top');
ylabel('Total urban area (ha)','FontSize',fs,'FontName',fn);

ax1=gca;
ax2=axes('position',get(ax1,'Position'),'box','on','color','none');
set(ax2,'Xlim',xlim,'XDir','reverse','YAxisLocation','right','XTickLabel',[]);
set(ax2,'Ylim',ylim*sc);
ylabel('Number of artifact sites','FontSize',fs,'FontName',fn);
axes(ax1);
%r=load('randall_periods_sites_areas');
%ps=plot(r.ptimestairs,r.snrstairs/sc,'k-','LineWidth',2);


[sitetimes,sitenumbers]=clp_randall_sites('noprint');
%for i=2:length(sitetimes)
%  sitenumbers(i)=sum(r(:,3)>=sitetimes(i) & r(:,4)<sitetimes(i-1));
%end
[sx,sy]=cl_stairs(sitetimes,sitenumbers/sc);
ps=plot(sx,sy,'k-','LineWidth',3,'color',g5);
pg=clp_xgrid(gca,xgrid,'k-','color',g5);


pl(1)=legend(ax1,[pc(1),ps],'Urban area','Artifact sites');
set(pl(1),'location','Northwest');

subplot(3,1,3);
ax3=gca;
hold on;

[xb,sb]=cl_stairs(bricks(:,1),bricks(:,2)+bricks(:,3))
pb(1)=clp_area(xb,sb,'r','facecolor',g5,'edgecolor','none')
[xb,sb]=cl_stairs(bricks(:,1),bricks(:,3))
pb(2)=clp_area(xb,sb,'r','facecolor',g7,'edgecolor','none')
pg=clp_xgrid(gca,xgrid,'k-','color',g5);

pl2=legend(ax3,pb,'Mud and baked','Baked fraction');

% pb=cl_patchbar(bricks(:,1),bricks(:,3:-1:2),70);
% ipb1=find(pb(:,1)>0);
% ipb2=find(pb(:,2)>0);
% set(pb(ipb1,1),'EdgeColor','none','FaceColor',lg,'LineWidth',2);
% set(pb(ipb2,2),'EdgeColor','none','FaceColor',dg,'Linestyle','--','LineWidth',2);
% pbs=stairs(bricks(:,1),bricks(:,2)+bricks(:,3),'k-','LineWidth',2);
% pl2=legend(ax3,[pbs,pb(4,2),pb(4,1)],'all','only mud','also baked');

set(gca,'XDir','reverse','xlim',xlim,'color','none','ylim',[-0.5 20]);
xlabel('Time (year BC)','FontSize',fs,'FontName',fn);
ylabel('Number of brick sites','FontSize',fs,'FontName',fn);

set(pl2,'location','Northwest','color','none');
p=findobj(gcf,'-property','Fontsize');
set(p,'FontSize',fs,'FontName',fn);
set([pte,ptm,ptl],'FontSize',9);


set(ax0,'Position',get(ax0,'Position')+[0 -0.07 0 0.07]);
set([ax1,ax2],'Position',get(ax1,'Position')+[0 -0.07 0 0.07]);
set(ax3,'Position',get(ax3,'Position')+[0 -0.05 0 0.05],'box','on');


cl_print(gcf,'name','ivc_city_bricks_technology','ext','pdf');


end


function [hdl]=clp_area(varargin)
  offset=0;
  if ishandle(varargin{1}) axes(varargin{1}); offset=1; end
  x=varargin{offset+1};
  y=varargin{offset+2};
  if size(x,1)==1 x=x'; end
  if size(y,1)==1 y=y'; end
  
  n=length(x);
  patchx=[x;flipud(x)];
  patchy=[y;zeros(n,1)];
  
  hdl=patch(patchx,patchy,varargin{offset+3:end})

  return;
end


function hdl=akp_bar(x,y,xwidth,ywidth,facecolor,edgecolor,xarrowlength)

  xpos=x+[0,xwidth,xwidth+xarrowlength,xwidth,0];
  ypos=y+[-ywidth,-ywidth,0,ywidth,ywidth];
  hdl=patch(xpos,ypos,'k','FaceColor',facecolor,'EdgeColor','none');
  return;
end

function hdl=akp_whisker(x,y,xwidth,ywidth,color)

  xpos=x+[-xwidth -xwidth -xwidth +xwidth +xwidth +xwidth];
  ypos=y+[-ywidth +ywidth 0 0 +ywidth -ywidth];
  hdl=line(xpos,ypos,'Color',[1 1 1]*.8);
  return;
end







