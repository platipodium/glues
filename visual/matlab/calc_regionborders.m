function calc_regionborders

cl_register_function();

regionpathfile='regionpath_686.mat';

load(regionpathfile);

if exist('region','var') & isstruct(region) 
  nreg=region.nreg; 
  regionneighbours=region.neighbours;
  regionneighbourhood=region.neighbourhood;
  regionpath=region.path;
  if ~isfield(region,'center') region.center=[region.lon,region.lat]; end
end


% For each neighbourhood, calculate borderlength distance and ease
region.borders=zeros([size(region.neighbourhood),3])-9999.9;

for ireg=1:nreg
   % for ireg=33:33
  disp(ireg);
  ivalid=find(region.path(ireg,:,1) >  -9999);
  nvalid=length(ivalid);
  ineigh=find(region.neighbourhood(ireg,:) > -9999);
  nneigh=length(ineigh);
  if nneigh ~= region.neighbours(ireg)
    error('Something is wrong here');
    return
  end
  
  for in=1:nneigh
    neigh=region.neighbourhood(ireg,in);
    if neigh < 0 gcd=0.0; 
    else gcd=m_lldist(region.center([ireg,neigh],1),region.center([ireg,neigh],2));
    end
    region.borders(ireg,in,2)=gcd;
  end
  
  pathlength=zeros(nneigh,1);
  
  for i=2:nvalid
    j=ivalid(i);
    jm=ivalid(i-1);
    gcd=m_lldist(region.path(ireg,[j,jm],1),region.path(ireg,[j,jm],2));
    ineigh=find(region.neighbourhood(ireg,:) == region.path(ireg,j,3));
    if region.path(ireg,jm,3) == region.path(ireg,j,3) pathlength(ineigh)=pathlength(ineigh)+gcd;
    else 
      pathlength(ineigh)=pathlength(ineigh)+0.5*gcd;
      jneigh=find(region.neighbourhood(ireg,:) == region.path(ireg,jm,3));
      pathlength(jneigh)=pathlength(jneigh)+0.5*gcd; 
    end
  end
  region.borders(ireg,1:nneigh,1)=pathlength;
end

% correct for inconsistencies introduce by differing path ends
for ireg=1:nreg
  ineigh=find(region.neighbourhood(ireg,:) > -1 & region.neighbourhood(ireg,:) > ireg);
  nneigh=length(ineigh);
  for in=1:nneigh
    jreg=region.neighbourhood(ireg,in);
    if jreg<0 continue; end
    jn = find(region.neighbourhood(jreg,:) == ireg);
    m=mean([region.borders(ireg,in,1),region.borders(jreg,jn,1)]);
    region.borders(ireg,in,1)=m;
    region.borders(jreg,jn,1)=m;
  end
end

nregion=calc_region_bridges(region);

regionbordersfile=strrep(regionpathfile,'path','borders');
save('-v6',regionbordersfile,'region');

regionbordersfile=strrep(regionbordersfile,'.mat','.tsv');
fid=fopen(regionbordersfile,'w');
for ireg=1:nreg
  ineigh=find(region.neighbourhood(ireg,:) > -9999);
  nneigh=length(ineigh);
  fprintf(fid,'%04d %4d',ireg,nneigh);
  for ineigh=1:nneigh
    fprintf(fid,' %d:%d:%d',region.neighbourhood(ireg,ineigh),...
      round(region.borders(ireg,ineigh,1)),round(region.borders(ireg,ineigh,2)));
  end
  fprintf(fid,'\n');
  
end
fclose(fid);

return
