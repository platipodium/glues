function clp_funnelbeaker

cl_register_function;

file='neolithicsites.mat';

load(file);
itrb=strmatch('TRB',Forenbaher.Period);

figure(1); clf reset;
lat=Forenbaher.Latitude(itrb);
lon=Forenbaher.Long(itrb);
period=Forenbaher.Period(itrb);
country=Forenbaher.Country(itrb);
age=Forenbaher.Median_age(itrb);

latlim=[min(lat)-0.2 max(lat)+0.5];
lonlim=[min(lon)-0.2 max(lon)+0.2];
m_proj('equidistant','lat',latlim,'lon',lonlim);
m_coast;
m_grid;
hold on;

iw=strmatch('TRB_West',period);
in=strmatch('TRB_North',period);
ie=strmatch('TRB_East',period);
pw=m_plot(lon(iw),lat(iw),'bo');
pe=m_plot(lon(ie),lat(ie),'mo');
pn=m_plot(lon(in),lat(in),'ro');
ht=m_text(lon+0.1,lat,num2str(age'),'FontSize',16);
legend([pw pe pn],'West','East','North');

%% 
figure(2);
ncol=10;
timelim=[-5000 -3000];
[data,bname]=clp_nc_variable('file','../../eurolbk_events.nc','var','farming',...
    'threshold',0.5,'timelim',timelim,'latlim',latlim,'lonlim',lonlim,...
    'showstat',0,'showtime',0,'ncol',ncol,'marble',2,'transparency',1);

c=get(gcf,'Children');
cb=c(strmatch('colorbar',get(c,'tag')));


yt=get(cb,'YTick');
yr=timelim(2)-timelim(1);
ytl=scale_precision((yt-min(yt))*yr/(max(yt)-min(yt))+timelim(1),3)';
set(cb,'YTickLabel',num2str(ytl));


%%
time=1950-age;
c=get(gcf,'Children');
axes(c(strmatch('m_grid',get(c,'tag'))));

resvar=round(((time-timelim(1)))./(timelim(2)-timelim(1))*(ncol-1))+1;
cmap=jet(ncol);

for i=1:length(itrb)
  p(i)=m_plot(lon(i),lat(i),'ko','MarkerFaceColor',cmap(resvar(i),:),'tag',period{i},'Userdata',time(i));
end

plot_multi_format(gcf,[bname '_TRB']);

return; 
end
