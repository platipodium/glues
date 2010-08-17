function clp_discharge


time=[3:16]; % Days in April 2010
sukkur=[NaN,NaN,NaN,600710,871682,1075233,1130000,1130995,1130995,1113218,1083660,1010327,1008377,1021220]; %Discharge in CuSec

figure(1);
clf reset;

plot(time,sukkur,'r-','LineWidth',3);
set(gca,'XLim',[-1,17],'YLim',[500000,1250000]);
ylabel('River flow (m^3 s^{-1})');
xlabel('Days in August');
title('Indus river discharge at Sukkur (Sindh)');
text(8,800000,'2010','Color','r','FontSize',15);

hold on;

%Prior flood events from http://www.pakmet.com.pk/FFD/index_files/hpeak.htm
plot(15,1166574,'bh','MarkerSize',10);
text(14,1130000,'1986','Color','b','FontSize',15);
plot(14,1161000,'gh','MarkerSize',10);
text(13,1210000,'1976','Color','g','FontSize',15);
plot(0,1118856,'mh','MarkerSize',10);
text(1,1118856,'1988','Color','m','FontSize',15);

plot_multi_format(1,'indus_discharge');

figure(2);
clf reset;
clp_varves('timelim',[1970,2010],'lim',[0.8,1.4]);
hold on;
text(1985.8,1.35,'1986','Color','b','FontSize',15,'HorizontalAlignment','center');
text(1976,1.38,'1976','Color','g','FontSize',15,'HorizontalAlignment','center');
text(1988.2,1.35,'1988','Color','r','FontSize',15,'HorizontalAlignment','center');

plot(1970:1986,repmat(1.0097,17,1),'k--'); text(1987,1.0097,'5000 a mean');
plot(1978:1986,repmat(0.9298,9,1),'k:'); text(1987,0.93,'500 a mean');
plot(1982:1986,repmat(0.9124,5,1),'k-.');text(1987,0.91,'50 a mean');

plot_multi_format(1,'indus_varves_20');

%1.0097 5000 a mean
%0.0.9298 500 a mean
%0.9142 50 a mean


