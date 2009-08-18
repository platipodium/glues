function plot_region_trajectories(varargin)

cl_register_function();

clear all
if nargin==0 fignum=1; else fignum=varargin(1); end;

[dirs,files]=get_files;

iselect=[123,272,411];
names={'N Germany','Fert Crescent','Centr Mexico'};

vselect=[9];
nvar=length(vselect);


nselect=length(iselect);

for i=1:nselect
    ireg=iselect(i);
    filename=sprintf('pop_%04d.tsv',iselect(i)-1);
    pop(i,:,:)=load(fullfile(dirs.result,filename));
end

hold on;
% natfert ,actfert                  //2-3
% product,growthrate,density        //4-6
% technology,ndomesticated,qfarming //7-9 
% npp,rgr ,ndommax                  //10-12
% tlim 

vnames={'Time','FEP','FEP_a','Subsistence Intensity',...
    'Growth rate','Density {\it P} (Ind km^{-2})',...
    'Technology index{\it T}',...
    'Agricultural diversity {\it AAE}',...
    'Farming quota',...
    'NPP','RGR','PAE','T-limitation'}

dyt=[0.2 0.2 0.2 0.2 0.2 1.0 1.0 1.0 0.2 0.5 1 1];
maxy=[1.1,5.2,9.0,8.0,1.0];
color='grcbckymgrcbckym';


time=11500-pop(1,:,1)*10;

figure(2);
clf reset;hold on;

for iv=1:nvar
for is=1:nselect
  plot(time,pop(is,:,vselect(iv)),'Color',color(is))
  xlabel(vnames{1});
  ylabel(vnames{vselect(iv)});
  set(gca,'XDir','reverse');
end
legend(names{:});
end


return

sty=['o';'s';'d';'^';'o';'s';'d';'^';'o';'s';'d';'^';'o';'s';'d';'^'];
lsty=['- ';'- ';'--';'--';'--';'- ';'- ';'- ';'--';'--';'--';'- ';'- ';'- ';'--';'--';'--';'- ';'- ';'- ';'--';'--';'--';'- '];
dimens=[210 -210 800 1200];
%
%       showing time trajetories at four region
%

 axis off;
 figure(1); clf reset;
 set(gcf,'Position',dimens);
 gcall=axes('Position',[0. 0. 1. 1.1],'Visible','off');

 for n=[2 3 5]
   j=pind(n);
   if n==5 
      %axes('Position',[0.1 -0.01+0.25*(4-1)+(4==1)*0.08 0.9 0.25-(4==1)*0.08]);
   else
     %gca=axes('Position',[0.1 -0.01+0.25*(n-1)+(n==1)*0.08 0.9 0.25-(n==1)*0.08]);
   end
   set(gca,'XLim',[2.5 t_max],'FontSize',16);

   hold on;
   set(gca,'FontName','Arial','XDir','reverse','Box','on');
   ylabel(vnames{j-1},'FontName','Arial','FontSize',16);%,'VerticalAlignment','bottom','Alignment','bottom'
%   maxy=0.5*dyt(j)*ceil(max(pop(1,:,j))*2.2/dyt(j)+3-n);
%   miny=0.5*dyt(j)*ceil(min(pop(1,:,j))*1.8/dyt(j)-0.8);
   if(n==1) miny=0.2; else miny=0; end;
   ylim([miny maxy(n)]);
   set(gca,'YTick',miny:2*dyt(j):maxy(n)-(2-1*n)*dyt(j));

   if n==2
    for v=1:nselect
    %text(11.75-1.2*(v-1),maxy(2)*0.4,regname(v,:),'Color',col(v),'FontSize',15);
    text(11.75-1.2*(v-9),maxy(2)*0.4,names{v},'Color',col(v),'FontSize',15);
    end
   end 
   
   if n==2
     xlabel('Time (kyr BP)','FontName','Arial','FontSize',16);
   else
     set(gca,'XTickLabel',[])
 %  set(gca(n),'XTickLabel',{''})
   end;
  for v=1:nselect
%  for v=3-(n==1)*2:-1:1
    plot(pop(v,:,1),pop(v,:,j),col(v),'LineStyle',lsty(v,:),'LineWidth',2);%,'LineWidth',v*4-2-(v==3)*6
 %   if(n==2 & v==2) legend('Fertile Crescent','Central Andes',2); end;
   end;
 %      if(n==1) legend('Israel','Macedonia',0); end;  
   plot([6 6],[miny maxy(n)],'k:');
   % plot a,b for subfigures
   text(11.75,maxy(n)*0.81-(n==1)*0.25,sname(n,:),'FontSize',22);
 %  line([5 5],[miny maxy],'LineStyle',':');
 % if(n==2) legend('knowledge loss & variable diversity','knowledge loss','base simulation',2); end;
 end;

hold off;
 drawnow;

 plot_multi_format(gcf,fullfile(dirs.plot,'region_trajectories'))

return;
%EOF
