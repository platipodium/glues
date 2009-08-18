function [phdl]=plot_single_timeseries_anomaly(varargin)

cl_register_function();

% Default values
fs=16; no_title=0; no_xticks=0; i=1; no_arrow=0; no_event=0;
no_normalise=0;
lstyles=['k-.';'r--';'b-.';'b--'];
mstyles=['ko';'ro';'bo';'bo'];
tcrit=5.5;
tcritvar=0.5;
sitename='';


[dirs,files]=get_files;
dirs.total='~/projects/glues/m/holocene/redfit/data/eleven';


if (nargin>0)
  i=varargin{1};
  for iargin=2:nargin
    if strcmp(varargin{iargin},'FontSize') fs=varargin{iargin+1}; iargin=iargin+1; end;
    if strcmp(varargin{iargin},'NoTitle') no_title=1; end;
    if strcmp(varargin{iargin},'NoXTicks') no_xticks=1; end;
    if strcmp(varargin{iargin},'NoNormalise') no_normalise=1; end;
   if strcmp(varargin{iargin},'Noevent') no_event=1; end;
    if strcmp(varargin{iargin},'NoArrow') no_arrow=1; end;
    if strcmp(varargin{iargin},'LineStyle') lstyles=varargin{iargin+1}; iargin=iargin+1; end;
    if strcmp(varargin{iargin},'Dir') 
        dirs.total=varargin{iargin+1}; iargin=iargin+1; end;
      
  end;
end;  

%dirs.total='~/projects/glues/m/holocene/redfit/data/disturbed/d0.1';
%dirs.total='~/projects/glues/m/holocene/redfit/data/deevented';

load('holodata.mat');
%file=fullfile(dirs.total,strrep(holodata.Datafile{i},'.dat','_tot.dat'));
file=fullfile(dirs.total,holodata.Datafile{i});

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


nevents=zeros(4,2);
ifile=i;
[dummy, sitename, dummy1, dummy2]=fileparts(ts.fullname);
t=ts.time;
v=ts.value;
ts.sitename=sitename;
td.mean=mean(t(2:end)-t(1:end-1));
td.std=std(t(2:end)-t(1:end-1));
tmima=[min(t),max(t)];
if any(t>=tcrit-tcritvar) ts.lowspan=max(t)-min(t(t>=tcrit-tcritvar)); else ts.lowspan=inf; end
if any(t<=tcrit+tcritvar) ts.uppspan=max(t(t<=tcrit+tcritvar))-min(t); else ts.uppspan=inf; end

set(gca,'XLim',[0,12]);
if (~no_title) title(sprintf('Time series anomaly %s',strrep(sitename,'_','\_'))); end;
m50=movavg(t,v,0.05);
m2000=movavg(t,v,2.0);
indlower=min(find(t>=tcrit-tcritvar));
indupper=max(find(t<=tcrit+tcritvar));
vsize=size(v);
if vsize(2)>vsize(1) v=v'; end
vdetrend=v-m2000;
vinterp=movavg(t,vdetrend,0.05);
if ~no_normalise
  vstd=(vinterp-mean(vinterp))/std(vinterp);
else
   vstd=ts.value;
end
hold on;
set(gca,'XLim',[0,11],'YLim',[-3,3],'Ytick',[-fliplr(thresh(1,:)),0,thresh(1,:)]);
set(gca,'yticklabel',{'-2.25','','1','','','','1','','2.25'});
if (~no_xticks)
  fill([0 12 12 0],[-3,-3,-2.25,-2.25],'y');
  fill([0 tcrit+tcritvar tcrit-tcritvar 0],[-3,-3,-2.25,-2.25],'c');
end
  plot(tmima, thresh(:,1),'color',[0.5 0.5 0.5],'linestyle',':');
plot(tmima,-thresh(:,1),'color',[0.5 0.5 0.5],'linestyle',':');
plot(tmima, thresh(:,2),'color',[0.5 0.5 0.5],'linestyle','-');
plot(tmima,-thresh(:,2),'color',[0.5 0.5 0.5],'linestyle','-');
plot(tmima, thresh(:,3),'color',[0.5 0.5 0.5],'linestyle',':');
plot(tmima,-thresh(:,3),'color',[0.5 0.5 0.5],'linestyle',':');
plot(tmima, thresh(:,4),'color',[0.5 0.5 0.5],'linestyle','-');
plot(tmima,-thresh(:,4),'color',[0.5 0.5 0.5],'linestyle','-'); 
phdl=plot(t,vstd,'k-');

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
  
  %plot(t(ind),vstd(ind),'Linestyle','none','Marker','o','MarkerEdgecolor','r'); 
  %plot(t(negind),vstd(negind),'Linestyle','none','Marker','o','MarkerEdgecolor','r'); 
  
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
   %plot(t(events(:,1)),events(:,2),mstyles(i,:),'Linestyle','none','Marker','v','Facecolor','r')
   
     if (i==3) plot(t(events(:,1)),0*t(events(:,1))+2.9,'Linestyle','none','Marker','v',...
           'MarkerFacecolor','r','MarkerEdgecolor','r'); end
 
   %plot(t(events(:,1)),0*t(events(:,1))+thresh(1,i),'Linestyle','none','Marker','v',...
   %        'MarkerFacecolor','r','MarkerEdgecolor','r'); 
  
     if indlower & ~isempty(events) & find(events(:,1)>=indlower)
       nevents(i,1)=sum(events(:,1)>=indlower);
     end
     if indupper & ~isempty(events) & find(events(:,1)<=indupper)
       nevents(i,2)=sum(events(:,1)<=indupper);
     end
   end

end

wevents(1)=sum(nevents(:,1))/4.0/ts.lowspan;
wevents(2)=sum(nevents(:,2))/4.0/ts.uppspan;

if isfinite(ts.lowspan)
  change=(wevents(2)-wevents(1))/wevents(1)*100;
else
  change=NaN;
end

h=ylabel('Anomaly (\sigma)','Position',[-0.6 -0.0299 1.0001]);
       % text(2,-2.8,['Upper (' sprintf('%.1f',wevents(2)) '/ka)']);

if ~no_xticks 
  %  text(8,-2.8,['Lower (' sprintf('%.1f',wevents(1)) '/ka)']);
     text(8,-2.6,'Lower');
    %text(2,-2.8,['Upper (' sprintf('%.1f',wevents(2)) '/ka)']);
text(2,-2.6,'Upper');
   set(gca,'XTicklabel',{'Present',2,4,6,8,10,'ka BP'});
else set(gca,'XTicklabel',[]);
end

if ~no_arrow
if round(change)>0
  h=fill([4.8,5.2,5.2,6.5,6.5,5.2,5.2],[1.5,1.0,1.2,1.2,1.8,1.8,2.0],'r','facecolor',[1 0.7 0.7]);
  text(5,1.5,sprintf('+%d%%',round(change)),'FontSize',fs);
elseif round(change)<0
  h=fill([4.8,5.2,5.2,6.5,6.5,5.2,5.2],[1.5,1.0,1.2,1.2,1.8,1.8,2.0],'b','facecolor',[0.7 0.7 1]);
  text(5,1.5,sprintf('%d%%',round(change)),'FontSize',fs);
end
end

hold off;

return
