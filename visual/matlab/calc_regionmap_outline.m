function calc_regionmap_outline

cl_register_function();

%dir='/h/lemmen/projects/glues/glues/glues/examples/setup/686';
%map=fullfile(dir,'mapping_80_686.mat');

% Need mapping file enriched with sea information by calc_seas.m
map='regionmap.mat';

if ~exist(map,'file')
  fprintf('Please create file regionmap.mat first\n');
  return
end

%map='$HOME/projects/glues/glues/glues/setup/mapping_80_686.mat'

load(map);

rows=360;
cols=720;
lat=lat-1;
lon=lon-0.5;

nland=length(regionindex);
nreg=length(regionlength);
border=zeros(nland,4);

regionpath=zeros(nreg,400,3)-NaN;
regionneighbourhood=zeros(nreg,100)-NaN;
regionneighbours=zeros(nreg);

for iland=1:nland
  me=regionnumber(iland);
  [ilon,ilat]=regidx2geoidx(regionindex(iland),cols);
  %if (latgrid(360-ilat) ~= lat(iland)) || (longrid(ilon) ~= lon(iland)) 
    %fprintf('%f %f %f %f\n',latgrid(360-ilat),lat(iland),longrid(ilon),lon(iland)); end
  if (regionmap(ilon,ilat) ~= me) 
    fprintf('%f %f\n',regionmap(ilon,ilat),me); end

  ilonl=mod(ilon+720-2,720)+1;
  ilonr=mod(ilon,720)+1;
  border(iland,:)=[regionmap(ilonl,ilat) ~= me,regionmap(ilon,ilat-1) ~= me,...
                   regionmap(ilonr,ilat) ~= me,regionmap(ilon,ilat+1) ~= me];
end

nborder=sum(border,2);
iborder=find(nborder > 0);
nborderland=length(iborder);

for ireg=1:nreg 
  me=ireg;
  disp(ireg);
  
  % select all cells of this region
  iselect=find(regionnumber == ireg);
  nselect=length(iselect);
  if nselect<1 continue; end

  [ilon,ilat]=regidx2geoidx(regionindex(iselect),cols);
  
  %ilat=ilat-2;
  %ilon=ilon+1;
  latmin=max([-90,min(latgrid(360-ilat))-1]);
  latmax=min([ 90,max(latgrid(360-ilat))+1]);
  lonmin=max([-180,min(longrid(ilon))-2]);
  lonmax=min([ 180,max(longrid(ilon))+2]);
    
  %figure(1); clf reset;
  %m_proj('Mercator','lon',[lonmin lonmax],'lat',[latmin latmax]);
  %m_coast('line','color','k');
  %m_line(longrid(ilon),latgrid(360-ilat),'color','y','Linestyle','none','marker','.');

  % select all border cells of this region  
  iselect=find(regionnumber == ireg & nborder > 0 &  nborder < 5);
  nselect=length(iselect);
  if nselect<1 continue; end

  [ilon,ilat]=regidx2geoidx(regionindex(iselect),cols);
  latmin=max([-90,min(latgrid(360-ilat))-1]);
  latmax=min([ 90,max(latgrid(360-ilat))+1]);
  lonmin=max([-180,min(longrid(ilon))-2]);
  lonmax=min([ 180,max(longrid(ilon))+2]);
    
  %m_line(longrid(ilon),latgrid(360-ilat),'color','b','Linestyle','none','marker','.');
  
  % calculate neighbourhood to the left,top,right, and bottom 
  neighbours=[];
  ileft=find(regionnumber == ireg & nborder > 0 &  border(:,1) );
  if ~isempty(ileft) 
    [ilon,ilat]=regidx2geoidx(regionindex(ileft),cols);
    ilonl=mod(ilon+cols-2,cols)+1;
    neighbours=[neighbours;unique(regionmap(ilonl,ilat))];
  end
    
  itop=find(regionnumber == ireg & nborder > 0 &  border(:,2) );
  if ~isempty(itop) 
    [ilon,ilat]=regidx2geoidx(regionindex(itop),cols);
    ilatu=ilat-1;
    neighbours=[neighbours;unique(regionmap(ilon,ilatu))];
  end
    
  iright=find(regionnumber == ireg & nborder > 0 &  border(:,3) );
  if ~isempty(iright)
    [ilon,ilat]=regidx2geoidx(regionindex(iright),cols);
    ilonr=mod(ilon,720)+1;
    neighbours=[neighbours;unique(regionmap(ilonr,ilat))];
  end

  ibot=find(regionnumber == ireg & nborder > 0 &  border(:,4) );
  if ~isempty(ibot)
    [ilon,ilat]=regidx2geoidx(regionindex(ibot),cols);
    ilatu=ilat+1;
    neighbours=[neighbours;unique(regionmap(ilon,ilatu))];
  end
  
  neighbours=unique(neighbours);
  regionneighbours(ireg)=length(neighbours);
  regionneighbourhood(ireg,1:regionneighbours(ireg))=neighbours';

  % calculate outline
  npath=sum(sum(border(iselect,:)));
  path=zeros(npath+1,3);

  isel=1;
  ipath=1; 
  idir=0;

  while(sum(sum(border(iselect,:))) > 0)
    %fprintf('%d\n',sum(sum(border(iselect,:))));
    [ilon,ilat]=regidx2geoidx(regionindex(iselect(isel)),cols);
    [ilonl,ilatu,ilonr,ilatb]=geoidx2geoneighbour(ilon,ilat,cols);
    
    latc=min(latgrid(rows-ilat));
    latu=min(latgrid(rows-ilatu));
    latl=min(latgrid(rows-ilatb));
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
        path(ipath,:)=[lonc-0.25,latc,regionmap(ilonl,ilat)];
        if (regionmap(ilonl,ilat-1) == me) idir=3; ineigh=1;
        elseif (regionmap(ilon,ilat-1) == me) idir=0; ineigh=2;
        else ineigh=8; idir=1; end
        
      case 2
        path(ipath,:)=[lonc,latc+0.25,regionmap(ilon,ilat-1)];
        if (regionmap(ilonr,ilat-1) == me) idir=0; ineigh=3; 
        elseif (regionmap(ilonr,ilat) == me) idir=1; ineigh=4; 
        else idir=2; ineigh=8; end
      case 3
        path(ipath,:)=[lonc+0.25,latc,regionmap(ilonr,ilat)];
        if (regionmap(ilonr,ilat+1) == me) idir=1; ineigh=5;
        elseif (regionmap(ilon,ilat+1) == me) idir=2; ineigh=6; 
        else idir=3; ineigh=8; end
      case 4
        path(ipath,:)=[lonc,latc-0.25,regionmap(ilon,ilat+1)];
        if (regionmap(ilonl,ilat+1) == me) idir=2; ineigh=7; 
        elseif (regionmap(ilonl,ilat) == me)  idir=3; ineigh=0; 
        else  idir=0; ineigh=8; end
    end

    %m_line(path(1:ipath,1),path(1:ipath,2),'color','r','marker','.');
    
    ipath=ipath+1;
    border(iselect(isel),isort(ibord))=0;
    %fprintf('%d %d %f=%f %f?%f?\n',isel,ineigh,latc,lat(iselect(isel)),lonc,lon(iselect(isel)));
     

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
  regionpath(ireg,1:ipath,1)=path(1:ipath,1);
  regionpath(ireg,1:ipath,2)=path(1:ipath,2);
  regionpath(ireg,1:ipath,3)=path(1:ipath,3);

end

regioncenter=zeros(nreg,2)-9999.9;
for ireg=1,nreg
  iselect=find(regionnumber == ireg);
  regioncenter(ireg,:)=[mean(lat(iselect)),mean(lon(iselect))];
end

save('regionpath.mat','regionpath','nreg','regionneighbours',...
  'regionneighbourhood','regioncenter');

return;
