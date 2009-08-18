function calc_regionmap_borders

cl_register_function();

load('regionpath_939');

% For each neighbourhood, calculate borderlength distance and ease
regionborders=zeros([size(regionneighbourhood),3])-9999.9;

for ireg=1:nreg
  disp(ireg);
  ivalid=find(regionpath(ireg,:,1) >  -9999);
  nvalid=length(ivalid);
  ineigh=find(regionneighbourhood(ireg,:) > -9999);
  nneigh=length(ineigh);
  if nneigh ~= regionneighbours(ireg)
    error('Something is wrong here');
    return
  end
  
  for in=1:nneigh
    neigh=regionneighbourhood(ireg,in);
    if neigh < 0 gcd=0.0; 
    else gcd=m_lldist(regioncenter([ireg,neigh],1),regioncenter([ireg,neigh],2));
    end
    regionborders(ireg,in,2)=gcd;
  end
  
  pathlength=zeros(nneigh,1);
  
  for i=2:nvalid
    j=ivalid(i);
    jm=ivalid(i-1);
    gcd=m_lldist(regionpath(ireg,[j,jm],1),regionpath(ireg,[j,jm],2));
    ineigh=find(regionneighbourhood(ireg,:) == regionpath(ireg,j,3));
    if regionpath(ireg,jm,3) == regionpath(ireg,j,3) pathlength(ineigh)=pathlength(ineigh)+gcd;
    else 
      pathlength(ineigh)=pathlength(ineigh)+0.5*gcd;
      jneigh=find(regionneighbourhood(ireg,:) == regionpath(ireg,jm,3));
      pathlength(jneigh)=pathlength(jneigh)+0.5*gcd; 
    end
  end
  regionborders(ireg,1:nneigh,1)=pathlength;
end

% correct for inconsistencies introduce by differing path ends
for ireg=1:nreg
  ineigh=find(regionneighbourhood(ireg,:) > -1 & regionneighbourhood(ireg,:) > ireg);
  nneigh=length(ineigh);
  for in=1:nneigh
    jreg=regionneighbourhood(ireg,in);
    if jreg<0 continue; end
    jn = find(regionneighbourhood(jreg,:) == ireg);
    m=mean([regionborders(ireg,in,1),regionborders(jreg,jn,1)]);
    regionborders(ireg,in,1)=m;
    regionborders(jreg,jn,1)=m;
  end
end

save('regionborders','regionborders');

fid=fopen('regionborders.tsv','w');
for ireg=1:nreg
  ineigh=find(regionneighbourhood(ireg,:) > -9999);
  nneigh=length(ineigh);
  fprintf(fid,'%4d %4d',ireg,nneigh);
  for ineigh=1:nneigh
    fprintf(fid,' %4d:%5.5d:%4.4d',regionneighbourhood(ireg,ineigh),...
      round(regionborders(ireg,ineigh,1)),round(regionborders(ireg,ineigh,1)));
  end
  fprintf(fid,'\n');
  
end
fclose(fid)

return
