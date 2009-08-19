function read_iiasa()

cl_register_function();

[d,f]=get_files;

if ~isfield(d,'data')
  error('DATA directory not defined. Fix in get_files!');
end

precfile =fullfile(d.data,'climatology/iiasa','prec.grd');
if ~exist(precfile,'file');
  error('Cannot read precipitation data file');
end

tmeanfile=fullfile(d.data,'climatology/iiasa','tmean.grd');
if ~exist(tmeanfile,'file');
   error('Cannot read temperature data file');
end

prec=load(precfile,'-ascii');
tmean=load(tmeanfile,'-ascii');

% Data is lower-left coded, change to center
lon=prec(:,1)+0.25; 
lat=prec(:,2)+0.25;
prec=prec(:,3:end);
tmean=tmean(:,3:end);

save('-v6','iiasa','prec','tmean','lon','lat');

return;
end
