function fepre=cl_read_fepre(varargin)
% CL_READ_FEPRE reads a .csv file exported from Excel with no text
% delimiter and # as field delimiter

file='../../data/Fort2012_etal_americanantiquity_som1.csv';
[filepath filename]=fileparts(file);

fid=fopen(file,'r');
C=textscan(fid,'%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s','Delimiter','#','headerlines',5);
fclose(fid);

% Headers in row one, roff=1
%COUNTRY;PERIOD;CULTURE;SITE;TYPESITE;LABNR;C14AGcal;c14ageuncal;C14STD;MATERIAL;LAT; LON;dC13;METHOD;CONTEXT;REFS

roff=0;
country=strrep(C{1}(roff+1:end),'"','');
period=strrep(C{2}(roff+1:end),'"','');
culture=strrep(C{3}(roff+1:end),'"','');
site=strrep(C{4}(roff+1:end),'"','');
typesite=strrep(C{5}(roff+1:end),'"','');
lab=strrep(C{6}(roff+1:end),'"','');

% convert numeric fields
for i=[7 8 9 11 12 13]
  txt=char(strrep(C{i},',','.')); 
  s=size(txt,2);
  emptystring=repmat(' ',1,s);
  nanstring=emptystring;
  nanstring(1:3)='NaN';
  inan=strmatch(emptystring,txt);
  for j=1:length(inan) txt(inan(j),:)=nanstring; end;
  value=str2num(txt);
  switch (i)
      case 7, age_cal_bp=value; 
      case 8, age_uncal_bp=value;
      case 9, age_cal_bp_sdev=value;
      case 11, lat=value;
      case 12, lon=value;
      case 13, d13c=value;
      otherwise error('Unknown field');
  end
end

material=strrep(C{10}(roff+1:end),'"','');

%txt=char(strrep(C{11}(roff+1:end),',','.')); lat=str2num(txt);
%txt=char(strrep(C{12}(roff+1:end),',','.')); lon=str2num(txt);
%txt=char(strrep(C{13}(roff+1:end),',','.')); d13c=str2num(txt);

method=strrep(C{14}(roff+1:end),'"','');
context=strrep(C{15}(roff+1:end),'"','');
reference=strrep(C{16}(roff+1:end),'"','');

fepre.latitude=lat;
fepre.longitude=lon;
fepre.site=site;
fepre.lab=lab;
fepre.country=country;
fepre.culture=culture;
fepre.period=period;
fepre.age_uncal_bp=age_uncal_bp;
fepre.age_cal_bp=age_cal_bp;
fepre.age_cal_bp_s=age_cal_bp_sdev;
fepre.filename=filename;


save(strrep(file,'.csv','.mat'),'fepre');

end
