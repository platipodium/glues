
function plot_timeseries_anomaly(varargin)
%\{}

cl_register_function();

%if ~exist('m_proj') addpath('~/matlab/m_map'); end
%if nargin==0 fignum=1; else fignum=varargin{1}; end

[dirs,files]=get_files;

dirs.total='~/projects/glues/m/holocene/redfit/data/eleven';
tsfiles=dir(fullfile(dirs.total,'*.dat'));
nfiles=length(tsfiles);

holodata=get_holodata(fullfile(dirs.proxies,'proxydescription.csv')); 
lon=holodata.Longitude;
lat=holodata.Latitude;
No_sort=holodata.No_sort;


if ~exist('ts.mat','file')
  for ifile=1:nfiles 
   file=fullfile(dirs.total,tsfiles(ifile).name);
   
    isite=strmatch(tsfiles(ifile).name,holodata.Datafile,'exact') ;
    if (isite>0)
    ts(ifile).lon=lon(isite(1));
   ts(ifile).lat=lat(isite(1));
   ts(ifile).no_sort=No_sort(isite(1));
      else
          warning('Site %s not found\n',tsfiles(ifile).name);
     ts(ifile).lon=NaN;
   ts(ifile).lat=NaN;
   ts(ifile).no_sort=NaN;
   end
          
          
          data=load(file,'-ascii');
   ts(ifile).length=length(data(:,1));
   ts(ifile).time=data(:,1);
   ts(ifile).value=data(:,2);
    
   fid=fopen(file,'r');
   if fid<0 continue; end
   ts(ifile).fullname=file;
 
   fprintf('.'); 
   if mod(ifile,80)==0 fprintf('\n'); end
  end
 save('ts','ts');
else 
 load('ts'); 
 nfiles=length(ts);
end

thresh=1.5.^[-1,0,1,2];
thresh=repmat(thresh,2,1);

lstyles=['k-.';'r--';'b-.';'b--'];
mstyles=['ko';'ro';'bo';'bo'];

nevents=zeros(nfiles,4,2);

for ifile=1:nfiles
%for ifile=1:1
 [dummy, sitename, dummy1, dummy2]=fileparts(ts(ifile).fullname);
  fprintf('\nFile %4d \n',ifile);
  t=ts(ifile).time;
  v=ts(ifile).value;
  ts(ifile).sitename=sitename;
  td.mean=mean(t(2:end)-t(1:end-1));
  td.std=std(t(2:end)-t(1:end-1));
  tmima=[min(t),max(t)];
  if any(t>=5.5) ts(ifile).lowspan=max(t)-min(t(t>=5.5)); else ts(ifile).lowspan=inf; end
  if any(t<=6.0) ts(ifile).uppspan=max(t(t<=6.0))-min(t); else ts(ifile).uppspan=inf; end
         
  figure(1); clf reset;
  set(gcf,'Units','Centimeters','Position',[20.0 10.0 15.0 15.0]);
  set(gcf,'PaperPositionMode','auto');
  set(gca,'Position',[0.1 0.55 0.85 0.4]);

  set(gca,'XLim',[0,11]);
  plot(t,v,'k.');
  title(sprintf('Time series %s',strrep(sitename,'_','\_')));
  hold on;
  m50=movavg(t,v,0.05);
  m2000=movavg(t,v,2.0);
  indlower=min(find(t>=5.0));
  indupper=max(find(t<=6.0));
  vdetrend=v-m2000;
  vinterp=movavg(t,vdetrend,0.05);
  plot(t,m50,'r-');
  plot(t,m2000,'b-');
  legend('Raw data','50-yr mov.avg.','2-kyr mov.avg.',0);
  hold off;
  axes('Position',[0.1 0.05 0.85 0.4]);
  vstd=(vinterp-mean(vinterp))/std(vinterp);
  plot(t,0*vstd,'color',[0.5 0.5 0.5]);
  hold on;
  set(gca,'XLim',[0,11],'YLim',[-3,3],'Ytick',[-fliplr(thresh(1,:)),0,thresh(1,:)]);
  set(gca,'yticklabel',{'-2.25','','1','','','','1','','2.25'});
  fill([0 12 12 0],[-3,-3,-2.6,-2.6],'y');
  fill([0 6 5.5 0],[-3,-3,-2.6,-2.6],'c');
  plot(tmima, thresh(:,1),'color',[0.5 0.5 0.5],'linestyle',':');
  plot(tmima,-thresh(:,1),'color',[0.5 0.5 0.5],'linestyle',':');
  plot(tmima, thresh(:,2),'color',[0.5 0.5 0.5],'linestyle','-');
  plot(tmima,-thresh(:,2),'color',[0.5 0.5 0.5],'linestyle','-');
  plot(tmima, thresh(:,3),'color',[0.5 0.5 0.5],'linestyle',':');
  plot(tmima,-thresh(:,3),'color',[0.5 0.5 0.5],'linestyle',':');
  plot(tmima, thresh(:,4),'color',[0.5 0.5 0.5],'linestyle','-');
  plot(tmima,-thresh(:,4),'color',[0.5 0.5 0.5],'linestyle','-'); 
  plot(t,vstd,'k-');
  title(sprintf('Time series %s',strrep(sitename,'_','\_')));
  
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
   
     if (i==3) plot(t(events(:,1)),0*t(events(:,1))+2.8,'Linestyle','none','Marker','v',...
           'MarkerFacecolor','r','MarkerEdgecolor','r'); end
 
   %plot(t(events(:,1)),0*t(events(:,1))+thresh(1,i),'Linestyle','none','Marker','v',...
   %        'MarkerFacecolor','r','MarkerEdgecolor','r'); 
  
     if indlower & ~isempty(events) & find(events(:,1)>=indlower)
       nevents(ifile,i,1)=sum(events(:,1)>=indlower);
     end
     if indupper & ~isempty(events) & find(events(:,1)<=indupper)
       nevents(ifile,i,2)=sum(events(:,1)<=indupper);
     end
   end

   fprintf('.');
end

wevents(ifile,1)=sum(nevents(ifile,:,1))/4.0/ts(ifile).lowspan;
wevents(ifile,2)=sum(nevents(ifile,:,2))/4.0/ts(ifile).uppspan;

if isfinite(ts(ifile).lowspan)
  change(ifile)=(wevents(ifile,2)-wevents(ifile,1))/wevents(ifile,1)*100;
else
  change(ifile)=NaN;
end

text(2,-2.8,['Upper (' sprintf('%.1f',wevents(ifile,2)) '/kyr)']);
text(8,-2.8,['Lower (' sprintf('%.1f',wevents(ifile,1)) '/kyr)']);
h=ylabel('Deviation (\sigma)','Position',[-0.6 -0.0299 1.0001]);
set(gca,'XTicklabel',{'Present',2,4,6,8,10,'kyr BP'});

if round(change(ifile))>0
  h=fill([4.8,5.2,5.2,6.5,6.5,5.2,5.2],[1.5,1.0,1.2,1.2,1.8,1.8,2.0],'r','facecolor',[1 0.7 0.7]);
  text(5,1.5,sprintf('+%d%%',round(change(ifile))),'FontSize',15);
elseif round(change(ifile))<0
  h=fill([4.8,5.2,5.2,6.5,6.5,5.2,5.2],[1.5,1.0,1.2,1.2,1.8,1.8,2.0],'b','facecolor',[0.7 0.7 1]);
  text(5,1.5,sprintf('%d%%',round(change(ifile))),'FontSize',15);
end

%plot_multi_format(gcf,fullfile(dirs.plot,['timeseries_anomaly_' sitename]))
close(gcf);

end

fid=fopen(['timeseries_events.csv'],'w');
for i=1:nfiles
    fprintf(fid,'%s;%4d;%6.2f;%6.2f;%6.2f;%1d;%.2f;%.2f;%3d\n',...
       ts(i).sitename,0,change(i),ts(i).lon,ts(i).lat,...
       0,nevents(i,2),nevents(i,1),ts(i).no_sort);
       %rmdata.Freq(i),rmdata.gdiff(i),rmdata.lon(i),rmdata.lat(i),...
       %rmdata.istot(i),rmdata.isupp(i),rmdata.islow(i),rmdata.No_sort(i));
end
fclose(fid);

save('ts','tsfiles','ts','nevents','wevents','change');

return
