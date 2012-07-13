function data=clp_single_timeseries_trend(timeseries,varargin)

cl_register_function;

arguments = {...
  {'latlim',[-90 90]},...
  {'lonlim',[-180 180]},...
  {'timelim',[0,6]},...
  {'fontsize',16},...
  {'no_title',0},...
  {'no_xticks',0},...
  {'no_legend',0},...
  {'highpass',0.1},...
  {'lowpass',2.0},...
  {'file','holodata.mat'},...
};

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end

dirs.total='~/projects/glues/m/holocene/redfit/data/eleven';
dirs.total='~/projects/glues/tex/2012/jarcsclim/data';

% Default values
if ~exist('timeseries','var') timeseries=1; end

if ~exist(file,'file')
    warning('File %s does not exist',file);
   return
end

load(file);
if ~exist('holodata','var') holodata=evinfo; end

if isstr(timeseries)
    file=timeseries;
else
    file=fullfile(dirs.total,holodata.Datafile{timeseries});
end

fid=fopen(file,'r');
if (fid<0) 
    warning('File %s not found',file);
    data=NaN;
    return; 
end

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

[ut,m50]=movavg(t,v,highpass);
[ut,m2000]=movavg(t,v,lowpass);
vsize=size(t);
%if vsize(2)>vsize(1) v=v'; end
plot(ut,m50,'r-','LineWidth',3);
hold on
plot(t,v,'kd','MarkerSize',8,'MarkerFaceColor','k');
set(gca,'XLim',timelim,'XDir','reverse');
if ~no_title title(sprintf('Time series %s',strrep(sitename,'_','\_'))); end
hold on;
%plot(t,m2000,'b-');
%if ~no_legend legend('Raw data','100-yr mov.avg.','6-kyr mov.avg.',0); end;
if ~no_legend legend('Raw data','100-yr mov.avg.',0); end;

if no_xticks 
  %set(gca,'XTicklabel',{'Present day',1,2,3,4,5,'6 kBP'});
  set(gca,'XTicklabel',[]);
end

fit=polyfit(t,v,1);
%plot(t,t.*fit(1)+fit(2),'k:');
fit(3)=std(v-t.*fit(1)-fit(2));
data.trend=[fit(1)*(timelim(1)-timelim(2)) fit(3)]
plot(t,t.*fit(1)+fit(2),'b-','LineWidth',5);

data.ts=ts;
data.m50=m50;
data.m2000=m2000;
data.ut=ut;

if ~isstruct(data) 
    error('Data not found');;
end


return;
