function cl_dump_landcells

cl_register_function();

map='regionmap_sea_685.mat';

if ~exist(map,'file')
  fprintf('Please create file regionmap_sea_XXX.mat first by running cl_calc_seas\n');
  return
end

load(map);

nreg=length(region.length);
offset=0;

dumpfile='regionmap_685.asc';
fid=fopen(dumpfile,'w');

fprintf(fid,'# GLUES raster of region ids\n');
fprintf(fid,'# Carsten Lemmen & Kai Wirtz <carsten.lemmen@gkss.de> \n');
fprintf(fid,'# Format: lon lat id\n');


for ireg=1:nreg
 imap=find(map.region==ireg);
 n=region.length(ireg);
 [ilon,ilat]=regidx2geoidx(region.land(ireg,1:n));
 lon=map.longrid(ilon);
 lat=-map.latgrid(ilat);
 
 
 dumplon(offset+1:offset+n)=lon;
 dumplat(offset+1:offset+n)=lat;
 dumpid(offset+1:offset+n)=ireg;
 dump=([dumplon' dumplat' dumpid'])';

 fprintf(fid,'%.2f %.2f %d\n',dump(:,offset+1:offset+n));

 
 offset=offset+n;
    
end

fprintf(fid,'#EOF\n');
fclose(fid);


end
