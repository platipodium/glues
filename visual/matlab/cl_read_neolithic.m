function sites = cl_read_neolithic(author,timelim,lonlim,latlim)
% sites = cl_read_neolithic(author,timelim,lonlim,latlim)


if ~exist('author','var') author='Turney'; end
if ~exist('latlim','var') latlim=[31,57]; end
if ~exist('lonlim','var') lonlim=[-10,42]; end
if ~exist('timelim','var') timelim=[-12000,0]; end


% For Turney and Brown do this
if strcmp(author,'Turney')
  load('neolithicsites');
  filename='neolithicsites (Turney)';
  lat=Forenbaher.Latitude';
  lon=Forenbaher.Long';
  culture=Forenbaher.Period';
  period=culture; 
  period(:)={'Neolithic'};
  location=Forenbaher.Site_name';
  age_cal_bp=Forenbaher.Median_age';
  age_uncal_bp=age_cal_bp+NaN;
  age_upper=Forenbaher.Upper_cal_';
  age_lower=Forenbaher.Lower_cal';
  culture=period;
elseif strcmp(author,'Pinhasi')
  % For Pinhasi
  load('../../data/Pinhasi2005_etal_plosbio_som1.mat');
  filename='Pinhasi2005_etal_plosbio_som1';
  lat=Pinhasi.latitude;
  lon=Pinhasi.longitude;
  culture=Pinhasi.period;
  period=culture; 
  period(:)={'Neolithic'};
  location=Pinhasi.site;
  age_cal_bp=Pinhasi.age_cal_bp;
  age_uncal_bp=age_cal_bp+NaN;
  age_upper=age_cal_bp+Pinhasi.age_cal_bp_sdev;
  age_lower=age_cal_bp-Pinhasi.age_cal_bp_sdev;
  culture=period;
elseif strcmp(author,'Vanderlinden');
  % For Van der Linden
  load('../../data/VanDerLinden_unpub_mesoneo14C.mat');
  filename='VanDerLinden_unpub_mesoneo14C';
  lat=Vanderlinden.latitude;
  lon=Vanderlinden.longitude;
  period=Vanderlinden.period;
  culture=Vanderlinden.culture;
  location=Vanderlinden.site;
  age_uncal_bp=Vanderlinden.age_uncal_bp;
  if exist('Vanderlinden_calibrated.mat','file')
     load('Vanderlinden_calibrated.mat');
  else
    age_cal_bp=Vanderlinden.age_cal_bp;
  end
  age_upper=age_cal_bp+Vanderlinden.age_cal_bp_s;
  age_lower=age_cal_bp-Vanderlinden.age_cal_bp_s;
elseif strcmp(author,'Fepre');
  % Fepre data, also Vanderlinden
  file='../../data/Fort2012_etal_americanantiquity_som1.mat';
  [ filepath filename]=fileparts(file);
  load(file);
  lat=fepre.latitude;
  lon=fepre.longitude;
  period=fepre.period;
  culture=fepre.culture;
  location=fepre.site;
  age_uncal_bp=fepre.age_uncal_bp;
  age_cal_bp=fepre.age_cal_bp;
  age_upper=age_cal_bp+fepre.age_cal_bp_s;
  age_lower=age_cal_bp-fepre.age_cal_bp_s;
  
else
  error('Not a valid dataset author, choose Turney, Vanderlinden, Fepre, or Pinhasi');
end

time=1950-age_cal_bp;
time_upper=time+(age_lower-age_cal_bp);
time_lower=time+(age_upper-age_cal_bp);

if any(isnan(time_lower))
  is=find(lat>=latlim(1) & lat<=latlim(2) & lon>=lonlim(1) & lon<=lonlim(2) ...
    & strcmp('Neolithic',period));
else
is=find(lat>=latlim(1) & lat<=latlim(2) & lon>=lonlim(1) & lon<=lonlim(2) ...
    & time_lower>=timelim(1) & time_upper<=timelim(2) & strcmp('Neolithic',period));
end

sites.lon=lon(is);
sites.lat=lat(is);
sites.latitude=sites.lat;
sites.longitude=sites.lon;
sites.period=period(is);
sites.culture=culture(is);
sites.location=location(is);
sites.time=time(is);
sites.age_cal_bp=age_cal_bp(is);
sites.age_uncal_bp=age_uncal_bp(is);
sites.time_lower=time_lower(is);
sites.time_upper=time_upper(is);
sites.time_range=time_lower(is)-time_upper(is);
sites.filename=filename;

return
end
