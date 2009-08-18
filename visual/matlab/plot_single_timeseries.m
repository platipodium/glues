function plot_single_timeseries(varargin)

cl_register_function();

% Default values
fs=16; no_title=0; no_xticks=0; i=1; no_legend=0;

if (nargin>0)
  i=varargin{1};
  for iargin=2:nargin
    if strcmp(varargin{iargin},'FontSize') fs=varargin{iargin+1}; iargin=iargin+1; end;
    if strcmp(varargin{iargin},'NoTitle') no_title=1; end;
    if strcmp(varargin{iargin},'NoXTicks') no_xticks=1; end;
    if strcmp(varargin{iargin},'NoLegend') no_legend=1; end;
  end;
end; 

  

[dirs,files]=get_files;
dirs.total='~/projects/glues/m/holocene/redfit/data/eleven';

load('holodata.mat');
%file=fullfile(dirs.total,strrep(holodata.Datafile{i},'.dat','_tot.dat'));

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

thresh=1.5.^[-1,0,1,2];
thresh=repmat(thresh,2,1);

lstyles=['k-.';'r--';'b-.';'b--'];
mstyles=['ko';'ro';'bo';'bo'];

ifile=i;
[dummy, sitename, dummy1, dummy2]=fileparts(ts.fullname);
t=ts.time;
v=ts.value;
ts.sitename=sitename;
td.mean=mean(t(2:end)-t(1:end-1));
td.std=std(t(2:end)-t(1:end-1));
tmima=[min(t),max(t)];
if any(t>=5.5) ts.lowspan=max(t)-min(t(t>=5.5)); else tslowspan=inf; end
if any(t<=6.0) ts.uppspan=max(t(t<=6.0))-min(t); else ts.uppspan=inf; end

plot(t,v,'k.');
set(gca,'XLim',[0,12]);
if ~no_title title(sprintf('Time series %s',strrep(sitename,'_','\_'))); end
hold on;
m50=movavg(t,v,0.05);
m2000=movavg(t,v,2.0);
indlower=min(find(t>=5.5));
indupper=max(find(t<=6.0));
vsize=size(v);
if vsize(2)>vsize(1) v=v'; end
vdetrend=v-m2000;
vinterp=movavg(t,vdetrend,0.05);
plot(t,m50,'r-');
plot(t,m2000,'b-');
if ~no_legend legend('Raw data','50-yr mov.avg.','2-kyr mov.avg.',0); end;

if ~no_xticks set(gca,'XTicklabel',{'Present',2,4,6,8,10,'kyr BP'});
else set(gca,'XTicklabel',[]);
end


return;
