function plot_leavemanyout

cl_register_function();

file='sajama.dat_var.tsv';

%if ~exist(file,'file') return

[fpe.path fpe.name fpe.ext fpe.version]=fileparts(file);

data=load(file,'-ascii');

p=data(6:end,1);
nrat=data(1,2);
nout=length(data(1,3:end));
nvar=length(p);

odd=[1:2:nvar];
even=odd+1;
nvar=nvar/2;

freq=data(1,3:end);
gxx=db(data(2,3:end));
gredth=db(data(3,3:end));
th95=db(data(4,3:end));
thcrit=db(data(5,3:end));


f=data(odd+5,3:end);
d=data(even+5,3:end);

gxxv=zeros(nvar,nout);

figure;
clf reset;
plot(freq,gxx);

xlim=[1/2. 1000/200.];

%set(gca,'YLim',[0 50]);
set(gca,'XLim',xlim)
valid=find(freq>=xlim(1) & freq<=xlim(2));
xtickv=get(gca,'XTick');
xticklabel=round(1000./xtickv);
set(gca,'XTickLabel',xticklabel);
xlabel('Recurrence time (yr)')
ylabel('Spectral intensity (dB)');
title([fpe.name ' (r=' num2str(nrat(1)) '%)']);
hold on

for i=1:nvar
    positive=find(d(i,:)>0);
    gxxv(i,:)=interp1(f(i,positive),db(d(i,positive)),freq);
    %if (p(i)==1) plot(f(i,:),d(i,:),'Color','r');
    %else  plot(f(i,:),d(i,:),'Color','g');
    % end 
end 

for i=1:-nvar
    positive=find(d(i,:)>0);
    plot(freq,gxxv(i,:),'Color','m');
    if (p(i)==1) plot(f(i,positive),db(d(i,positive)),'Color','r');
    else  plot(f(i,positive),db(d(i,positive)),'Color','g');
    end 
end      
    
    

p1=plot(freq,gxx,'b','Linewidth',2);
p2=plot(freq,gredth,'k','LineWidth',3);
plot(freq,th95,'k');
plot(freq,thcrit,'k','LineWidth',3);

max1=mean(gxxv(find(p(odd)==1),:));
max2=mean(gxxv(find(p(odd)==2),:));
n1=sum(p(odd)==1);
n2=sum(p(odd)==2);

p3=plot(freq,max1,'r','LineWidth',2);
p4=plot(freq,max2,'g','LineWidth',2);
legend([p1,p2,p3,p4],'original','ar(1)',['low ' num2str(n1)],['upp ' num2str(n2) ]);
hold off

end
