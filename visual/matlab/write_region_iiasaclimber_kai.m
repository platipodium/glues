function write_region_iiasaclimber_kai


cl_register_function();

npptxtfile='../../examples/setup/685/reg_npp_80_685.dat';
gddtxtfile=strrep(npptxtfile,'npp','gdd');


npp=load(npptxtfile);
gdd=load(gddtxtfile);

[nclim,nreg]=size(npp);

nppfile=['region_iiasaclimber_kai_npp_' num2str(nreg) '.tsv'];
gddfile=strrep(nppfile,'npp','gdd');

v=get_version;
fid=fopen(nppfile,'w');
fprintf(fid,'# ASCII data info: columns\n');
fprintf(fid,'# 1. region id 2. number of climates,\n');
fprintf(fid,'# 3..n dynamic-npp\n');
fprintf(fid,'# Version info: %s\n',struct2stringlines(v));
fprintf(fid,'# File converted from %s\n',npptxtfile);

for ireg=1:nreg
    fprintf(fid,'%04d %5d',ireg,nclim);
    for iclim=1:nclim
        fprintf(fid,' %f',(npp(iclim,ireg)));
    end
    fprintf(fid,'\n');
end
fclose(fid);

fid=fopen(gddfile,'w');
fprintf(fid,'# ASCII data info: columns\n');
fprintf(fid,'# 1. region id 2. number of climates \n');
fprintf(fid,'# 4..n dynamic-gdd\n');
fprintf(fid,'# Version info: %s\n',struct2stringlines(v));
fprintf(fid,'# File converted from %s\n',gddtxtfile);

for ireg=1:nreg 
    fprintf(fid,'%04d %5d',ireg,nclim);
    for iclim=1:nclim
        fprintf(fid,' %.1f',(gdd(iclim,ireg)));
    end
    fprintf(fid,'\n');
end
fclose(fid);

return
end

