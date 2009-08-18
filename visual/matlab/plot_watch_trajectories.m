function plot_watch_trajectories(varargin)

cl_register_function();

if nargin==0 fignum=1; else fignum=varargin(1); end;

[dirs,files]=get_files;

sces=[1:8];
sces=[9,10,12];
resfilename = '000watch.res';
t_max = 12;
%
%      loading data
%
tsx=findstr(resfilename,'.');
for sce=sces
 % resfilename(tsx)=num2str(sce);
 
 v=sce;
  resfilename2=resfilename;
  ts=findstr(resfilename,'wat');
  %resfilename(ts-1)=int2str(0+mod(v-1,2)*1);
  if v>10 resfilename2(ts-2:ts-1)=int2str(v-1);
  else  resfilename2(ts-1)=int2str(v-1); end
  %if(sce>2)
  % resfilename2=[resfilename(1:tsx-1) '_sync' resfilename(tsx:end)];
  %else
   %  resfilename2=resfilename;
  %end
  fprintf('Loading %s \n',[dirs.result '/' resfilename2]);
  pop(sce,:,:)=load([dirs.result '/' resfilename2]);
  pop(sce,:,1)=t_max-pop(sce,:,1)*0.01;
end;
ts= size(pop,2);

%
%      graph settings and scaling
%
%ThinLineStyles=0;
hold on;
% natfert ,actfert                  //2-3
% product,growthrate,density        //4-6
% technology,ndomesticated,qfarming //7-9 
% npp,rgr ,ndommax                  //10-12
regname=['Krim         ';
         'Anatolia     ';
         'Hungary      ';
         'North Germany';
         '             ';
         '             ';
         '             ';
         '             ';
         'Vietnam      ';
         'E India      ';
         'S China      ';
         'N China      '];
empty= '                               ';
vname=['            FEP                ';empty;empty;empty;
       'Density {\it P} [Ind km^{-2}]  ';
       '   Technology index{\it T}     ';
       'Agricultural economies{\it AAE}';
       'Farming quota {\it Q}          ';empty;empty;empty;empty];
dyt=[0.2 0.2 0.2 0.2 0.2 1.0 1.0 1.0 0.2 0.5 1 1];
sname=[	
	'Natural Productivity  ';%];
	'Population Density    ';
	'Technology            ';
  'Agricultural diversity';
  'Farming quota         ';];
maxy=[1.1,5.2,9.0,8.0,1.0];

pind=[2 6 7 8 9];
%subfind=['a';'b';'a';'b']
%
%       preparing Y Axis Marks at maxima
%
col='grcbckymgrcbckym';
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
      gca=axes('Position',[0.1 -0.01+0.25*(4-1)+(4==1)*0.08 0.9 0.25-(4==1)*0.08]);
   else
     gca=axes('Position',[0.1 -0.01+0.25*(n-1)+(n==1)*0.08 0.9 0.25-(n==1)*0.08]);
   end
   set(gca,'XLim',[2.5 t_max],'FontSize',16);

   hold on;
   set(gca,'FontName','Arial','XDir','reverse','Box','on');
   ylabel(vname(j-1,:),'FontName','Arial','FontSize',16);%,'VerticalAlignment','bottom','Alignment','bottom'
%   maxy=0.5*dyt(j)*ceil(max(pop(1,:,j))*2.2/dyt(j)+3-n);
%   miny=0.5*dyt(j)*ceil(min(pop(1,:,j))*1.8/dyt(j)-0.8);
   if(n==1) miny=0.2; else miny=0; end;
   ylim([miny maxy(n)]);
   set(gca,'YTick',miny:2*dyt(j):maxy(n)-(2-1*n)*dyt(j));

   if n==2
    for v=sces
    %text(11.75-1.2*(v-1),maxy(2)*0.4,regname(v,:),'Color',col(v),'FontSize',15);
    text(11.75-1.2*(v-9),maxy(2)*0.4,regname(v,:),'Color',col(v),'FontSize',15);
    end
   end 
   
   if n==2
     xlabel('Time (kyr BP)','FontName','Arial','FontSize',16);
   else
     set(gca,'XTickLabel',[])
 %  set(gca(n),'XTickLabel',{''})
   end;
  for v=sces
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

 
% 
 hold off;
 drawnow;

 plot_multi_format(gcf,[dirs.plot '/watch_trajectories'])

return;
%EOF
