function sites = cl_read_megalithtombs
% sites = cl_read_megalithtombs()

cl_register_function;

csvfile='../../data/MegalithgraeberNE_Skan_2010_08_25.csv';
tsvfile=strrep(csvfile,'.csv','_lonlat.tsv');
sep=';';

if ~exist(tsvfile)
  if ~exist(csvfile,'file') error('File does not exist'); end;
  cmd=sprintf('awk -F"%s" ''{ if ($8>0) {print $8,$9;}}'' %s | grep -v Koo | sed ''s#,#.#g'' > %s',sep,csvfile,tsvfile);
  system(cmd);
end
if ~exist(tsvfile,'file') error('File does not exist'); end;

lonlat=load(tsvfile);
lon=lonlat(:,2);
lat=lonlat(:,1);


sites.lon=lon;
sites.lat=lat;
sites.latitude=sites.lat;
sites.longitude=sites.lon;

return
end
