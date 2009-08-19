function plot_redfit_condensed(description,mask,year,dyear,extra)

cl_register_function();

if ~exist('description','var')
     description='';
end    

ratio=33;
if ~exist('year','var') year=5.5; end
if ~exist('dyear','var') dyear=0.5; end

fignum=2;

yrtext=sprintf('_%.1f_%.1f',year,dyear);

if exist('extra','var')
yrtext=[yrtext '_' extra];
end

if ~exist('mask','var') | strcmp(mask,'')
  mask=['*_condensed.tsv'];
end    


fdir=['/h/lemmen/projects/glues/m/holocene/redfit/data/output/repl' yrtext];
files=dir(fullfile(fdir , mask));

tsv=['replacemany' yrtext '_' num2str(ratio) '.tsv'];

if ~exist(tsv, 'file') 
    newfile=1;
    fid=fopen(tsv,'w');
     fprintf(fid,'"Site" "NEvents" "Freq" "ar" "ar95" "arcrit" "gtot" "gupp" "glow"\n');
else
  rmdata=read_textcsv(tsv,' ','"');   
  fid=fopen(tsv,'a');
  newfile=0;
end

for ifile=1:length(files)
  
file=fullfile(fdir,files(ifile).name);
%file='../scripts/Canary_d18O_red_condensed.tsv';

%if ~exist(file,'file') return

[fpe.path fpe.name fpe.ext fpe.version]=fileparts(file);


% skip records already in file
if (newfile==0)
    if strmatch(fpe.name,rmdata.Site,'exact')
      continue; 
    end
end

try 
  data=load(file,'-ascii');
catch
  warning('Could not load %s as ASCII file, skipped\n',fpe.name);
  continue;
end

if numel(data)<1
  warning('No redfit performed for %s',fpe.name);
  continue;
end

d=data(:,2:end);

novar=0;
if (size(data,1)<6)
    warning('No variation calculated for %s',fpe.name);
    novar=1;
end

freq=d(1,:);
gxx=db(d(2,:));
gredth=db(d(3,:));
th95=db(d(4,:));
thcrit=db(d(5,:));

if ~novar 
    p1mean=db(d(6,:));
p1sigmau=db(d(6,:)+d(7,:));
p1sigmal=db(d(6,:)-d(7,:));
p2mean=db(d(8,:));
p2sigmau=db(d(8,:)+d(9,:));
p2sigmal=db(d(8,:)-d(9,:));
end

nout=length(freq);

b=1000*[[1/1800 1/1000.];[1/500 1/333];[1/250 1/200]];

figure(fignum);
clf reset;

plot(freq,gxx);
hold on;
ylim=get(gca,'YLim');
by=reshape(repmat(ylim,2,1),1,4);
for i=1:3 fill([b(i,:) fliplr(b(i,:))],by,[0.99 0.99 0.8],'EdgeColor','none'); end 

xlim=[1/2. 1000/200.];
set(gca,'XLim',xlim)
valid=find(freq>=xlim(1) & freq<=xlim(2));
xtickv=get(gca,'XTick');
xticklabel=round(1000./xtickv);
set(gca,'XTickLabel',xticklabel);
xlabel('Recurrence time (yr)')
ylabel('Spectral intensity (dB)');
title([fpe.name ' Bootstrap/redfit ' description ],'Interpreter','none');

if ~novar
plot(freq,p1sigmau,'r','LineWidth',0.1);
plot(freq,p1sigmal,'r','LineWidth',0.1);
plot(freq,p2sigmau,'g','LineWidth',0.1);
end

p1=plot(freq,gxx,'b','Linewidth',2);
p2=plot(freq,gredth,'k','LineWidth',3);
plot(freq,th95,'k');
plot(freq,thcrit,'k','LineWidth',3);

if ~novar
p3=plot(freq,p1mean,'r','LineWidth',2);
p4=plot(freq,p2mean,'g','LineWidth',2);
legend([p1,p2,p3,p4],'original','ar(1)','Period 1', 'Period 2');
else
legend([p1,p2],'original','ar(1)');
end
    

if any(thcrit>th95) thresh=th95; else thresh=thcrit; end
imin=min(find(freq>=b(1,1)));
imax=max(find(freq<=5));
xmaxima=0;
nmaxima=0;
ymaxima=0;

if ~novar
gmax=max([gxx;p1mean;p2mean]);
else
gmax=gxx;
p1mean=gxx+NaN;
p2mean=gxx+NaN;
end

if (any(gmax(imin:imax)>=thresh(imin:imax)))
  above=find(gmax>=thresh & freq>=b(1,1) & freq<=5);
  nabove=length(above);
  nmaxima=1;
  begin=1;
  for a=2:nabove
    if (above(a)>above(a-1)+1) 
      ab=above(begin:a-1);
      [ymaxima(nmaxima),imax]=max(gmax(ab));
      xmaxima(nmaxima)=ab(imax);
      nmaxima=nmaxima+1;
      begin=a;
    end
  end
  %if (nmaxima<2) continue; end
  ab=above(begin:end);
  [ymaxima(nmaxima),imax]=max(gmax(ab));
  xmaxima(nmaxima)=ab(imax);
  for a=1:nmaxima
    plot([freq(xmaxima(a)),freq(xmaxima(a))],[by(1),ymaxima(a)],'b-');
    % if ~novar
    fprintf('"%s" %3d %5d %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f\n',fpe.name,nmaxima,round(1000./freq(xmaxima(a))),...
      gredth(xmaxima(a)),th95(xmaxima(a)),thcrit(xmaxima(a)),gxx(xmaxima(a)),p1mean(xmaxima(a)),p2mean(xmaxima(a)));  
    fprintf(fid,'"%s" %3d %5d %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f\n',fpe.name,nmaxima,round(1000./freq(xmaxima(a))),...
      gredth(xmaxima(a)),th95(xmaxima(a)),thcrit(xmaxima(a)),gxx(xmaxima(a)),p1mean(xmaxima(a)),p2mean(xmaxima(a))); 
    %else
    %fprintf('"%s" %3d %5d %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f\n',fpe.name,nmaxima,round(1000./freq(xmaxima(a))),...
    %  gredth(xmaxima(a)),th95(xmaxima(a)),thcrit(xmaxima(a)),gxx(xmaxima(a)),p1mean(xmaxima(a)),p2mean(xmaxima(a)));  
    %fprintf(fid,'"%s" %3d %5d %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f\n',fpe.name,nmaxima,round(1000./freq(xmaxima(a))),...
    %  gredth(xmaxima(a)),th95(xmaxima(a)),thcrit(xmaxima(a)),gxx(xmaxima(a)),p1mean(xmaxima(a)),p2mean(xmaxima(a))); 
    %end
    
  end
  
else
  if novar novar=NaN; end
  fprintf('"%s" %3d %5d %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f\n',fpe.name,[1:6]*0,-novar,-novar);
  fprintf(fid,'"%s" %3d %5d %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f\n',fpe.name,[1:6]*0,-novar,-novar);
end

print(gcf,'-depsc2', [file '.eps']) ;
hold off
%close all
  %pause
end
fclose(fid);

return
