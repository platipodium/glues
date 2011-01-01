function clp_Turney2007(varargin)

arguments = {...
  {'latlim',[-inf inf]},...
  {'lonlim',[-inf inf]},...
  {'timelim',[-inf,inf]},...
  {'timeunit','BC'},...
  {'seacolor',0.7*ones(1,3)},...
  {'landcolor',.8*ones(1,3)},...
  {'transparency',0},...
  {'file','../../data/Turney2007_Brown_qsr_som.csv'},...
  {'nocolor',0},...
  {'ncol',19},...
  {'nogrid',0},...
  {'notitle',0},...
  {'flip',0},...
  {'showtime',1},...
  {'showstat',1},...
  {'showvalue',0},...
  {'noprint',0},...
  {'plotmode','new'},...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
end

fid=fopen(file,'r');
d=textscan(fid,'%s %s %f %f %s %s %d %d %d %d %d %d','CommentStyle','%',...
    'Delimiter',';');
fclose(fid);

if isinf(latlim(1)) latlim(1)=min(d{3}); end
if isinf(lonlim(1)) lonlim(1)=min(d{4}); end
if isinf(latlim(2)) latlim(2)=max(d{3}); end
if isinf(lonlim(2)) lonlim(2)=max(d{4}); end

if strcmp(timeunit,'BC')
  d{9}=d{9}-1950;
  d{10}=d{10}-1950;
  d{11}=d{11}-1950;
end

if strcmp(timeunit,'AD')
  d{9}=1950-d{9};
  d{10}=1950-d{10};
  d{11}=1950-d{11};
end

if isinf(timelim(1)) timelim(1)=min(d{11}); end
if isinf(timelim(2)) timelim(2)=max(d{11}); end

if strcmp(plotmode,'new')
  figure(1); clf reset;
  clp_basemap('lon',lonlim,'lat',latlim);
end

ival=find(d{11}>=timelim(1) & d{11}<=timelim(2) ...
    & d{3}>=latlim(1) & d{3} <= latlim(2) ...
    & d{4}>=lonlim(1) & d{4} <= lonlim(2));

nval=length(ival);
lat=d{3}(ival);
lon=d{4}(ival);
time=double(d{11}(ival));
hold on;
for i=1:nval;
  p(i)=m_plot(lon(i),lat(i),'ko');
end

timecol=ceil((time-timelim(1))/(timelim(2)-timelim(1))*ncol);
timecol(timecol==0)=1;
cmap=colormap(jet(ncol));
for i=1:nval;
    set(p(i),'MarkerFaceColor',cmap(timecol(i),:));
end

cb=colorbar;
yt=get(cb,'YTick');
yt=round(yt*(timelim(2)-timelim(1))+timelim(1));
ytl=num2str(yt');
set(cb,'YTickLabel',ytl);
title(cb,['Year ' timeunit]);

return;
end

