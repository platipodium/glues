function cl_eventdensity(varargin)

arguments = {...
  {'nreg',685},... 
  {'np',124},... 
  {'flucperiod',175},...
  {'timelim',[0 12]},... % in ka BP
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  lv=length(a.value{i});
  if (lv>1 & iscell(a.value{i}))
    for j=1:lv
      eval( [a.name{i} '{' num2str(j) '} = ''' char(clp_valuestring(a.value{i}(j))) ''';']);         
    end
  else
    eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
  end
end

evseriesfile=sprintf('EventSeries_%03d.tsv',np);
evregionfile=sprintf('EventInReg_%03d_%03d.tsv',np,nreg);
evradiusfile=sprintf('EventInRad_%03d_%03d.tsv',np,nreg);

eventinreg=load(evregionfile,'-ascii');
eventinrad=load(evradiusfile,'-ascii');
evseries=load(evseriesfile,'-ascii');

wmax=max(max(eventinrad));
emax=size(evseries,2)-2;

for ir=1:nreg
  time=min(timelim):0.01:max(timelim);
  wtime=zeros(size(time));
  value=zeros(size(time));
  figure(1); clf;
  set(gca,'Xlim',timelim); hold on;
  p=eventinreg(ir,:);
  p=p(p>0);
  np=length(p);
  wp=wmax+1-squeeze(eventinrad(ir,1:np));
  for ip=1:np
    plot(evseries(p(ip),1:emax),wp(ip),'kd');
    it=find(time>=evseries(p(ip),emax+1) & time<=evseries(p(ip),emax+2));
    wtime(it)=wtime(it)+1;
  end
  plot(time,wtime,'k-');
  
  valid=find(wtime>0);
  
  for ip=1:np
    e=find(evseries(p(ip),1:emax)>0);
    e=e(find(e>=evseries(p(ip),emax+1)+flucperiod/500.0 & e<=evseries(p(ip),emax+2)-flucperiod/500.0));
    ne=length(e)
    for ie=1:ne
      ev=evseries(p(ip),e(ie));
      %[mt,it]=min(abs(ev-time));
      %evalue=time;
      %evalue(it)=wp(ip)/wtime(it);
      evalue=exp(-0.5*(ev-time).^2/(flucperiod/1000).^2)*wp(ip);
      value=value+evalue;
      plot(time,evalue);
    end
  end
  figure(2); clf;
  value(valid)=value(valid)./wtime(valid);
  plot(time,value);
    

end






return

%% 1. Read raw proxy datafile if .mat file does not exist
evfile='proxydescription.tsv';
evmatfile=strrep(evfile,'.tsv','.mat');
if exist(evmatfile,'file')
  load(evmatfile);
else
  %"No";"No_sort";"Datafile";"t_min";"t_max";"Plotname";"Proxy";"Interpret";"Latitude";"Longitude";"CutoffFreq";"SourcePDF";"Source ";"Comment"
  proxydir='/h/lemmen/projects/glues/m/holocene/redfit/data/eleven';
  fid=fopen(evfile,'r');
  e=textscan(fid,'%f%f%s%f%f%s%s%s%f%f%f%s%s%s','headerlines',1,'Delimiter',';');
  fclose(fid);
  valid=find(e{2}<500);

  evinfo.No=e{1}(valid);
  evinfo.No_sort=e{2}(valid);
  evinfo.Datafile=e{3}(valid);
  evinfo.Plotname=e{6}(valid);
  evinfo.Proxy=e{7}(valid);
  evinfo.Interpret=e{8}(valid);
  evinfo.Latitude=e{9}(valid);
  evinfo.Longitude=e{10}(valid);
  evinfo.SourcePDF=e{12}(valid);
  evinfo.Source=e{13}(valid);
  
  %% 2.  Analyse events in all time series
  maxevent=30; % to preallocate array
  ne=length(valid);
  events=zeros(ne,maxevent)-NaN;
  maxnp=0;

  for ie=1:ne
    file=fullfile(proxydir,evinfo.Datafile{ie});
    if ~exist(file,'file')
      warning('File %s does not exist, skipped',file);
      continue;
    end
    ts=load(file,'-ascii');
    [ut m50]=movavg(ts(:,1),ts(:,2),0.05);
    [ut m2000]=movavg(ts(:,1),ts(:,2),2.0);
    v=cl_normalize(m50-m2000);
    itime=find(ut>=timelim(1) & ut<=timelim(2));
    if isempty(itime) continue; end
    % Adaptive threshold needed? 
    threshold=norminv(1-1/length(itime));
    p=cl_findpeaks(v(itime),threshold);
    p=p(isfinite(p));
    % Remove events at end of time series (within half flucperiod)
    p=p(find(ut(itime(p))>min(ts(:,1))+flucperiod/2000 & ut(itime(p))<max(ts(:,1))-flucperiod/2000));
    np=length(p);
    if np>maxevent
      warning('%d events detected, increase maxevent',p);
      return;
    end
    if np>0
      events(ie,1:np)=ut(itime(p));
    end
    maxnp=max([np,maxnp]);  
    evinfo.events{ie}=events(ie,1:np);
    evinfo.threshold(ie)=threshold;
    evinfo.time{ie}=ut(itime);
    evinfo.value{ie}=v(itime);
    evinfo.peakindex{ie}=p;
  end
  events=events(:,1:maxnp);
  evinfo.flucperiod=flucperiod;
  save('-v6',strrep(evfile,'.tsv','.mat'),'evinfo');
end

%% 3. Relate this to regions

evregmatfile=strrep(evfile,'.tsv','_regionevents.mat');
[ireg,nreg,loli,lali]=find_region_numbers(reg);
lonlim=loli; latlim=lali;
maxradius=2500;

if ~exist(evregmatfile,'file')
  load(evregmatfile);
else
   
ne=length(evinfo.No);
events.innregion=zeros(nreg,ne)-NaN;
events.dists=zeros(nreg,ne)+Inf;
events.weights=zeros(nreg,ne);

for ir=1:nreg
  if (1==2)
      figure(1); clf;
    clp_basemap('latlim',latlim,'lonlim',lonlim);
    [h,lolimit,lalimit,rlon,rlat]=clp_regionpath('reg',ireg(ir));
  else
    [lon,lat,rlon,rlat]=cl_regionpath('reg',ireg(ir));
  end
  esd=cl_esd(lon,lat);
  dist=cl_distance(evinfo.Longitude,evinfo.Latitude,rlon,rlat)-esd;  
  if (dist<0) dist=0; end
  events.dists(ireg(ir),:)=dist;
  weight=floor(dist/esd);
  %weight=exp(-dist/maxradius);
  %sw=sum(weight);
  events.weights(ireg(ir),:)=weight';%'/sw;
  
  continue;
  ie=find(dist<=maxradius);
  ne=length(ie);
  if ne<1 continue; end
    m_plot(evinfo.Longitude(ie),evinfo.Latitude(ie),'r*');
  
  figure(2); clf; hold on;
  colors=jet(ne);
  evs=[];
  for iie=1:ne
    evs=horzcat(evs,evinfo.events{ie(iie)});
    plot(evinfo.time{ie(iie)},evinfo.value{ie(iie)},'k-','color',colors(iie,:));
    plot(evinfo.events{ie(iie)},-4,'kv','color',colors(iie,:));
  end
  events.inregion(ireg(ir),1:length(evs))=sort(evs,'descend');
end
save('-v6',evregmatfile,'events');
end
  
%% Save all of this to ascii files

% a) EvSeries.dat : containes fore each proxy time series maximum 16 events, i.e. their time in kyr BP, also
%(last two columns) the min and max time within the proxy time series
np=length(evinfo.No);
ne=0;
for ip=1:np
  ne=max([ne,length(evinfo.events{ip})]);
end
ev=zeros(np,ne+2)-1;
for ip=1:np
  pev=evinfo.events{ip};
  nev=length(pev);
  ev(ip,1:nev)=pev;
  ev(ip,ne+1:end)=[min(evinfo.time{ip}) max(evinfo.time{ip})];
end

format=repmat('%.2f ',1,ne+2);
file=sprintf('EventSeries_%03d.tsv',np);
fid=fopen(file,'w');
fprintf(fid,sprintf('%s\n',format),ev');
fclose(fid);

% b) EventInReg.dat: contains at most 8 proxy ids which are close to region
ne=8;
eventinreg=zeros(nreg,ne)-1;
eventinrad=zeros(nreg,ne)-1;
for ir=1:nreg
  [sdists idists]=sort(events.dists(ireg(ir),:));
  ie=idists(1:ne);
  eventinreg(ireg(ir),:)=ie;
  
  de=sdists(1:ne);
  eventinrad(ireg(ir),1:ne)=events.weights(ireg(ir),ie);
end

format=repmat('%d ',1,8);
file=sprintf('EventInReg_%03d_%03d.tsv',np,nreg);
fid=fopen(file,'w');
fprintf(fid,sprintf('%s\n',format),eventinreg');
fclose(fid);

format=repmat('%d ',1,8);
file=sprintf('EventInRad_%03d_%03d.tsv',np,nreg);
fid=fopen(file,'w');
fprintf(fid,sprintf('%s\n',format),eventinrad');
fclose(fid);


return
end