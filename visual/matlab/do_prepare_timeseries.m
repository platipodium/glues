function do_prepare_timeseries
% DO_PREPARE_TIMESERIES

% requires 
% * get_files.m
% * remove_trend.m
% * remove_singularevents.m

cl_register_function();

[d,f]=get_files;
d.proxies=fullfile(d.proxies,'redfit/data');
d.raw=fullfile(d.proxies,'input/total');

f=dir(d.raw);
clear files
j=0;
for i=1:length(f) 
  file=fullfile(d.raw,f(i).name);
  [p,n,e,v]=fileparts(file);
  if strcmp(e,'.dat')
     j=j+1;
     files{j}=f(i).name;
  end
end

n=j;
% Select time series here, if not continue with all
%n=1;

if (1==0)

% 0.task : select appropriate interval
d.eleven=fullfile(d.proxies,'eleven');
if ~exist(d.eleven,'file')
  mkdir(d.eleven);
end
for i=1:n
  data=load(fullfile(d.raw,files{i}));
  valid=find(data(:,1)>=0 & data(:,1)<=11.0);
  nvalid=length(valid)
  if nvalid<2
      warning('Datafile %s does not contain enough data in 0-11',files{i});
      continue;
  end
  data=data(valid,:);
  save(fullfile(d.eleven,files{i}),'-ascii','data');
end
end


% 1. task: detrending
if (1==0)
d.detrended=fullfile(d.proxies,'detrended');
if ~exist(d.detrended,'file')
  mkdir(d.detrended);
end
for i=1:n
  data=load(fullfile(d.eleven,files{i}));
  vdetr=remove_trend(data(:,1),data(:,2),'polyfit');
  data=[data(:,1),vdetr];
  save(fullfile(d.detrended,files{i}),'-ascii','data');
end
end

% 2. task: normalising
if (2==0)
d.normalised=fullfile(d.proxies,'normalised');
if ~exist(d.normalised,'file')
  mkdir(d.normalised);
end
for i=1:n
  data=load(fullfile(d.detrended,files{i}));
  v=data(:,2);
  vstd=(v-mean(v))./std(v);
  data=[data(:,1),vstd];  
  save(fullfile(d.normalised,files{i}),'-ascii','data');
end

else d.normalised=fullfile(d.proxies,'normalised');

end


% 3. task: removal of singular events 
if (3==3)
d.deevented=fullfile(d.proxies,'deevented');
if ~exist(d.deevented,'file')
  mkdir(d.deevented);
end
for i=1:n
  data=load(fullfile(d.normalised,files{i}));
  vse=remove_singularevents(data(:,1),data(:,2));
  
  if (1==1)
      plot(data(:,1),vse,'r-');
      hold on
      plot(data(:,1),data(:,2),'k-');
      title(files{i});
      hold off
      
      ;
  end
  data=[data(:,1),vse];  
  save(fullfile(d.deevented,files{i}),'-ascii','data');
end
end

% 4. task: disturb chronologies
if (0==4)
    delta=0.12;
d.disturbed=fullfile(d.proxies,['d' num2str(delta)]);
if ~exist(d.disturbed,'file')
  mkdir(d.disturbed);
end

for i=1:n
 
    data=load(fullfile(d.normalised,files{i}));
    tdist=disturb_chronology(data(:,1),8,delta);
    data=[tdist',data(:,2)];  
    
    save(fullfile(d.disturbed,files{i}),'-ascii','data');
end
end
