function cl_events(varargin)

arguments = {...
  {'reg','all'},... 
  {'threshold',1.5},... 
  {'timelim',[0 12]},...
  {'flucperiod',175},...
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


%% 1. Read raw proxy datafile if .mat file does not exist
evfile='proxydescription_258_128.csv';
evmatfile=strrep(evfile,'.csv','.mat');
if exist(evmatfile,'file')
  load(evmatfile);
else
  %"No";"No_sort";"Datafile";"t_min";"t_max";"Plotname";"Proxy";"Interpret";"Latitude";"Longitude";"CutoffFreq";"SourcePDF";"Source ";"Comment"
  proxydir='/h/lemmen/projects/glues/m/holocene/redfit/data/eleven';
  %fid=fopen(evfile,'r');
  evinfo=read_textcsv(evfile,';','"');
  
  valid=find(evinfo.No_sort<500);
  f=fieldnames(evinfo);
  nf=length(f);
  
  for jf=1:nf
    a=evinfo.(f{jf});
    if length(a)<length(valid);continue; end
    evinfo.(f{jf})=a(valid);
  end
       
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
    evinfo.threshold(ie)=threshold;
    if mod(ie,10)==0 fprintf('.'); end

  end
  events=events(:,1:maxnp);
  evinfo.flucperiod=flucperiod;
  save('-v6',strrep(evfile,'.csv','.mat'),'evinfo');
end

%% 3. Relate this to regions

evregmatfile=strrep(evfile,'.csv','_regionevents.mat');
[ireg,nreg,loli,lali]=find_region_numbers(reg);
lonlim=loli; latlim=lali;
maxradius=2500;

if exist(evregmatfile,'file')
  load(evregmatfile);
else
   
ne=length(evinfo.No);
events.inregion=zeros(nreg,ne)-NaN;
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
  dist=cl_distance(evinfo.Longitude,evinfo.Latitude,rlon,rlat)-esd/2;  
  dist(dist<0)=0;
  events.dists(ireg(ir),:)=dist;
  weight=floor(dist/(esd/2));
  if any(weight<0)
      fprintf(' %d',dist(weight<0));
  end
  %weight=exp(-dist/maxradius);
  %sw=sum(weight);
  events.weights(ireg(ir),:)=weight';%'/sw;
  if mod(ir,10)==0; fprintf('.'); end
  
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
eventindist=zeros(nreg,ne)-1;
for ir=1:nreg
  [sdists idists]=sort(events.dists(ireg(ir),:));
  ie=idists(1:ne);
  eventinreg(ireg(ir),:)=ie;
  
  de=sdists(1:ne);
  eventinrad(ireg(ir),1:ne)=events.weights(ireg(ir),ie);
  eventindist(ireg(ir),1:ne)=events.dists(ireg(ir),ie);
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

eventindist(eventindist>9999)=9999;
eventindist=round(eventindist);
format=repmat('%04d ',1,8);
file=sprintf('EventInDist_%03d_%03d.tsv',np,nreg);
fid=fopen(file,'w');
fprintf(fid,sprintf('%s\n',format),eventindist');
fclose(fid);



return
end