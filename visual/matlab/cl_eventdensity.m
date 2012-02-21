function cl_eventdensity(varargin)

arguments = {...
  {'nreg',685},... 
  {'np',128},... 
  {'flucperiod',175},...
  {'timelim',[0 11]},... % in ka BP
  {'nofig',0},...
  {'noprint',0},...
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
%evradiusfile=sprintf('EventInRad_%03d_%03d.tsv',np,nreg);
evdistfile=sprintf('EventInRad_%03d_%03d.tsv',np,nreg);

eventinreg=load(evregionfile,'-ascii');
%eventinrad=load(evradiusfile,'-ascii');
eventindist=load(evdistfile,'-ascii');
evseries=load(evseriesfile,'-ascii');

emax=size(evseries,2)-2;
regionevents=zeros(nreg,emax)-1;

reg='all'; [ireg,nreg,loli,lali]=find_region_numbers(reg);
lonlim=loli; latlim=lali;


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
  c=jet(nip);
  
  eventinrad=exp(-eventindist);
  
  wmax=max(max(eventindist(ir,1:nip)));
  %wp=wmax+1-squeeze(eventinrad(ir,1:nip));
  wp=eventindist(ir,1:nip);
  if all(wp==0) wp(1:nip)=1; end
  for ip=1:nip
    %plot(evseries(p(ip),1:emax),wp(ip),'kd');
    it=find(time>=evseries(p(ip),emax+1) & time<=evseries(p(ip),emax+2));
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
      evalue=exp(-0.5*(ev-time).^2/(flucperiod/1000).^2)*wp(ipsort(ip))*mwtime/max(wp);
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
  %
  
  value=cl_normalize(value);
  [pvalue,ipeak]=findpeaks(value);
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
  hst=plot(time,value*0-minval,'k:','color','w','LineWidth',2);
 
  
  ylimit=get(gca,'ylim');
  set(gca,'ylim',[ -mevalue*1.1 max([evalue wtime])*1.1]);
  ax0=gca;
  
  itime=find(wtime==mwtime);
  
  text(time(itime(end))-0.2,0.97*mwtime,sprintf('Region %d',ir),...
      'FontSize',20,'Vertical','top','horizontal','left','FontName','Times');
  
  pos=get(gcf,'pos');
  set(gcf,'pos',[pos(1:2) 700 340]);
  set(gca,'XDir','reverse','FontName','Times','FontSize',14);
  ytl=get(gca,'YTickLabel');
  ineg=strmatch('-',ytl);
  ytl(ineg,:)=' ';
  set(gca,'YTickLabel',ytl);
  ylabel('Relative intensity / number of series');
  set(gca,'XMinorTick','on'); set(gca,'yMinorTick','on');
  
  %valid=find(he>0);
  
  legends{1}='No. of series';
  for i=1:nip
    legends{i+3}=sprintf('Proxy %d',p(i));
  end
  legends{3}='Weighted sum';
  legends{2}='Identified peaks';  
  
  pl=legend([hk hp hs he(:)'],legends);
  set(pl,'color','w','box','on','location','Northeastoutside','fontSize',12);
  pos=get(ax0,'pos');

  cl_xticktitle('ka BP');
  
  if noprint continue; end
  cl_print(1,'name',sprintf('eventdensity_%03d',ir),'ext','eps');
  
end

npeak=ceil(sum(sum(regionevents>0))/nreg);

format=repmat('%.2f ',1,emax);
file=sprintf('RegionEventTimes_%03d_%03d_%02d.tsv',np,nreg,npeak);
fid=fopen(file,'w');
fprintf(fid,sprintf('%s\n',format),regionevents');
fclose(fid);


return
end