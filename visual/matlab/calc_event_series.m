function calc_event_series

cl_register_function();

[d,f]=get_files;
d.total=fullfile(d.proxies,'redfit/data/input/total');
v=cl_get_version;

proxyfile='holodata.mat';

if ~exist(proxyfile,'file')
  error('Required file holodata.mat does not exist');
end

load('holodata.mat');
valid=find(holodata.No_sort<500);
nvalid=length(valid);

for ifile=1:nvalid
  file=fullfile(d.total,strrep(holodata.Datafile{valid(ifile)},'.dat','_tot.dat'));
  if ~exist(file,'file') 
    file=fullfile(d.total,holodata.Datafile{valid(ifile)});
  end
  if ~exist(file,'file') 
    warning('Trying to read %s',file);
    error('Data file does not exist'); 
  end

  try
    tv=load(file,'-ascii');
    t=tv(:,1);
    v=tv(:,2);
  catch 
  
    fid=fopen(file,'r');
    i=0; t=[];v= [];
    while ~feof(fid)
      l=fgetl(fid);
      num=str2num(l);
      if length(num)<2 continue; end
      i=i+1;
      t(i)=num(1); v(i)=num(2);
    end
    fclose(fid);
  end
  
  ts(ifile).fullname=file;
  ts(ifile).length=length(t);
  ts(ifile).time=t;
  ts(ifile).value=v;
  ts(ifile).lat=holodata.Latitude(ifile);
  ts(ifile).lon=holodata.Longitude(ifile);
  ts(ifile).no_sort=holodata.No_sort(ifile);
  [dummy, ts(ifile).sitename, dummy1, dummy2]=fileparts(ts(ifile).fullname);
end

save('-v6','ts','ts');

thresh=1.5.^[-1,0,1,2];
thresh=repmat(thresh,2,1);

% Event counting in nfile x nthreshold x nperiod array
nevents=zeros(nvalid,4,2);

for ifile=1:nvalid

  t=ts(ifile).time;
  v=ts(ifile).value;
  td.mean=mean(t(2:end)-t(1:end-1));
  td.std=std(t(2:end)-t(1:end-1));
  tmima=[min(t),max(t)];

  m50=movavg(t,v,0.05);
  m2000=movavg(t,v,2.0);
  vdetrend=m50-m2000;
  vstd=(vdetrend-mean(vdetrend))/std(vdetrend);

  for i=1:4
    ind=find(vstd>thresh(1,i));
    negind=find(vstd<-thresh(1,i));
    nind=length(ind);
    nnegind=length(negind);
    neginddiff=negind(2:end)-negind(1:end-1);
    inddiff=ind(2:end)-ind(1:end-1);
    pos2neg=find(vstd(1:end-1)>0 & vstd(2:end)<0);
    neg2pos=find(vstd(1:end-1)<0 & vstd(2:end)>0);
    j=1; n=0; vmax=0; events=[]; indmax=0;
  
 
  while j<=nind;
    if vstd(ind(j))> vmax
           vmax=vstd(ind(j));
           indmax=ind(j); 
     end
     while(j<nind & inddiff(j)==1) 
        if vstd(ind(j))> vmax
           vmax=vstd(ind(j));
           indmax=ind(j); 
        end
        %fprintf('%d %f %d\n',j,vmax,inddiff(j));
        j=j+1;
    end
    if (j<nind & find(pos2neg>=ind(j) & pos2neg<ind(j+1)) )
      if vstd(ind(j))> vmax
           vmax=vstd(ind(j));
           indmax=ind(j); 
       end
       n=n+1;
        events(n,2)=vmax;
        events(n,1)=indmax;
        vmax=0;
        indmax=0;
    elseif j>=nind 
      if vstd(nind)> vmax
           vmax=vstd(nind);
           indmax=nind; 
      end
       n=n+1;
        events(n,2)=vmax;
        events(n,1)=indmax;
        vmax=0;
        indmax=0;
    end
 %  fprintf('%d %d %f %f\n',j,n,t(ind(j)),vmax);
   j=j+1;
  end
   j=1; vmin=0; indmin=0;
   while j<=nnegind;
     if vstd(negind(j))< vmin
           vmin=vstd(negind(j));
           indmin=negind(j); 
     end
     while(j<nnegind & neginddiff(j)==1) 
       if vstd(negind(j))< vmin
           vmin=vstd(negind(j));
           indmin=negind(j); 
       end
       j=j+1;
    end
    if (j<nnegind & find(neg2pos>=negind(j) & neg2pos<negind(j+1)) )
       if vstd(negind(j))< vmin
           vmin=vstd(negind(j));
           indmin=negind(j); 
       end
     n=n+1;
        events(n,2)=vmin;
        events(n,1)=indmin;
        vmin=0;
        indmin=0;
    elseif j>=nnegind 
         if vstd(nnegind)< vmin
           vmin=vstd(nnegind);
           indmin=nnegind; 
       end
     n=n+1;
        events(n,2)=vmin;
        events(n,1)=indmin;
        vmin=0;
        indmin=0;
    end
   % fprintf('%d %d %f %f\n',j,n,t(negind(j)),vmax);
   j=j+1;
  end
  
   if n>=1
     events=sortrows(events,1); 
     ts(ifile).events=events;
   else
       ts(ifile).events=[NaN, NaN];
   end
  end
end

v=cl_get_version;
fid=fopen('event_series.tsv','w');
fprintf(fid,'# Proxy-id lon lat nevents min(t) max(t) event1 event2 ..\n');
fprintf(fid,'# %s, created %s by program %s (%s)\n',v.copy,v.time,v.file, v.version);
for ifile=1:nvalid
  t=ts(ifile).time;
  nevents=size(ts(ifile).events,1);
  if isnan(ts(ifile).events(1)) continue; end
  fprintf(fid,'%04d %7.2f %6.2f %3d ',ts(ifile).no_sort,ts(ifile).lon,ts(ifile).lat,nevents);
  fprintf(fid,'%7.3f %7.3f',min(t),max(t));
  fprintf(fid,' %7.3f',t(ts(ifile).events(1:nevents,1)));
  fprintf(fid,'\n');
end
fclose(fid);

save('-v6','event_series.mat','ts');

return
end
