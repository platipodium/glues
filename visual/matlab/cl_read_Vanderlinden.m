function Vanderlinden=cl_read_Vanderlinden(varargin)
% CL_READ_Vanderlinden reads a .csv file exported from Excel with " as text
% delimiter and ; as field delimiter

file='../../data/VanDerLinden_unpub_mesoneo14C.csv';
[filepath filename]=fileparts(file);


fid=fopen(file,'r');
C=textscan(fid,'%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s','Delimiter','|');
fclose(fid);

% Headers in row one, roff=1
roff=1;
%COUNTRY;PERIOD;CULTURE;SITE;TYPESITE;LABNR;C14AGE;C14STD;MATERIAL;SPECIES;C13;METHOD;CONTEXT;LAT;LON;REFS

country=strrep(C{1}(roff+1:end),'"','');
period=strrep(C{2}(roff+1:end),'"','');
culture=strrep(C{3}(roff+1:end),'"','');
site=strrep(C{4}(roff+1:end),'"','');
typesite=strrep(C{5}(roff+1:end),'"','');
lab=strrep(C{6}(roff+1:end),'"','');

txt=char(strrep(C{7}(roff+1:end),',','.')); age_uncal_bp=str2num(txt);
txt=char(strrep(C{8}(roff+1:end),',','.')); age_cal_bp_sdev=str2num(txt);


material=strrep(C{9}(roff+1:end),'"','');
species=strrep(C{10}(roff+1:end),'"','');

txt=char(strrep(C{11}(roff+1:end),',','.')); c13=str2num(txt);

method=strrep(C{12}(roff+1:end),'"','');
context=strrep(C{13}(roff+1:end),'"','');

txt=char(strrep(C{14}(roff+1:end),',','.')); lat=str2num(txt);
txt=char(strrep(C{15}(roff+1:end),',','.')); lon=str2num(txt);

reference=strrep(C{13}(roff+1:end),'"','');

Vanderlinden.latitude=lat;
Vanderlinden.longitude=lon;
Vanderlinden.site=site;
Vanderlinden.lab=lab;
Vanderlinden.country=country;
Vanderlinden.culture=culture;
Vanderlinden.period=period;
Vanderlinden.age_uncal_bp=age_uncal_bp;
Vanderlinden.age_cal_bp=age_uncal_bp*NaN;
Vanderlinden.age_cal_bp_s=age_cal_bp_sdev;
Vanderlinden.filename=filename;

save(strrep(file,'.csv','.mat'),'Vanderlinden');

end
