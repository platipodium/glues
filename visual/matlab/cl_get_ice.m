function cl_get_ice
%CL_GET_ICE   Retrieves ICE-5G database
%  CL_GET_ICE retrieves the fractional ice sheet coverage, topography, and
%  ice sheet thickness from the ICE-5G database (Peltier)
%
% 
% Copyright 2009 Carsten Lemmen <carsten.lemmen@gkss.de>

% Dependencies CL_REGISTER_FUNCTION, CL_INIT
% Data should end up in /usr/local/share/glues/extern/ice5g

cl_register_function;
d=cl_init;
datadir=fullfile(d.share,'glues/extern/ice5g');

years=[0:0.5:12]; % kyr BP
ny=length(years);
parameters={'tmean','prec'};
urldir='http://pmip2.lsce.ipsl.fr/share/design/ice5g';
basename='ice5g_v1.2_YEARk_1deg.nc.gz';

for iy=1:ny
  y=years(iy);
  zipname=strrep(basename,'YEAR',sprintf('%04.1f',y));
  zipfile=fullfile(datadir,zipname);
  
  url=fullfile(urldir,zipfile);
  ncname=strrep(zipfile,'.gz','');
  ncfile=fullfile(datadir,ncname);  
  
  if ~exist(zipfile) & ~exist(ncfile)
    fprintf('Retrieving %s from %s\n',zipfile,url);
    [zipfile,status] = urlwrite(url,zipfile);
  end

  if ~exist(ncfile) & exist(zipfile)
    status=system(['gunzip ' zipname]);
    status=system(['mv ' ncname ' ' ncfile]);
  end
end

return

end