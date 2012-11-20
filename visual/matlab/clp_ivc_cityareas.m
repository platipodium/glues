function clp_ivc_cityareas


%% Read city area information
d='/Users/lemmen/projects/glues/tex/2012/indusreview/data';
file1=fullfile(d,'IVC_area.csv');
fid=fopen(file1,'r');

D=cell2mat(textscan(fid,'%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d,','Delimiter',',','Headerlines',2));
i=1;
time(i)=D(1);
n=length(D)-1;

area(i,:)=D(2:end);

while ~feof(fid)
  i=i+1;
  D=cell2mat(textscan(fid,'%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d,','Delimiter',',','Headerlines',0));
  if isempty(D) break; end
  time(i)=D(1);
  area(i,:)=D(2:end);
end
fclose(fid);


time=double(time);
area=double(area);


%% Create figure and plot
lg=repmat(0.7,1,3);
vlg=repmat(0.9,1,3);
dg=repmat(0.5,1,3);
fs=15;
xlim=[500,5400];
fn='Times';

clf reset; hold on;
pc=cl_patchbar(time,area);


end


function phdl=cl_patchbar(xdata,ydata,xwidth)

if ~exist('xwidth','var') xwidth=0.9; end
nx=length(xdata);

xdiff=abs(xdata(2:end)-xdata(1:end-1));
xmin=min(xdiff);
phdl=zeros(size(ydata));
lhdl=phdl;
cmap=gray(size(ydata,2));
if ~ishold hold on; end

pattern={
  {'single',30,5},...
  {'cross',30,5},...
  {'single',60,5},...
  {'cross',60,5},...
  {'single',120,5},...
  {'cross',90,5},...
  {'single',150,5},...
  {'cross',45,5},...
  {'single',30,10},...
  {'cross',45,10},...
  {'single',60,10},...
  {'cross',90,10},...
  {'single',120,10},...
  {'cross',60,10},...
  {'single',150,10},...
  {'cross',30,10},...
};
np=length(pattern);

for i=1:nx
  xi=xdata(i)+0.5*xmin.*[-1 1]*xwidth;
  for j=1:size(ydata,2)
    if ydata(i,j)==0 continue; end
    if j<2 yi=[0 ydata(i,1)];
    else yi=[sum(ydata(i,1:j-1)) sum(ydata(i,1:j))];
    end
    xline=[xi(1) xi(1) xi(2) xi(2) xi(1)];
    yline=[yi(1) yi(2) yi(2) yi(1) yi(1)];
    phdl(i,j)=patch(xline,yline,'k','facecolor','none','edgecolor',cmap(j,:));
    ip=mod(j,np);
    if ip==0 ip=np; end
    lhdl(i,j)=cl_hatch(xline,yline,pattern{ip}{1},pattern{ip}{2},pattern{ip}{3},'color',cmap(j,:));
  end
end
  

end


function bla

set(pc,'EdgeColor','none','FaceColor',lg);
ylim=get(gca,'Ylim');
ylim=[ylim(2)/1000.0 ylim(2)-0.01*ylim(2)];
set(gca,'XDir','reverse','xlim',xlim,'ylim',ylim);
pb=bar(bricks(:,1),bricks(:,2:3)*sc,0.2,'stacked','LineWidth',2);
set(pb(1),'EdgeColor',dg,'FaceColor','none');
set(pb(2),'EdgeColor',dg,'FaceColor','none','Linestyle','--');

xlabel('Time (Year BC)','FontSize',fs,'FontName',fn);
ylabel('Total urban area (ha)','FontSize',fs,'FontName',fn);


ax1=gca;
ax2=axes('position',get(ax1,'Position'),'box','off','color','none');
set(ax2,'Xlim',xlim,'XDir','reverse','YAxisLocation','right','XTick',[]);
set(ax2,'Ylim',ylim/sc);
ylabel('Number of sites with bricks','FontSize',fs,'FontName',fn);

pl=legend(ax1,[pc,pb(1),pb(2)],'Urban area','Mud brick sites','Baked brick sites');
set(pl,'location','Northwest');

p=findobj(gcf,'-property','Fontsize');
set(p,'FontSize',fs,'FontName',fn);

cl_print(gcf,'name','ivc_city_and_bricks','ext','pdf');



end