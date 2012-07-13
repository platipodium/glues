function cl_eventdensity(varargin)

arguments = {...
  {'nreg',685},... 
  {'np',134},... 
  {'flucperiod',175},...
  {'timelim',[0 12]},... % in ka BP
  {'nofig',0},...
  {'noprint',0},...
  {'threshold','adaptive'},...
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


if ~isnumeric(threshold)
  infix='.';
else
  infix=sprintf('_%03.1f.',threshold);
end
evseriesfile=sprintf('EventSeries_%03d%stsv',np,infix);
evregionfile=sprintf('EventInReg_%03d_%03d%stsv',np,nreg,infix);
%evradiusfile=sprintf('EventInRad_%03d_%03d.tsv',np,nreg);
evdistfile=sprintf('EventInRad_%03d_%03d%stsv',np,nreg,infix);
evinfofile=sprintf('proxydescription_265_%3d%smat',np,infix);

eventinreg=load(evregionfile,'-ascii');
%eventinrad=load(evradiusfile,'-ascii');
eventindist=load(evdistfile,'-ascii');
evseries=load(evseriesfile,'-ascii');
load(evinfofile); % into struct evinfo

emax=size(evseries,2)-2;
regionevents=zeros(nreg,emax)-1;

reg='all'; [ireg,nreg,loli,lali]=find_region_numbers(reg);
lonlim=loli; latlim=lali;

ireg=236; nreg=1;


for j=1:nreg

  ir=ireg(j);
  he=[];
  time=min(timelim):0.01:max(timelim);
  wtime=zeros(size(time));
  value=zeros(size(time));
  
  if ~nofig
    figure(1); clf;
    set(gca,'Xlim',timelim,'FontName','Times'); hold on;
  end
  
  p=eventinreg(ir,:);
  p=p(p>0);
  nip=length(p);
  c=0.5*jet(nip);
  
  eventinrad=exp(-eventindist);
  
  wmax=max(max(eventindist(ir,1:nip)));
  %wp=wmax+1-squeeze(eventinrad(ir,1:nip));
  wp=exp(-eventindist(ir,1:nip)/2);
  if all(wp==0) wp(1:nip)=1; end
  for ip=1:nip
    %plot(evseries(p(ip),1:emax),wp(ip),'kd');
    % weight by number of events
    %it=find(time>=evseries(p(ip),emax+1) & time<=evseries(p(ip),emax+2));
    
    % weight by length of time series
    it=find(time>=evinfo.t_min(p(ip)) & time<=evinfo.t_max(p(ip)));
    
    wtime(it)=wtime(it)+1;
  end
  if ~nofig hk=plot(time,wtime,'k--','linewidth',3); end
  
  valid=find(wtime>0);
  mwtime=max(wtime);
 
  mevalue=0;
  [p ipsort]=sort(p);
  for ip=nip:-1:1
    evs=evseries(p(ip),1:emax);
    evmin=evseries(p(ip),emax+1);
    evmax=evseries(p(ip),emax+2);
    e=find(evs>=evmin+flucperiod/2000.0 & evs<=evmax-flucperiod/2000.0);
    ne=length(e);
    freq(ip)=ne/(evmax-evmin-flucperiod/1000);
    for ie=1:ne
      ev=evs(e(ie));
      %[mt,it]=min(abs(ev-time));
      %evalue=time;
      %evalue(it)=wp(ip)/wtime(it);
      %evalue=exp(-0.5*(ev-time).^2/(flucperiod/1000).^2)*wp(ipsort(ip))*mwtime/max(wp);
      evalue=5*exp(-0.5*(ev-time).^2/(flucperiod/1000).^2)*wp(ipsort(ip));
      mevalue=max([mevalue evalue]);
      value=value+evalue;
      %plot(time,evalue,'k-');
      if ~nofig
        he(ip)=patch([time,fliplr(time)],[-evalue,0*evalue],'w','FaceColor',c(ip,:),'FaceAlpha',0.5);
      end
     end
    if ne==0 & ~nofig
      he(ip)=patch([time,fliplr(time)],[-value,0*value],'w','FaceColor',c(ip,:),'FaceAlpha',0.5,'visible','off');
    end
  end
  
 
  %figure(2); clf; hold on;
  value(valid)=value(valid)./wtime(valid);
  %plot(time,value,'k-');
  [ut value]=movavg(time,value,flucperiod/1000);
  %[ut value]=movavg(time,value,0.05);
  %
  
  value=cl_normalize(value);
  %[pvalue,ipeak]=findpeaks(value); % dsp toolbox
  [pvalue,ipeak]=cl_findpeaks_new(value);
  % todo: if no dsp toolbox
  %[ipeak]=cl_findpeaks(value,-0.5);
  %pvalue=value(ipeak);
  ipos=find(pvalue>0);
  ipeak=ipeak(ipos);
  pvalue=pvalue(ipos);
  
  %plot(time,value,'k-','linewidth',2);
  %plot(time,value,'b-'); hold on;
  %value(value<0.7)=-0.1;
  %plot(time,value,'r-');
  %pvalue=value;
  %pvalue(value<0)=-0.1;
  
  %ipeak=cl_findpeaks(value,0);   
  %ipeak=ipeak(isfinite(ipeak));
  %ipos=find(value(ipeak)>0);
  %ipeak=ipeak(ipos);
  minval=min(value);
  value=(value-minval)';
  value=value*0.6*mwtime/max(value);
  mg=repmat(0.5,1,3);
  
  if ~nofig
    hs=patch([time,fliplr(time)],[value 0*value],'w','FaceColor',repmat(0.7,1,3),'FaceAlpha',0.9);
  end
  
  %pvalue=value(ipeak);
  
  %npeak=min(ceil(mean(freq)),emax);
  
  %plot(time(ipeak),value(ipeak),'kv','MarkerSize',10,'MarkerFaceColor','k');
  
  npeak=min([length(ipeak),emax]);
  [speak ispeak]=sort(pvalue);
  peaktime=sort(time(ipeak(ispeak(1:npeak))));
  regionevents(ir,1:npeak)=peaktime;

  if nofig continue; end
  %plot(time(ipeak(ispeak(1:npeak))),value(ipeak(ispeak(1:npeak))),'kv','MarkerSize',10,'MarkerFaceColor','k');

  evalue=time*0;
  for ie=1:npeak;
    evalue=evalue+exp(-0.5*(peaktime(ie)-time).^2/(flucperiod/1000).^2);
  end
  evalue=evalue*max(value)/max(evalue)*1.1;
  
  hp=patch([time,fliplr(time)],[evalue,0*evalue],'w','FaceColor',repmat(0.4,3,1),'FaceAlpha',0.9);
  uistack(hp,'down');
  %hst=plot(time,value*0-minval,'k:','color','w','LineWidth',2);
 
  
  ylimit=get(gca,'ylim');
  set(gca,'ylim',[ -mevalue*1.1 max([evalue wtime])*1.1],'FontSize',15,'FontName','Times');
  ax0=gca;
  
  itime=find(wtime==mwtime);
  
 % text(time(itime(end))-0.2,0.97*mwtime,sprintf('Region %d',ir),...
 %     'FontSize',20,'Vertical','top','horizontal','left','FontName','Times');
  
  pos=get(gcf,'pos');
  set(gcf,'pos',[pos(1:2) 700 340]);
  set(gca,'XDir','reverse','FontName','Times','FontSize',14);
  ytl=get(gca,'YTickLabel');
  ineg=strmatch('-',ytl);
  ytl(ineg,:)=' ';
  set(gca,'YTickLabel',ytl);
  ylabel('Relative event intensity (A.U.)');
  set(gca,'XMinorTick','on'); set(gca,'yMinorTick','on');
  
  text(5.3,1,'Weighted sum','color','w','FontSize',14,'FontName','Times');
  text(8,4,'Identified peaks','color',repmat(0.4,3,1),'FontSize',14,'FontName','Times');
  text(10,-3,'Individual events from each time series','color','k','FontSize',14,'FontName','Times');

  text(10.3,6.8,'Number of time series','color','k','FontSize',14,'FontName','Times');

  
  %valid=find(he>0);
  if (1==2)
    legends{1}='No. of series';
  %for i=1:nip
  %  legends{i+3}=sprintf('Proxy %d',p(i));
  %end
    legends{3}='Weighted sum';
    legends{2}='Identified peaks';  
  
    pl=legend([hk hp hs],legends);
    set(pl,'color','w','box','on','location','westoutside','fontSize',12);
    pos=get(ax0,'pos');
  end
  
  cl_xticktitle('ka BP');
  
  if noprint continue; end
  if isnumeric(threshold)
    cl_print(1,'name',sprintf('eventdensity_%03d_%03.1f',ir,threshold),'ext','pdf');
  else
  cl_print(1,'name',sprintf('eventdensity_%03d',ir),'ext','pdf');
  end    
end

npeak=ceil(sum(sum(regionevents>0))/nreg);

save(sprintf('RegionEventTimes_%03d_%03d_%02d.mat',np,nreg,npeak),'np','nreg','npeak','emax','regionevents');

regionevents=round(regionevents*1000);
regionevents(regionevents<0)=-9999;
regionevents=sort(regionevents,2,'descend');

format=repmat('%05d ',1,emax);
file=sprintf('RegionEventTimes_%03d_%03d_%02d.tsv',np,nreg,npeak);
fid=fopen(file,'w');
fprintf(fid,sprintf('%s\n',format),regionevents');
fclose(fid);


return
end