function cl_read_Pinhasi(varargin)
% CL_READ_PINHASI reads a .csv file exported from Excel with " as text
% delimiter and ; as field delimiter

file='../../data/Pinhasi2005_etal_plosbio_som1.csv';

fid=fopen(file,'r');
C=textscan(fid,'%s%s%s%s%s%s%s%s%s%s%s%s%s','Delimiter',';');
fclose(fid);

% Headers in row three
roff=2;
txt=char(strrep(C{1}(roff+1:end),',','.')); lat=str2num(txt);
txt=char(strrep(C{2}(roff+1:end),',','.')); lon=str2num(txt);
site=strrep(C{3}(roff+1:end),'"','');
location=strrep(C{4}(roff+1:end),'"','');
country=strrep(C{5}(roff+1:end),'"','');
period=strrep(C{7}(roff+1:end),'"','');
lab=strrep(C{8}(roff+1:end),'"','');
txt=char(strrep(C{12}(roff+1:end),',','.')); age_cal_bp=str2num(txt);
txt=char(strrep(C{13}(roff+1:end),',','.')); age_cal_bp_sdev=str2num(txt);

Pinhasi.latitude=lat;
Pinhasi.longitude=lon;
Pinhasi.site=site;
Pinhasi.lab=lab;
Pinhasi.country=country;
Pinhasi.period=period;
Pinhasi.location=location;
Pinhasi.age_cal_bp=age_cal_bp;
Pinhasi.age_cal_bp_s=age_cal_bp_sdev;

save(strrep(file,'.csv','.mat'),'Pinhasi');

end
