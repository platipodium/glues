% File plot_region_numbers
% Author Carsten Lemmen <carsten.lemmen@gkss.de>
%
% based on show_map.m by Kai Wirtz
%--------------------------------------------------

cl_register_function();

[directory,file]=get_files;
[regionvector,regionlength]=get_regionvector(directory.setup);

cols=720;
rows=360;
figure(1);
set(gcf,'Position',[50 50 2*cols 2*ceil(rows*0.9)]);

offs0=0;
n=offs0+length(regionlength);

map = zeros(rows*cols,1)+n;

 for i=1+offs0:n  %n-1 last region combines islands
    map(regionvector(i,1:regionlength(i)))=1+i;
 end;
 map = reshape(map,cols,rows)';

map19=zeros([19 3]);
map19(1:6,1)=1;
map19([2 7:11],2)=1;
map19([3 8 12:15],3)=1;
map19([9 11 14 15 17 18 19],1)=0.5;
map19([5 6 13 15 16 18 19],2)=0.5;
map19([4 6 10 11 16 17 19],3)=0.5;
jetnew=repmat(map19,[n/19+1 1]);
jetnew=jetnew(1:n,:);
 
%%jetnew=prism(n);
jetnew(n,:) = [1 1 1];
jetnew(1,:) = [0 0 0];
colormap(jetnew);

y0=ceil(rows*0.07);
imagesc(map(y0:ceil(rows*0.89),:),[1 n]);
 for i=1+offs0:n
   ad=regionvector(i,1:regionlength(i));
   x=mod(ad,cols);
   y=round((ad-x)./cols)-y0+1;
   hold on;

   %if (abs(mean(x)-360-15) < 120) &&  (abs(mean(y)-70)<40)
      plot(mean(x)-0.5,mean(y)+0.5,'k*');
      text(mean(x),mean(y),num2str(i));
   %end;
 end;
 set(gca,'YTick',[],'XTick',[],'Visible','on');

save regionvector_686 regionvector regionlength n rows cols offs0

fname=[directory.plot '/region_numbers_' num2str(n)];

set(gcf,'PaperPositionMode','auto')
fnme=[fname '.eps'];
print('-deps2','-r600',fnme );
fnme=[fname '.png'];
print('-dpng',fnme );
%fnme=[fname '.fig']
%print(fnme);

