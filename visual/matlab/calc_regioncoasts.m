function calc_regioncoasts

cl_register_function();

load('regionpath');

% Basins as defined in plot_seas.m
basins={'Mediterranean','Black Sea','Red Sea','Persian Gulf','Caspian Sea','Baltic Sea','Other'};
basinnumber=[   -200   ,  -300     , -400    , -450         , -350        , -650       , -10];

nbasins=length(basins);
coastreg=[];

for ibasin=1:nbasins-1
  sea=basinnumber(ibasin);
  fprintf('Calculating neighbours in %s basin ...',basins{ibasin});

  coastreg=find_region_numbers('neigh',basinnumber(ibasin));
  ncoast=length(coastreg);

  fprintf('%d regions surround it.\n',ncoast);
 
  neighbours=zeros(ncoast,ncoast)-9999;
  coastregions=zeros(ncoast,4)-9999;
  coastregions(:,1)=coastreg;
    
  for icoast=1:ncoast

    ireg=coastreg(icoast);
    ineigh=find(regionneighbourhood(ireg,:) == sea);

    ivalid=find(regionpath(ireg,:,1) > -9999);
    nvalid=length(ivalid);
    istart=min(find(regionpath(ireg,:,1) > -9999 & regionpath(ireg,:,3) == sea));
    iend=max(find(regionpath(ireg,:,1) > -9999 & regionpath(ireg,:,3) == sea));
    pathlength=0.0;

    for i=max(1,istart):min(nvalid-1,iend) 
      j=i+1;
      if ((regionpath(ireg,i,3) ~= sea) & (regionpath(ireg,j,3) ~= sea)) continue; end
      gcd=m_lldist(regionpath(ireg,[i,j],1),regionpath(ireg,[i,j],2));
      if (regionpath(ireg,i,3) == regionpath(ireg,j,3)) pathlength=pathlength+gcd;
      else pathlength=pathlength+0.5*gcd; 
      end
    end

    coastregions(icoast,2)=round(pathlength);
    ipath=find(regionpath(ireg,:,3) == sea);
    if isempty(ipath) continue; end
    coastregions(icoast,4)=mean(regionpath(ireg,ipath,2));
    coastregions(icoast,3)=mean(regionpath(ireg,ipath,1)); 
    
    %fprintf('... coast %d for %d (%d km around %f.1E %f.1N)\n',icoast,ireg,coastregions(icoast,2), ...
    %  coastregions(icoast,3),coastregions(icoast,4));
    end
      
    for icoast=1:ncoast-1 for jcoast=icoast+1:ncoast
        ireg=coastreg(icoast);
        jreg=coastreg(jcoast);
 
        gcd=m_lldist(coastregions([icoast,jcoast],3),coastregions([icoast,jcoast],4));,
        neighbours(icoast,jcoast)=round(gcd);
        neighbours(jcoast,icoast)=round(gcd);
      end
    end
 
    basinn=lower(strrep(basins{ibasin},' ',''));
    save(['regioncoasts_' basinn],'coastregions','neighbours');

    fid=fopen(strcat('regioncoasts_',basinn,'.tsv'),'w');

    for icoast=1:ncoast
      ireg=coastregions(icoast,1);
      ijreg=find(coastregions(:,1) ~= ireg);
      jreg=coastregions(ijreg);
      
      fprintf(fid,'%4d %5d',ireg,length(jreg));
      for i=1:ncoast-1
        fprintf(fid,' %4d:%5.5d',jreg(i),neighbours(icoast,ijreg(i)));
      end
      fprintf(fid,'\n');
    end
    fclose(fid);
  
end
return
