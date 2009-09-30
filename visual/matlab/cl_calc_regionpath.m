function cl_calc_regionpath

cl_register_function();

%dir='/h/lemmen/projects/glues/glues/glues/examples/setup/686';
%map=fullfile(dir,'mapping_80_686.mat');

% Need mapping file enriched with sea information by calc_seas.m
mapfile='regionmap_sea_1439.mat';
%map='regionmap.mat';

if ~exist(mapfile,'file')
  fprintf('Please create file regionmap_sea_XXX.mat first by running cl_calc_seas\n');
  return
end

%map='$HOME/projects/glues/glues/glues/setup/mapping_80_686.mat'

load(mapfile);

[cols,rows]=size(map.region);

lat=land.lat;
lon=land.lon;

nland=length(land.map);
nreg=length(region.length);

region.path=zeros(nreg,400,3)-NaN;
region.neighbourhood=zeros(nreg,100)-NaN;

[land.ilon,land.ilat]=regidx2geoidx(land.map,cols);
% Sanity check for ilon/ilat
ok=all(map.latgrid(land.ilat)==land.lat')
ok=all(map.longrid(land.ilon)==land.lon')

border=zeros(nland,4);

ilon=land.ilon;
ilat=land.ilat;
ilonl=ilon-1;
ilonl(ilonl==0)=cols;
ilonr=ilon+1;
ilonr(ilonr==cols+1)=1;

nnu=geoidx2regidx(ilon,ilat-1,cols);
nnd=geoidx2regidx(ilon,ilat+1,cols);
nnl=geoidx2regidx(ilonl,ilat,cols);
nnr=geoidx2regidx(ilonr,ilat,cols);
nni=geoidx2regidx(ilon,ilat,cols);

ok=all(map.region(nni)==land.region)

border=[map.region(nnl)~=land.region, map.region(nnu)~=land.region, ...
  map.region(nnr)~=land.region, map.region(nnd)~=land.region];

% border is size (nland,4)
nborder=sum(border,2);
iborder=find(nborder > 0);
nborderland=length(iborder);

debug=0;
 
latgrid=map.latgrid;
longrid=map.longrid;

if ~isfield(region,'center')
  region.center=zeros(nreg,2);
  for ireg=1:nreg
    me=ireg;
  
    % select all cells of this region
    iselect=find(land.region == ireg);
    nselect=length(iselect);
    if nselect<1 error('Region with zero grid cells'); end
    if nselect~=region.length(ireg) error('Inconsistency detected'); end

   region.center(ireg,1)=calc_geo_mean(map.latgrid(ilat(iselect)),map.longrid(ilon(iselect)));
   %region.center(ireg,2)=calc_geo_mean(map.latgrid(ilat),map.longrid(ilat));
  region.center(ireg,2)=mean(map.latgrid(ilat(iselect)));

  if debug>2

    colors='rgyb';
    latmin=max([-90,min(latgrid(ilat(iselect)))-1]);
  latmax=min([ 90,max(latgrid(ilat(iselect)))+1]);
  lonmin=max([-180,min(longrid(ilon(iselect)))-2]);
  lonmax=min([ 180,max(longrid(ilon(iselect)))+2]);
  figure(1); clf reset;
  title=sprintf('Regions');
  m_proj('miller','lat',[latmin latmax],'lon',[lonmin, lonmax]);
  m_coast('line','color','k');
  m_grid;
  hold on;
    m_line(land.lon(iselect),land.lat(iselect),'color','b','Linestyle','none','marker','o');
    m_plot(region.center(ireg,1),region.center(ireg,2),'k*');
    for ib=1:4
      is=border(iselect,ib)==1;
      if ~isempty(is)
      m_plot(land.lon(iselect(is)),land.lat(iselect(is)),'y.','color',colors(ib)); end
    end
    %m_line(land.lon(ilon(border(:,1)==1)),land.lat(ilat(border(:,1)==1),'color','y','Linestyle','none','marker','.');
    %m_plot(region.lon(ireg),region.lat(ireg),'ro');
  end
  end
  save(mapfile,'map','land','region');
end

  
for ireg=10:nreg %:nreg 
%    for ireg=400:400
  me=ireg;  
  % select all cells of this region
  iselect=find(land.region == ireg);
  nselect=length(iselect);
  rborder=border(iselect,:);
  if nselect<1 
     fprintf('Something is wrong here, no cells with region id %d\n',me);
     continue; 
  end
  
  latmin=max([-90,min(latgrid(ilat(iselect)))-1]);
  latmax=min([ 90,max(latgrid(ilat(iselect)))+1]);
  lonmin=max([-180,min(longrid(ilon(iselect)))-2]);
  lonmax=min([ 180,max(longrid(ilon(iselect)))+2]);

  region.area(ireg)=sum(calc_gridcell_area(latgrid(ilat(iselect))));

    
  if debug>0
    figure(1); clf reset;
    title=sprintf('Region %d',ireg);
    m_proj('Miller','lon',[lonmin lonmax],'lat',[latmin latmax]);
    m_coast('line','color','k');
    m_grid;
    m_line(lon(iselect),lat(iselect),'color','y','Linestyle','none','marker','.');
    hold on;
    m_plot(region.center(ireg,1),region.center(ireg,2),'ks');
    
    ilo=find(longrid>lonmin & longrid<lonmax);
    ila=find(latgrid>latmin & latgrid<latmax);
    nla=length(ila);
    nlo=length(ilo);
    lo=repmat(longrid(ilo)',1,nla);
    la=repmat(latgrid(ila),nlo,1);
   % if (nreg==685 || nreg==686) ilat=361-ilat; end
    m_text(reshape(lo,nlo*nla,1),reshape(la,nlo*nla,1),...
        num2str(reshape(map.region(ilo,ila),nlo*nla,1)),...
        'VerticalAlignment','middle','HorizontalAlignment','center','FontSize',6);
    
  end


  % select all border cells of this region
  iselect=find(land.region == ireg & nborder > 0);
  rborder=border(iselect,:);
  nselect=length(iselect);
  if nselect<1 
      fprintf('Something is wrong here, no border cells with region id %d\n',me);
     continue;  
  end

    
  if debug>0
      m_line(land.lon(iselect),land.lat(iselect),'color','b','Linestyle','none','marker','.');
  end
  % calculate neighbourhood to the left,top,right, and bottom 
  neighbours=[];
  ileft=find(land.region == ireg &  border(:,1) );
  neighbours=[neighbours; map.region(nnl(ileft))];
  if ~isempty(ileft) & debug 
        m_text(lon(ileft),lat(ileft),num2str(map.region(nnl(ileft))),...
            'color','r','HorizontalAlignment','right','FontSize',6);
  end

  itop=find(land.region == ireg &  border(:,2) );
  neighbours=[neighbours; map.region(nnu(itop))];
  if ~isempty(itop) & debug 
        m_text(lon(itop),lat(itop),num2str(map.region(nnu(itop))),...
            'color','b','VerticalAlignment','bottom','FontSize',6);
  end

  iright=find(land.region == ireg &  border(:,3) );
  neighbours=[neighbours; map.region(nnr(iright))];
  if ~isempty(iright) & debug 
        m_text(lon(iright),lat(iright),num2str(map.region(nnr(iright))),...
            'color','g','HorizontalAlignment','left','FontSize',6);
  end

  ibot=find(land.region == ireg &  border(:,4) );
  neighbours=[neighbours; map.region(nnd(ibot))];
  if ~isempty(ibot) & debug 
        m_text(lon(ibot),lat(ibot),num2str(map.region(nnd(ibot))),...
            'color','m','VerticalAlignment','top','HorizontalAlignment','Center','FontSize',6);
  end

  neighbours=unique(neighbours);
  neighbours=neighbours(find(neighbours ~= me));
  region.neighbours(ireg)=length(neighbours);
  region.neighbourhood(ireg,1:region.neighbours(ireg))=neighbours';
  
  % calculate outline
  npath=sum(sum(border(iselect,:)));
  path=zeros(npath+1,3)+NaN;

  isel=randi(nselect);
  ipath=1; 
  idir=0;
  pathoffset=0;
  while(sum(sum(rborder(:,:))) > 0)
    %fprintf('%d\n',sum(sum(border(iselect,:))));

    iss=iselect(isel);
    latc=lat(iss);
    lonc=lon(iss);
    iloc=ilon(iss);
    ilac=ilat(iss);
    ilol=ilonl(iss);
    ilor=ilonr(iss);
    lonc=map.longrid(iloc);
    lonl=map.longrid(ilol);
    lonr=map.longrid(ilor);
    latc=map.latgrid(ilac);
    latu=map.latgrid(ilac-1);
    latl=map.latgrid(ilac+1);
    
    isort=mod([0:3]+idir,4)+1;
    %ibord=find((border(iselect(isel),isort)));
    ibord=find(rborder(isel,isort));
    if isempty(ibord) 
        % This happens when a region is not contiguous
        path(ipath,:)=path(1+pathoffset,:); % close prior ring
        path(ipath+1,:)=[NaN,NaN,NaN]; % create break in path
        ipath=ipath+2;
        pathoffset=ipath;
        ifsel=find(sum(rborder,2)>0);
        isel=ifsel(randi(length(ifsel)));
        continue;
    end
    ibord=ibord(1);
    switch isort(ibord)
      case 1
        path(ipath,:)=[lonc-0.25,latc,map.region(ilol,ilac)];
        if (map.region(ilol,ilac-1) == me) idir=3; ineigh=1;
        elseif (map.region(iloc,ilac-1) == me) idir=0; ineigh=2;
        else ineigh=8; idir=1; end
        if ipath>1 & path(ipath-1,3)~=path(ipath,3)
           path(ipath+1,:)=path(ipath,:);
           path(ipath,:)=[lonc-0.25,latc-0.25,NaN];
           ipath=ipath+1;
        end
        
      case 2
        path(ipath,:)=[lonc,latc+0.25,map.region(iloc,ilac-1)];
        if (map.region(ilor,ilac-1) == me) idir=0; ineigh=3; 
        elseif (map.region(ilor,ilac) == me) idir=1; ineigh=4; 
        else idir=2; ineigh=8; end
        if ipath>1 & path(ipath-1,3)~=path(ipath,3)
           path(ipath+1,:)=path(ipath,:);
           path(ipath,:)=[lonc-0.25,latc+0.25,NaN];
           ipath=ipath+1;
        end
      case 3
        path(ipath,:)=[lonc+0.25,latc,map.region(ilor,ilac)];
        if (map.region(ilor,ilac+1) == me) idir=1; ineigh=5;
        elseif (map.region(iloc,ilac+1) == me) idir=2; ineigh=6; 
        else idir=3; ineigh=8; end
        if ipath>1 & path(ipath-1,3)~=path(ipath,3)
           path(ipath+1,:)=path(ipath,:);
           path(ipath,:)=[lonc+0.25,latc+0.25,NaN];
           ipath=ipath+1;
        end
      case 4
        path(ipath,:)=[lonc,latc-0.25,map.region(iloc,ilac+1)];
        if (map.region(ilol,ilac+1) == me) idir=2; ineigh=7; 
        elseif (map.region(ilol,ilac) == me)  idir=3; ineigh=0; 
        else  idir=0; ineigh=8; end
        if ipath>1 & path(ipath-1,3)~=path(ipath,3)
           path(ipath+1,:)=path(ipath,:);
           path(ipath,:)=[lonc+0.25,latc-0.25,NaN];
           ipath=ipath+1;
        end
    end
 if debug>0
    m_line(path(1:ipath,1),path(1:ipath,2),'color','r','marker','.');
 end
    ipath=ipath+1;
    %border(iselect(isel),isort(ibord))=0;
    rborder(isel,isort(ibord))=0;
    if debug fprintf('%d %d %f=%f %f=%f\n',isel,ineigh,latc,lat(iselect(isel)),lonc,lon(iselect(isel)));
    end

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

  path(ipath,:)=path(1+pathoffset,:);
  %m_line(path(1:ipath,1),path(1:ipath,2),'color','b');
  region.path(ireg,1:ipath,1)=path(1:ipath,1);
  region.path(ireg,1:ipath,2)=path(1:ipath,2);
  region.path(ireg,1:ipath,3)=path(1:ipath,3);
  if debug m_plot(region.path(ireg,:,1),region.path(ireg,:,2),'m-'); end
  %Consistency check
  
  upath=unique(region.path(ireg,1:ipath,3));
  upath=upath(isfinite(upath));
  uneigh=region.neighbourhood(ireg,1:region.neighbours(ireg));
  if (length(upath)~=length(uneigh)) 
      warning('Inconsistency in path and neighbours for region %d',ireg);
  end
  
  
  if mod(ireg,20)==0 fprintf('.'); end
  
  
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
