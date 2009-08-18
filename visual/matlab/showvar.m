function plot_replacemany(file,description)

cl_register_function();

if ~exist('file','variable')
    file='sajama_var_40.tsv';
else
    file=['sajama_var_' num2str(file) '.tsv'];
end

if ~exist('description','variable')
     description=''
 end    

%if ~exist(file,'file') return

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
title([fpe.name ' (Replace ' description ' ' num2str(nrat) '%)']);
hold on

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
hold off

end
