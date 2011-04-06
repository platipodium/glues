function plot_regionfluctuation()

cl_register_function();

lw=3;
white=[1.0 1.0 1.0];
yline=[0.88 0.89];

% get regionfluc and time variables
load('regionfluc');
nr=size(regionfluc);
nt=nr(1);
nr=nr(2);
localsum=sum(regionfluc)/nt;
timesum=sum(regionfluc,2)/nr;
globalsum=sum(localsum)/nr;

figure(2);
clf reset;
hold on;
p1=plot(time,timesum,'LineWidth',lw);

ir=find_region_numbers('lbk');
p2=plot(time,sum(regionfluc(:,ir),2)/length(ir),'r-','LineWidth',lw);
legend([p1,p2],'Global mean','Europe mean');

reg=[272,254,236,199,147,123];
nreg=length(reg);

%p3=plot(time,regionfluc(:,272),'k-','LineWidth',lw*0.7,'color',0.8*white);

for ir=1:nreg
  itime=find(regionfluc(:,reg(ir))<0.601);
  ntime=length(itime);
  %pr(ir)=plot(time(itime),itime*0+0.8,'k.','color',(0.8-ir/10.)*white);
  for j=1:ntime
    pr(ir)=plot(repmat(time(itime(j)),2,1),yline-ir/200.,'k-','color',(0.2+ir/10.)*white,'LineWidth',lw/1.3);
  end    

end
legend([p1,p2,pr],'Global','Europe','Lebanon','W Anatolia','N Greece',...
   'Croatia','Slovakia','N Germany','location','southeast');
%legend([p1,p2],'Global','Europe','Location','northeast');

lg=repmat(0.5,1,3);
set(gca,'XDir','reverse','Xlim',[3000 11000]);
yticklabel=get(gca,'Yticklabel');
yticklabel([1,2],:)=repmat(' ',2,size(yticklabel(1,:)));
yticklabel(2,1:3)='min';
set(gca,'YTickLabel',yticklabel,'Xcolor',lg,'ycolor',lg,'color','none');

%title('Mean imposed climate fluctuation and timing of local minima')
xlabel('Time (yr BP)','color',lg);
ylabel('Fluctuation factor','color',lg);
hold off;

plot_multi_format(gcf,'../plots/regionfluctuation');

return
end
