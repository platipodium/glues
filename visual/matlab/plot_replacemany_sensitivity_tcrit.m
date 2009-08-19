function plot_replacemany_sensitivity_tcrit

cl_register_function();

figure(1);
clf reset;

file='replacemany_sensitivity_tcrit.tsv';

d=load(file,'-ascii');

time=d(:,1);
count=d(:,7);

valid=find(count>10);


%Hier steheln also #peaks in % der records
%1.  total 2. inside (lower), 3. outside (upper),  4. in-not-tot 5. out-not-tot 6. in-gt-out 7. out-gt-in


plot(d(valid,1),d(valid,2)./d(valid,2),'k-');
hold on;
plot(d(valid,1),d(valid,3)./d(valid,2),'g-');
plot(d(valid,1),d(valid,4)./d(valid,2),'m-');

legend('Total','Lower/Inside','Upper/Outside');

%plot(d(valid,1),d(valid,5)./d(valid,2),'r-','Linewidth',2);
%plot(d(valid,1),d(valid,6)./d(valid,2),'b-','LineWidth',2);
%plot(d(valid,1),0.1*(d(valid,6)+d(valid,5))./d(valid,2),'r--','LineWidth',4);
%hold on;
%plot(d(valid,1),(d(valid,8)+d(valid,9))./d(valid,2),'b--','LineWidth',4);
%plot(d(valid,1),(d(valid,3))./d(valid,2),'m-','LineWidth',4);


%legend('0.1*Peak changes in (in OR out) relative to tot','Peak changes (in XOR out)','# of peak changes (in window)');
ylabel('Relative number of sig-peaks  (%)');
xlabel('Mid-point of 4 ka window  (ka BP)');
title('Importance of 4 ka windows during Holocene');

plot_multi_format(1,'replacemany_sensitivity_tcrit');


end
