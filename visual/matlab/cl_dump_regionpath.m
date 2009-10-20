function cl_dump_regionpath

cl_register_function;

pathfile='regionpath_685';
dumpfile=[pathfile '.asc'];
fid=fopen(dumpfile,'w');


load(pathfile);
nreg=region.nreg;

fprintf(fid,'# GLUES region path definition shape file\n');
fprintf(fid,'# C. Lemmen & K. Wirtz <carsten.lemmen@gkss.de\n');
fprintf(fid,'# Layout > sign, regioid, then each row lat lon vals\n');

for ireg=1:nreg
  fprintf(fid,'> %d\n',ireg);

  ipath=find(isfinite(region.path(ireg,:,1))); 
  path=squeeze(region.path(ireg,ipath,1:2));  
  
  fprintf(fid,'%.2f %.2f\n',path');
  
end

fprintf(fid,'# EOF\n');
fclose(fid);
return;

end
