% Skript to produce the figures for the Umweltkrisen paper 

%% Figure 1 trajectory without climate change

timelim=[-9500,-1500];
latlim=[45,50];
lonlim=[18,20];

file='../../krisen_nofluc.nc';

[p,b]=clp_nc_trajectory('var','population_density','timelim',timelim,'latlim',latlim,'lonlim',lonlim,...
    'nocolor',1,'file',file,'nosum',1,'nearest',1);
[f,b]=clp_nc_trajectory('var','farming','timelim',timelim,'latlim',latlim,'lonlim',lonlim,...
    'nocolor',1,'file',file,'nosum',1,'nearest',1);
[t,b]=clp_nc_trajectory('var','technology','timelim',timelim,'latlim',latlim,'lonlim',lonlim,...
    'nocolor',1,'file',file,'nosum',1,'nearest',1);
[e,b]=clp_nc_trajectory('var','economies','timelim',timelim,'latlim',latlim,'lonlim',lonlim,...
    'nocolor',1,'file',file,'nosum',1,'nearest',1);
%%

figure(1);
clf reset;
time=timelim(1):(timelim(2)-timelim(1))/(length(e)-1):timelim(2);
af=subplot(4,1,4);
set(af,'FontSize',15);
plot(time,f,'k-','Linewidth',4,'Color','k');
set(gca,'Color','none','box','off','YAxisLoc','right');
afpos=get(gca,'Position');
xlabel('Calendar year');
ae=subplot(4,1,3);
set(ae,'FontSize',15);
plot(time,e,'k-.','Linewidth',4,'Color',0.4*[1 1 1]);
set(gca,'Color','none','box','off','XTick',[],'YAxisLoc','left','YColor',0.4*[1 1 1]);
aepos=get(gca,'Position');
set(gca,'Position',aepos+[0 -0.1 0 +0.12]);
at=subplot(4,1,2);
set(at,'FontSize',15);
plot(time,t,'k:','Linewidth',4);
set(gca,'Color','none','box','off','XTick',[],'YAxisLoc','right');
atpos=get(at,'Position');
set(at,'Position',atpos+[0 -0.13 0 +0.18]);
ap=subplot(4,1,1);
set(ap,'FontSize',15);
plot(time,p,'k--','Linewidth',4,'Color',0.4*[1 1 1]);
set(gca,'Color','none','box','off','XTick',[],'YAxisLoc','left','YColor',0.4*[1 1 1]);
appos=get(gca,'Position');
set(gca,'Position',appos+[0 -0.2 0 0.25]);

return

%% Figure 4 Timing of agriculture
% a) without climate disruptions
% b) with climate disruption

timelim=[-7500,-2500];
latlim=[30 60];
lonlim=[-15 45];
threshold=0.5;

[data,b]=clp_nc_variable('var','farming','timelim',[-7500,-2500],'latlim',[30 60],'lonlim',[-15 45],...
    'nogrid',1,'threshold',threshold,'file','../../krisen_base.nc','flip',1,'ncol',10,...
    'nocolor',1,'seacolor','none','figoffset',1);
ax=get(gcf,'Children');
axes(ax(2));
ytl=get(gca,'YTickLabel');
[n1,n2]=size(ytl);
for i=1:n1 ytl(i,1)=' '; end
set(gca,'YTickLAbel',ytl);
c=get(gca,'Children');
set(c(4),'String','v. Chr.');

lakes=findobj('Tag','Lake');
set(lakes,'FaceColor','none');
lp=get(lakes,'Parent');
axes(lp{1});
m_coast('color','k','LineWidth',2)
whites=findobj('FaceColor','w');
set(whites,'FaceColor',[0.99 0.99 0.99]);

[rdata,rerror]=clp_site_timing('timelim',[-7500,-2500],'latlim',[30 60],'lonlim',[-15 45],'nocolor',1,'flip',0,'ncol',10,'radius',70,'data',data);

[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,['krisen_fig4a_gray']));

[data,b]=clp_nc_variable('var','farming','timelim',[-7500,-2500],'latlim',[30 60],'lonlim',[-15 45],...
    'nogrid',1,'threshold',threshold,'file','../../krisen_nofluc.nc','flip',1,'ncol',10,...
    'nocolor',1,'seacolor','none','figoffset',1);
ax=get(gcf,'Children');
axes(ax(2));
ytl=get(gca,'YTickLabel');
[n1,n2]=size(ytl);
for i=1:n1 ytl(i,1)=' '; end
set(gca,'YTickLAbel',ytl);
c=get(gca,'Children');
set(c(4),'String','v. Chr.');

lakes=findobj('Tag','Lake');
set(lakes,'FaceColor','none');
lp=get(lakes,'Parent');
axes(lp{1});
m_coast('color','k','LineWidth',2)

[data,rerror]=clp_site_timing('timelim',[-7500,-2500],'latlim',[30 60],'lonlim',[-15 45],'nocolor',1,'flip',0,'ncol',10,'radius',70,'data',data);

whites=findobj('FaceColor','w');
set(whites,'FaceColor',[0.99 0.99 0.99]);

[d,n,e]=fileparts(b);
plot_multi_format(gcf,fullfile(d,['krisen_fig4b_gray']));




return
