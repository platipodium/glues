% Skript to produce the figures for the Umweltkrisen paper 

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
