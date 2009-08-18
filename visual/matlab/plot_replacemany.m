function plot_replacemany(description,mask,year,dyear,extra)

cl_register_function();

if ~exist('description','var')
     description='';
end    

ratio=33;
if ~exist('year','var') year=5.5; end
if ~exist('dyear','var') dyear=2.0; end

fignum=2;

yrtext=sprintf('_%.1f_%.1f',year,dyear);

if exist('extra','var')
yrtext=[yrtext '_' extra]
end

if ~exist('mask','var') | strcmp(mask,'')
  mask=['*.dat_' num2str(ratio) '_var.tsv'];
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
  continue;
end


p=data(6:end,1);
nrat=data(1,2);
d=data(:,3:end);

freq=d(1,:);
gxx=db(d(2,:));
gredth=db(d(3,:));
th95=db(d(4,:));
thcrit=db(d(5,:));

d=db(d(6:end,:));

nout=length(freq);
nvar=length(d(:,1));


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
title([fpe.name ' (Replace ' description ' ' num2str(nrat) '%)'],'Interpreter','none');

for i=1:-nvar
    if (p(i)==1) plot(freq,d(i,:),'Color','r');
    else  plot(freq,d(i,:),'Color','g');
    end 
end 

p1=plot(freq,gxx,'b','Linewidth',2);
p2=plot(freq,gredth,'k','LineWidth',3);
plot(freq,th95,'k');
plot(freq,thcrit,'k','LineWidth',3);

max1=mean(d(find(p==1),:));
max2=mean(d(find(p==2),:));
n1=sum(p==1);
n2=sum(p==2);

p3=plot(freq,max1,'r','LineWidth',2);
p4=plot(freq,max2,'g','LineWidth',2);
legend([p1,p2,p3,p4],'original','ar(1)',['low' num2str(n1)],['upp' num2str(n2) ]);

if any(thcrit>th95) thresh=th95; else thresh=thcrit; end
imin=min(find(freq>=b(1,1)));
imax=max(find(freq<=5));
xmaxima=0;
nmaxima=0;
ymaxima=0;

gmax=max([gxx;max1;max2]);

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
    fprintf('"%s" %3d %5d %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f\n',fpe.name,nmaxima,round(1000./freq(xmaxima(a))),...
      gredth(xmaxima(a)),th95(xmaxima(a)),thcrit(xmaxima(a)),gxx(xmaxima(a)),max1(xmaxima(a)),max2(xmaxima(a)));  
     fprintf(fid,'"%s" %3d %5d %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f\n',fpe.name,nmaxima,round(1000./freq(xmaxima(a))),...
      gredth(xmaxima(a)),th95(xmaxima(a)),thcrit(xmaxima(a)),gxx(xmaxima(a)),max1(xmaxima(a)),max2(xmaxima(a)));  
  end
  
else
  fprintf('"%s" %3d %5d %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f\n',fpe.name,[1:8]*0);
  fprintf(fid,'"%s" %3d %5d %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f\n',fpe.name,[1:8]*0);
end

%print(gcf,'-depsc2', [file '.eps']) ;
hold off
%close all
  %pause
end
fclose(fid);

return
