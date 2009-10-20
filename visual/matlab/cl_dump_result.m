function cl_dump_result

cl_register_function();

resultfile='result_iiasaclimber_ref_all.mat';

if ~exist(resultfile,'file')
  return
end

load(resultfile);

time=1980-r.time;
itime=find(time<=-1000);
ntime=length(itime);
nreg=r.nreg;

dumpfile='results_685.asc';
fid=fopen(dumpfile,'w');

fprintf(fid,'# GLUES result for 685 ids\n');
fprintf(fid,'# Carsten Lemmen\n');
fprintf(fid,'# Format: time region-id pop-density farmer-share tech-level\n');


for ireg=1:nreg

 dens=r.Density(ireg,itime);
 tech=r.Technology(ireg,itime);
 farm=r.Farming(ireg,itime);
 reg=repmat(ireg,1,ntime);
 
 dump=[reg' time(itime)' dens' farm' tech'];
 
 fprintf(fid,'%d %d %f %f %f\n',dump');

    
% fprintf(fid,'%.2f %.2f %d\n',dump(:,offset+1:offset+n));

 

end

fprintf(fid,'#EOF\n');
fclose(fid);


end
