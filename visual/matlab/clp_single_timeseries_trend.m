function trend=clp_single_timeseries_trend(i,varargin)

cl_register_function();

arguments = {...
  {'latlim',[-90 90]},...
  {'lonlim',[-180 180]},...
  {'timelim',[0,6]},...
  {'fontsize',16},...
  {'no_title',0},...
  {'no_xticks',0},...
  {'no_legend',0}
};

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

% Default values
if ~exist('i','var') i=1; end

[dirs,files]=get_files;
dirs.total='~/projects/glues/m/holocene/redfit/data/eleven';

load('holodata.mat');

if isstr(i)
    file=i;
else
    file=fullfile(dirs.total,holodata.Datafile{i});
end

fid=fopen(file,'r');
if (fid<0) return; end

i=0; t=[];v= [];
while ~feof(fid)
  l=fgetl(fid);
  i=i+1;
  num=str2num(l);
  t(i)=num(1); v(i)=num(2);
end
fclose(fid);
ts.fullname=file;
ts.length=i;
ts.time=t;
ts.value=v;

ifile=i;
[dummy, sitename, dummy1]=fileparts(ts.fullname);

it=find(ts.time>=timelim(1) & t<=timelim(2));
t=ts.time(it);
v=ts.value(it);
ts.sitename=sitename;

plot(t,v,'k.');
set(gca,'XLim',timelim,'XDir','reverse');
if ~no_title title(sprintf('Time series %s',strrep(sitename,'_','\_'))); end
hold on;
m50=movavg(t,v,0.1);
m2000=movavg(t,v,2.0);
vsize=size(v);
%if vsize(2)>vsize(1) v=v'; end
plot(t,m50,'r-');
plot(t,m2000,'b-');
if ~no_legend legend('Raw data','100-yr mov.avg.','2-kyr mov.avg.',0); end;

if no_xticks 
  %set(gca,'XTicklabel',{'Present day',1,2,3,4,5,'6 kBP'});
  set(gca,'XTicklabel',[]);
end

fit=polyfit(t,v,1);
%plot(t,t.*fit(1)+fit(2),'k:');
fit(3)=std(v-t.*fit(1)-fit(2));
trend=[fit(1)*(timelim(2)-timelim(1)) fit(3)]

return;
