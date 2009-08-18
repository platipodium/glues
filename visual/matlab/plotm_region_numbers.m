% File plot_region_numbers
% Author Carsten Lemmen <carsten.lemmen@gkss.de>
%
% based on show_map.m by Kai Wirtz
%--------------------------------------------------

cl_register_function();

function plotm_region_numbers(varargin)

if nargin==0 fignum=1; else fignum=varargin{1}; end;

  [directory,file]=get_files;
  [regionvector,regionlength]=get_regionvector(directory.setup);

  cols=720;
  rows=360;
  figure(fignum);
  clf;
  
  %set(gcf,'Position',[50 50 2*cols 2*rows]);
  m_proj('miller cylindrical','lat',[-66,83],'lon',[-150,178]);
  m_coast('patch',[.7 .7 .7],'edgecolor','none');

 %[X,Y]=m_ll2xy(-129,48.5);
 
  n=length(regionlength);
  jetnew=get_jetnew(n)
  ;colormap(jetnew);
  map  = zeros(rows*cols,1)+n;

  %n-1 last region combines islands
  for i=1:n 
     cells=regionvector(i,1:regionlength(i));
     map(cells)=1+i; 
     lats = 90.-round((cells-1)./cols)/(rows/180.);
     lons = mod(cells,cols)/(cols/360)-180.;
     m_patch(lons,lats,jetnew(i,:));
  end;
  map = reshape(map,cols,rows)';
  
  
 y0=ceil(rows*0.07);
 imagesc(map(y0:ceil(rows*0.89),:),[1 n]);
 for i=1:n
   ad=regionvector(i,1:regionlength(i));
   x=mod(ad,cols);
   y=round((ad-x)./cols)-y0+1;
   hold on;

   %if (abs(mean(x)-360-15) < 120) &&  (abs(mean(y)-70)<40)
      plot(mean(x)-0.5,mean(y)+0.5,'k*');
      text(mean(x),mean(y),num2str(i));
   %end;
 end;
 return;
 set(gca,'YTick',[],'XTick',[],'Visible','on');

 fname=[directory.plot '/region_numbers_' num2str(n)];

 plot_multi_format(gcf,fname);
 
return;

%fnme=[fname '.fig']
%print(fnme);

