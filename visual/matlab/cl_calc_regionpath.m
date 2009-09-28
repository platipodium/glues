function cl_calc_regionpath

cl_register_function();

%dir='/h/lemmen/projects/glues/glues/glues/examples/setup/686';
%map=fullfile(dir,'mapping_80_686.mat');

% Need mapping file enriched with sea information by calc_seas.m
map='regionmap_sea_685.mat';
%map='regionmap.mat';

if ~exist(map,'file')
  fprintf('Please create file regionmap_sea_XXX.mat first by running cl_calc_seas\n');
  return
end

%map='$HOME/projects/glues/glues/glues/setup/mapping_80_686.mat'

load(map);

[cols,rows]=size(map.region);

lat=land.lat;
lon=land.lon;

nland=length(land.map);
nreg=length(region.length);
border=zeros(nland,4);

region.path=zeros(nreg,400,3)-NaN;
region.neighbourhood=zeros(nreg,100)-NaN;

for iland=1:nland
  me=land.region(iland);
  [ilon,ilat]=regidx2geoidx(land.map(iland),cols);
  if (map.region(ilon,ilat) ~= me) 
    fprintf('%f %f\n',map.region(ilon,ilat),me); 
   error('Map and region information do not match');
  end

  ilonl=mod(ilon+720-2,720)+1;
  ilonr=mod(ilon,720)+1;%plot_path('file','regionpath_686','var','id');
%plot_path('file','regionpath_686','var','neighbours');

%plot_path('file','regionpath_938','var','id');
%plot_path('file','regionpath_938','var','neighbours');
%plot_path('file','regionpath_938','var','area');


  border(iland,:)=[map.region(ilonl,ilat) ~= me,map.region(ilon,ilat-1) ~= me,...
                   map.region(ilonr,ilat) ~= me,map.region(ilon,ilat+1) ~= me];
end

% border is size (nland,4)
nborder=sum(border,2);
iborder=find(nborder > 0);
nborderland=length(iborder);

debug=0;
 
latgrid=map.latgrid;
longrid=map.longrid;

if debug>2
 
  for ireg=1:nreg
    me=ireg;
  
    % select all cells of this region
    iselect=find(land.region == ireg);
    nselect=length(iselect);
    if nselect<1 error('Region with zero grid cells'); end

    [ilon,ilat]=regidx2geoidx(land.map(iselect),cols);
      latmin=max([-90,min(latgrid(ilat))-1]);
  latmax=min([ 90,max(latgrid(ilat))+1]);
  lonmin=max([-180,min(longrid(ilon))-2]);
  lonmax=min([ 180,max(longrid(ilon))+2]);


  figure(1); clf reset;
  title=sprintf('Regions');
  m_proj('miller','lat',[latmin latmax],'lon',[lonmin, lonmax]);
  m_coast('line','color','k');
  m_grid;
  hold on;
    m_line(map.longrid(ilon),map.latgrid(ilat),'color','y','Linestyle','none','marker','.');
    m_line(land.lon(iselect),land.lat(iselect),'color','b','Linestyle','none','marker','o');
    m_plot(region.center(ireg,1),region.center(ireg,2),'k*');
    m_plot(region.lon(ireg),region.lat(ireg),'ro');
  end
end

for ireg=1:nreg %:nreg 
%    for ireg=5:5
  me=ireg;  
  % select all cells of this region
  iselect=find(land.region == ireg);
  nselect=length(iselect);
  if nselect<1 
     fprintf('Something is wrong here, no cells with region id %d\n',me);
     continue; 
  end

  [ilon,ilat]=regidx2geoidx(land.map(iselect),cols);
 % if (nreg==685 || nreg==686) ilat=361-ilat; end
  
  %ilat=ilat-2;
  %ilon=ilon+1;
  latmin=max([-90,min(latgrid(ilat))-1]);
  latmax=min([ 90,max(latgrid(ilat))+1]);
  lonmin=max([-180,min(longrid(ilon))-2]);
  lonmax=min([ 180,max(longrid(ilon))+2]);

  region.area(ireg)=sum(calc_gridcell_area(latgrid(ilat)));

    
  if debug>0
    figure(1); clf reset;
    title=sprintf('Region %d',ireg);
    m_proj('Miller','lon',[lonmin lonmax],'lat',[latmin latmax]);
    m_coast('line','color','k');
    m_grid;
    m_line(longrid(ilon),latgrid(ilat),'color','y','Linestyle','none','marker','.');
    hold on;
    m_plot(region.center(ireg,1),region.center(ireg,2),'ks');
    
    ilon=find(longrid>lonmin & longrid<lonmax);
    ilat=find(latgrid>latmin & latgrid<latmax);
    nla=length(ilat);
    nlo=length(ilon);
    lo=repmat(longrid(ilon)',1,nla);
    la=repmat(latgrid(ilat),nlo,1);
   % if (nreg==685 || nreg==686) ilat=361-ilat; end
    m_text(reshape(lo,nlo*nla,1),reshape(la,nlo*nla,1),...
        num2str(reshape(map.region(ilon,ilat),nlo*nla,1)),...
        'VerticalAlignment','middle','HorizontalAlignment','center','FontSize',6);
    
  end


  % select all border cells of this region
  iselect=find(land.region == ireg & nborder > 0 &  nborder < 5);
  nselect=length(iselect);
  if nselect<1 
      fprintf('Something is wrong here, no border cells with region id %d\n',me);
     continue;  
  end

  [ilon,ilat]=regidx2geoidx(land.map(iselect),cols);
%  if (nreg==685 || nreg==686) ilat=361-ilat;  end
  latmin=max([-90,min(latgrid(ilat))-1]);
  latmax=min([ 90,max(latgrid(ilat))+1]);
  lonmin=max([-180,min(longrid(ilon))-2]);
  lonmax=min([ 180,max(longrid(ilon))+2]);
    
  if debug>0
      m_line(longrid(ilon),latgrid(ilat),'color','b','Linestyle','none','marker','.');
  end
  % calculate neighbourhood to the left,top,right, and bottom 
  neighbours=[];
  ileft=find(land.region == ireg & nborder > 0 &  border(:,1) );
  if ~isempty(ileft) 
    [ilon,ilat]=regidx2geoidx(land.map(ileft),cols);
    %if (nreg==685 || nreg==686) ilat=361-ilat; end
    ilonl=mod(ilon+cols-2,cols)+1;
    neighbours=[neighbours;diag(map.region(ilonl,ilat))];
    if debug>0
        %m_line(longrid(ilon),latgrid(ilat),'color','r','marker','.','linestyle','none');
        %m_line(longrid(ilonl),latgrid(ilat),'color','g','marker','o','linestyle','none');
        m_text(longrid(ilonl),latgrid(ilat),num2str(diag(map.region(ilonl,ilat))),...
            'color','r','HorizontalAlignment','right','FontSize',6);
   end
  end
    
  itop=find(land.region == ireg & nborder > 0 &  border(:,2) );
  if ~isempty(itop) 
    [ilon,ilat]=regidx2geoidx(land.map(itop),cols);
    ilatu=ilat-1;
   % if (nreg==685 || nreg==686) ilatu=361-ilatu; end
    neighbours=[neighbours;diag(map.region(ilon,ilatu))];
     if debug>0
        m_text(longrid(ilon),latgrid(ilatu),num2str(diag(map.region(ilon,ilatu))),...
          'color','r','VerticalAlignment','bottom','FontSize',6);
   end
 end
    
  iright=find(land.region == ireg & nborder > 0 &  border(:,3) );
  if ~isempty(iright)
    [ilon,ilat]=regidx2geoidx(land.map(iright),cols);
    % if (nreg==685 || nreg==686) ilat=361-ilat; end
   ilonr=mod(ilon,720)+1;
    neighbours=[neighbours;diag(map.region(ilonr,ilat))];
    
       if debug>0
        m_text(longrid(ilonr),latgrid(ilat),num2str(diag(map.region(ilonr,ilat))),...
          'color','r','HorizontalAlignment','left','FontSize',6);
   end
  
    
  end

  ibot=find(land.region == ireg & nborder > 0 &  border(:,4) );
  if ~isempty(ibot)
    [ilon,ilat]=regidx2geoidx(land.map(ibot),cols);
    ilatu=ilat+1;
   % if (nreg==685 || nreg==686) ilatu=361-ilatu; end
    neighbours=[neighbours;diag(map.region(ilon,ilatu))];
      if debug>0
        m_text(longrid(ilon),latgrid(ilatu),num2str(diag(map.region(ilon,ilatu))),...
          'color','r','VerticalAlignment','top','FontSize',6);
   end
 end
  
  neighbours=unique(neighbours);
  neighbours=neighbours(find(neighbours ~= me));
  region.neighbours(ireg)=length(neighbours);
  region.neighbourhood(ireg,1:region.neighbours(ireg))=neighbours';
  
  % calculate outline
  npath=sum(sum(border(iselect,:)));
  path=zeros(npath+1,3)+NaN;

  isel=1;
  ipath=1; 
  idir=0;

  while(sum(sum(border(iselect,:))) > 0)
    %fprintf('%d\n',sum(sum(border(iselect,:))));
    [ilon,ilat]=regidx2geoidx(land.map(iselect(isel)),cols);
    [ilonl,ilatu,ilonr,ilatb]=geoidx2geoneighbour(ilon,ilat,cols);
    
    latc=min(latgrid(ilat));
    latu=min(latgrid(ilatu));
    latl=min(latgrid(ilatb));
    lonc=min(longrid(ilon));
    lonl=min(longrid(ilonl));
    lonr=min(longrid(ilonr));

    %[dummy,isort]=sort(mod([0:3]+idir,4)+1);
    isort=mod([0:3]+idir,4)+1;
    ibord=find((border(iselect(isel),isort)));
    if isempty(ibord) break; end
    ibord=ibord(1);
    switch isort(ibord)
      case 1
        path(ipath,:)=[lonc-0.25,latc,map.region(ilonl,ilat)];
        if (map.region(ilonl,ilat-1) == me) idir=3; ineigh=1;
        elseif (map.region(ilon,ilat-1) == me) idir=0; ineigh=2;
        else ineigh=8; idir=1; end
        
      case 2
        path(ipath,:)=[lonc,latc+0.25,map.region(ilon,ilat-1)];
        if (map.region(ilonr,ilat-1) == me) idir=0; ineigh=3; 
        elseif (map.region(ilonr,ilat) == me) idir=1; ineigh=4; 
        else idir=2; ineigh=8; end
      case 3
        path(ipath,:)=[lonc+0.25,latc,map.region(ilonr,ilat)];
        if (map.region(ilonr,ilat+1) == me) idir=1; ineigh=5;
        elseif (map.region(ilon,ilat+1) == me) idir=2; ineigh=6; 
        else idir=3; ineigh=8; end
      case 4
        path(ipath,:)=[lonc,latc-0.25,map.region(ilon,ilat+1)];
        if (map.region(ilonl,ilat+1) == me) idir=2; ineigh=7; 
        elseif (map.region(ilonl,ilat) == me)  idir=3; ineigh=0; 
        else  idir=0; ineigh=8; end
    end
 if debug>0
    m_line(path(1:ipath,1),path(1:ipath,2),'color','r','marker','.');
 end
    ipath=ipath+1;
    border(iselect(isel),isort(ibord))=0;
    fprintf('%d %d %f=%f %f?%f?\n',isel,ineigh,latc,lat(iselect(isel)),lonc,lon(iselect(isel)));
     

     switch ineigh 
       case 0, isel=find(lat(iselect) == latc & lon(iselect) == lonl);
       case 1, isel=find(lat(iselect) == latu & lon(iselect) == lonl);
       case 2, isel=find(lat(iselect) == latu & lon(iselect) == lonc);
       case 3, isel=find(lat(iselect) == latu & lon(iselect) == lonr);
       case 4, isel=find(lat(iselect) == latc & lon(iselect) == lonr);
       case 5, isel=find(lat(iselect) == latl & lon(iselect) == lonr);
       case 6, isel=find(lat(iselect) == latl & lon(iselect) == lonc);
       case 7, isel=find(lat(iselect) == latl & lon(iselect) == lonl);
       case 8, isel=isel ; find(lat(iselect) == latc & lon(iselect) == lonc);
      end
     
   
   
    %if isempty(isel)
     %  fprintf('%d %f=%f %f?%f?\n',isel,latc,lat(iselect(isel)),lonc,lon(iselect(isel)));
       %end
  end
  
  %fprintf('%d %d\n',npath,ipath);

  path(ipath,:)=path(1,:);
  %m_line(path(1:ipath,1),path(1:ipath,2),'color','b');
  region.path(ireg,1:ipath,1)=path(1:ipath,1);
  region.path(ireg,1:ipath,2)=path(1:ipath,2);
  region.path(ireg,1:ipath,3)=path(1:ipath,3);

  %Consistency check
  
  upath=unique(region.path(ireg,1:ipath,3));
  uneigh=region.neighbourhood(ireg,1:region.neighbours(ireg));
  if (length(upath)==length(npath)) ;
  else
      warning('Inconsitency in path and neighbours for region %d',ireg);
  end
  
end

%regioncenter=zeros(nreg,2)-NaN;
%for ireg=1:nreg
%  iselect=find(regionnumber == ireg);
%  regioncenter(ireg,:)=[mean(lat(iselect)),mean(lon(iselect))];
%end

longest_path=max(find(isfinite(min(region.path(:,:,1)))));
most_neighbours=max(find(isfinite(min(region.neighbourhood(:,:)))));
region.path=region.path(:,[1:longest_path],:);
region.neighbourhood=region.neighbourhood(:,[1:most_neighbours]);

% regionneighbours: number of neighbours size (nreg,1)
% regioncenter:     lat lon of central point (nreg,2)
% regionpath:       lat lon neighid of path (nreg,maxpathlength,3)    

regionpathfile=sprintf('regionpath_%d.mat',nreg);

region.nreg=nreg;

save('-v6',regionpathfile,'region','map');

return;
