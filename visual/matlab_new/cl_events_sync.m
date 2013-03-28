function cl_events_sync(varargin)
% Needs statistics toolbox for norminv

arguments = {...
  {'reg','all'},... 
  {'threshold',1.8},... 
  {'timelim',[0 12]},...
  {'flucperiod',175},...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for iover=1:a.length 
  lv=length(a.value{iover});
  if (lv>1 & iscell(a.value{iover}))
    for j=1:lv
      eval( [a.name{iover} '{' num2str(j) '} = ''' char(clp_valuestring(a.value{iover}(j))) ''';']);         
    end
  else
    eval([a.name{iover} '=' clp_valuestring(a.value{iover}) ';']); 
  end
end


%% 1. Read raw proxy datafile if .mat file does not exist
tsfile='/h/lemmen/devel/glues/data/Steinhilber2009_totalsolarirradiance.tsv';

%"No";"No_sort";"Datafile";"t_min";"t_max";"Plotname";"Proxy";"Interpret";"Latitude";"Longitude";"CutoffFreq";"SourcePDF";"Source ";"Comment"
evinfo.No=1; evinfo.No_sort=1;
evinfo.Datafile='/Users/lemmen/devel/glues/data/Steinhilber2009_totalsolarirradiance.tsv';
evinfo.Plotname='TSI (Steinhilber)'; evinfo.Proxy='TSI';
evinfo.Interpret='Solar variation';
evinfo.Latitude=NaN; evinfo.Longitude=NaN;
       
%% 2.  Analyse events in all time series
maxevent=100; % to preallocate array
ne=length(evinfo.No); ie=1;
events=zeros(ne,maxevent)-NaN;
maxnp=0;

file=evinfo.Datafile;
if ~exist(file,'file')
   warning('File %s does not exist, skipped',file);
   error('Terminated');
end

ts=load(file,'-ascii');
ts(:,1)=ts(:,1)/1000.0;
[ut m50]=movavg(ts(:,1),ts(:,2),0.05);
[ut m2000]=movavg(ts(:,1),ts(:,2),2.0);
evinfo.t_min(ie)=min(ut);
evinfo.t_max(ie)=max(ut);
v=cl_normalize(m50-m2000);
itime=find(ut>=timelim(1) & ut<=timelim(2));
if isempty(itime) error; end
% Adaptive threshold:
if ~isnumeric(threshold)
   threshold=norminv(1-1/length(itime));
end
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
    maxnp=max([np,maxnp]);  
    evinfo.events{ie}=events(ie,1:np);
    evinfo.threshold(ie)=threshold;
    evinfo.time{ie}=ut(itime);
    evinfo.value{ie}=v(itime);
    evinfo.peakindex{ie}=p;
    evinfo.threshold(ie)=threshold;
    
    % Add diagnostics on mean time difference in interval itime
    tdiff=ut(itime(2:end))-ut(itime(1:end-1));
    evinfo.sampling.mean(ie)=mean(tdiff);
    evinfo.sampling.max(ie)=max(tdiff);
    
    if mod(ie,10)==0 fprintf('.'); end

  events=events(:,1:maxnp);
  evinfo.flucperiod=flucperiod;
  evinfo.threshold=threshold;
  %save('-v6',evmatfile,'evinfo');

%% 3. Relate this to regions

nreg=685
events.inregion=ones(nreg,ne)
events.dists=ones(nreg,ne);
events.weights=ones(nreg,ne);
%save('-v6',evregmatfile,'events');


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
  if nev<1 continue; end
  ev(ip,1:nev)=pev;
  ev(ip,ne+1:end)=[min(evinfo.time{ip}) max(evinfo.time{ip})];
end

format=repmat('%.2f ',1,ne+2);
file=sprintf('EventSeries_%03d_%03.1f.tsv',np,threshold);
fid=fopen(file,'w');
fprintf(fid,sprintf('%s\n',format),ev');
fclose(fid);

% b) EventInReg.dat: contains at most 8 proxy ids which are close to region
% and satisfy minimum resoultion requriment (2x fluctation)
ne=1;
eventinreg=ones(nreg,ne);
eventinrad=ones(nreg,ne);
eventindist=zeros(nreg,ne);
iover=find(evinfo.sampling.mean>flucperiod/1000);
for ie=iover
  fprintf('Skipped %s due to insufficient sampling (%d)\n',evinfo.Plotname{ie},round(evinfo.sampling.mean(ie)*1000));
end

format=repmat('%d ',1,ne);
file=sprintf('EventInReg_%03d_%03d_%03.1f.tsv',np,nreg,threshold);
fid=fopen(file,'w');
fprintf(fid,sprintf('%s\n',format),eventinreg');
fclose(fid);

format=repmat('%d ',1,ne);
file=sprintf('EventInRad_%03d_%03d_%03.1f.tsv',np,nreg,threshold);
fid=fopen(file,'w');
fprintf(fid,sprintf('%s\n',format),eventinrad');
fclose(fid);

eventindist(eventindist>9999)=9999;
eventindist=round(eventindist);
format=repmat('%04d ',1,8);
file=sprintf('EventInDist_%03d_%03d_%03.1f.tsv',np,nreg,threshold);
fid=fopen(file,'w');
fprintf(fid,sprintf('%s\n',format),eventindist');
fclose(fid);

eventtimes=round(sort(1000*ev(1,1:16),2,'descend'));
regeventtimes=repmat(eventtimes,nreg,1);

format=repmat('%05d ',1,16);
file=sprintf('RegionEventTimes_%03d_%03d_%03.1f.tsv',np,nreg,threshold);
fid=fopen(file,'w');
fprintf(fid,sprintf('%s\n',format),round(regeventtimes'));
fclose(fid);

return
end