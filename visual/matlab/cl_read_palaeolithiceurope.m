function sites = cl_read_palaeolithiceurope(varargin)
% sites = cl_read_palaeolithiceurope()

% Prepare your data file (comma to point)
% sed -i 's/\([0-9][0-9]*\),\([0-9][0-9]*\)/\1.\2/g' ../../data/palaeolithic_radiocarbon_data_europe_v13.csv

% Information from the data set:
%Radiocarbon Palaeolithic Europe Database v13;;;;;;;;;;;;;
%Pierre M. Vermeersch, Dept. of Earth and Environmental Sciences, Katholieke Universiteit Leuven, Belgium - june 2011;;;;;;;;;;;;;
%This Excel file is a query from the larger database which can be downloadend from:;;;;;;;;;;;;;
%http://www.ees.kuleuven.be/geography/projects/14c-palaeolithic/index.html;;;;;;;;;;;;;
%All suggestions and corrections are welcome at pierre.vermeersch@ees.kuleuven.be;;;;;;;;;;;;;
%Site;Level;Lat.;Long.;Culture;;Method;Age;?;Lab ref.;Sample;;;

cl_register_function;

csvfile='../../data/palaeolithic_radiocarbon_data_europe_v13.csv';
matfile=strrep(csvfile,'.csv','.mat');
sep=';';

if ~exist(matfile,'file') 
    if ~exist(csvfile,'file') error('File does not exist'); end;

fid=fopen(csvfile,'rt');
% Radiocarbon dates
RC=textscan(fid,'%s%s%f%f%s%s%d%d%s%s%s%s%s',4642,'delimiter',sep,'Headerlines',9,'CommentStyle','#');
% AMS dates
%g_sitename;g_layer_id;g_coord_lat;g_coord_long;cu_stage;;ch_ams_age;ch_ams_pm;ch_ams_labref;ch_ams_sample;;;;
AC=textscan(fid,'%s%s%f%f%s%s%d%d%s%s%s%s%s',4311,'delimiter',sep,'HeaderLines',3,'CommentStyle','#');
% OSL dates
% id;g_sitename;g_layer_id;g_country;g_coord_lat;;g_coord_long;cu_stage;ch_osl_age;ch_osl_pm;ch_other_age;ch_other_pm;ch_tl_age;ch_tl_pm
OC1=textscan(fid,'%d%s%s%s%f%s%f%s%d%d%s%d%d%d',20858,'delimiter',sep,'HeaderLines',3,'CommentStyle','#');
% Further OSL dates (no id)
%g_sitename;g_layer_id;g_coord_lat;g_coord_long;cu_stage;;ch_osl_age;ch_osl_pm;ch_osl_labref;ch_osl_sample;;;;
OC2=textscan(fid,'%s%s%f%f%s%s%d%d%s%s%s%s%s',136,'delimiter',sep,'HeaderLines',3,'CommentStyle','#');
% Thermoluminescence
%g_sitename;g_layer_id;g_coord_lat;g_coord_long;cu_stage;;ch_tl_age;ch_tl_pm;ch_tl_labref;ch_tl_sample;;;;
TC=textscan(fid,'%s%s%f%f%s%s%d%d%s%s%s%s%s','delimiter',sep,'HeaderLines',3,'CommentStyle','#');
fclose(fid);


sites.name=vertcat(RC{1},AC{1},OC1{2},OC2{1},TC{1});
sites.layer=vertcat(RC{2},AC{2},OC1{3},OC2{1},TC{2});
sites.latitude=vertcat(RC{3},AC{3},OC1{5},OC2{4},TC{3});
%sites.country=vertcat(OC1{4})
sites.longitude=vertcat(RC{4},AC{4},OC1{7},OC2{4},TC{4});
sites.period=vertcat(RC{5},AC{5},OC1{8},OC2{5},TC{5});
sites.age=vertcat(RC{7},AC{7},OC1{9},OC2{7},TC{7});
sites.age_pm=vertcat(RC{7},AC{8},OC1{10},OC2{8},TC{8});
%sites.labcode=vertcat(RC{8},AC{9},OC1{},OC2{9},TC{9};
%sites.sample=RC{9};

save(matfile','sites');
else load(matfile);
end

return
end
