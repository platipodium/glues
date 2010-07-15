% Skript to produce the figures for the Umweltkrisen paper 

%% Figure 4 Timing of agriculture
% a) without climate disruptions
% b) with climate disruption

[d,b]=clp_nc_variable('var','farming','timelim',[-7500,-2500],'latlim',[30 60],'lonlim',[-15 45],...
    'nogrid',1,'threshold',0.5,'file','../../krisen_base.nc','flip',1,'ncol',10,'nocolor',1);
ax=get(gcf,'Children');
axes(ax(2));
ytl=get(gca,'YTickLabel');
[n1,n2]=size(ytl);
for i=1:n1 ytl(i,1)=' '; end
set(gca,'YTickLAbel',ytl);
c=get(gca,'Children');
set(c(4),'String','Year BC');
[d,n,e]=fileparts(b);
%plot_multi_format(gcf,fullfile(d,['krisen_fig4a_color']));


return
