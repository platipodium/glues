function [colors]=calc_regioncolors(region)

cl_register_function();

%isstruct(region) 
  nreg=region.nreg; 


colors=zeros(nreg,1)+NaN;


icolor=1;
ireg=1;
rn=[];

while max(isnan(colors))==1
  colors(ireg)=icolor;
  rn=[rn,ireg,region.neighbourhood(ireg,1:region.neighbours(ireg))];
  while(ireg<=nreg && ( ~isempty(find(ireg==rn)) | isfinite(colors(ireg)))) ireg=ireg+1; end;
  if (ireg>nreg) 
      icolor=icolor+1;
      ireg=min(find(isnan(colors)));
      rn=[];
  end
end
    
