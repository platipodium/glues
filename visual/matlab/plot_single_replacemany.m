function plot_single_replacemany(inmask,varargin)

cl_register_function();

% Default values
lw=1.5;
fs=16; no_title=0; no_xticks=0; i=1; no_arrow=0; no_yticks=0;
no_legend=0;
lstyles=['k-.';'r--';'b-.';'b--'];
mstyles=['ko';'ro';'bo';'bo'];
no_shade=0;

if (nargin>1)
  for iargin=1:nargin-1
    if strcmp(varargin{iargin},'NoTitle') no_title=1; end;
    if strcmp(varargin{iargin},'NoXTicks') no_xticks=1; end;
    if strcmp(varargin{iargin},'NoYTicks') no_yticks=1; end;
    if strcmp(varargin{iargin},'NoLegend') no_legend=1; end;
    if strcmp(varargin{iargin},'NoShade') no_shade=1; end;
    if strcmp(varargin{iargin},'Extra') 
       extra=varargin{iargin+1}; iargin=iargin+1; end;
    if strcmp(varargin{iargin},'YLim') 
       ylimit=varargin{iargin+1}; iargin=iargin+1; end;

  end;
end;  

if ~exist('inmask','var') inmask='sunspot*'; end

inmask=strrep(inmask,'.dat','*');

if ~exist('description','var')
     description='';
 end    

ratio=33;
year=5.5;
dyear=0.5;
%extra='detrended';

yrtext=sprintf('%.1f_%.1f',year,dyear);
if exist('extra','var') 
    yrtext=[yrtext '_' extra]; end
 
mask=horzcat(char(inmask),'condensed.tsv');

[d,f]=get_files;

fdir=fullfile(d.proxies,['redfit/data/output/repl_' yrtext ]);
files=dir(fullfile(fdir , mask));
if length(files)==0
    warning('No file found for %s',fullfile(fdir,mask));
    return; 
end
file=fullfile(fdir,files(1).name);


if ~exist(file,'file') 
    return; end

[fpe.path fpe.name fpe.ext fpe.version]=fileparts(file);

data=load(file,'-ascii');

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

plot(freq,gxx);
hold on;

if ~exist('ylimit','var')
  ylim=get(gca,'YLim');
else
  ylim=ylimit;
  set(gca,'Ylim',ylim);
end

by=reshape(repmat(ylim+[2,-2],2,1),1,4);
if ~no_shade
 for i=1:3 fill([b(i,:) fliplr(b(i,:))],by,[0.99 0.99 0.8],'EdgeColor','none'); end 
else
 for i=1:6 plot(repmat(b(i),2,1),ylim,'k:','color',[0.5 0.5 0.5]); end 
end

xlim=[1000/2000. 1000/190.];
set(gca,'XLim',xlim)
valid=find(freq>=xlim(1) & freq<=xlim(2));
xtickv=get(gca,'XTick');
xticklabel=round(1000./xtickv);
if no_xticks 
    set(gca,'XTickLabel',[]);
else
     set(gca,'XTickLabel',xticklabel);
     xlabel('Periodicity (yr)')
end

if no_yticks
    set(gca,'YTickLabel',[]);
else
yticklabel=get(gca,'YTickLabel');
yticklabel(1,:)  =repmat(' ',1,length(yticklabel(1,:)));
yticklabel(end,:)=repmat(' ',1,length(yticklabel(end,:)));
set(gca,'YTickLabel',yticklabel);
ylabel('Spectral intensity (dB)');
end


%title([fpe.name ' (Replace ' description ' ' num2str(nrat) '%)']);

for i=1:-nvar
    if (p(i)==1) plot(freq,d(i,:),'Color','r');
    else  plot(freq,d(i,:),'Color','g');
    end 
end 

p1=plot(freq,gxx,'b','Linewidth',lw);
%p2=plot(freq,gredth,'k','LineWidth',lw);
p2=plot(freq,min([th95;thcrit]),'k','LineWidth',lw,'Color',[0.5 0.5 0.5]);
%plot(freq,thcrit,'k','LineWidth',3);

max1=d(1,:)
max2=d(3,:)

p3=plot(freq,max1,'r','LineWidth',lw);
p4=plot(freq,max2,'g','LineWidth',lw);


if ~no_legend
   %pl=legend([p1,p2,p3,p4],'original','ar(1)',['low' num2str(n1)],['upp' num2str(n2) ],'Location','Best');
   pl=legend([p2,p1,p3,p4],'AR 95%','Total','Lower','Upper','Location','NorthEast');

end

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
    plot([freq(xmaxima(a)),freq(xmaxima(a))],[ylim(1),ymaxima(a)],'k-.','Linewidth',lw);
    end
  
end

return
