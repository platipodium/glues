function plot_npp_lieth

cl_register_function();

temp=[-30:2:40];
prec=[0:20:2500];
ntemp=length(temp);
nprec=length(prec);

[npp,npp1,npp2,lp,lt]=vecode_npp_lieth(temp,0*temp);
npptemp=npp2;
[npp,npp1,npp2,lp,lt]=vecode_npp_lieth(0*prec,prec);
nppprec=npp1;

figure(1);
clf reset;

plot(temp,npptemp,'r-','LineWidth',3);
xlabel('Mean annual temperature (°C)')
ylabel('Annual NPP (g/m2)');
hold on;
set(gca,'Ylim',[0,1400],'box','off');
legend('Temperature');

axes
plot(prec,nppprec,'b-','LineWidth',3);
set(gca,'Color','none','YLim',[0,1400],'XAxisLocation','top','box','off');
set(gca,'YaxisLocation','right');
xlabel('Annual precipitation (mm)')

legend('Precipitation','Location','NorthWest');
plot_multi_format(gcf,fullfile('../plots','npp_lieth_lineplot'));

figure(2);
clf reset;

tgrid=repmat(temp,nprec,1);
pgrid=repmat(prec,ntemp,1)';

[npp,npp1,npp2,lp,lt]=vecode_npp_lieth(tgrid,pgrid);
pcolor(temp,prec,npp);
hold on;
xlabel('Mean annual temperature (°C)');
ylabel('Annual precipitation (mm)');
cmap=colormap(rainbow);
colorbar;

ic=find(abs(npp1-npp2)<10);
[b,i,j]=unique(tgrid(ic));
ic=ic(i);
tc=temp;
pc=interp1(tgrid(ic),pgrid(ic),tc,'spline');

plot(tc,pc,'w-','LineWidth',2);
plot_multi_format(gcf,fullfile('../plots','npp_lieth_mesh'));

return
end
