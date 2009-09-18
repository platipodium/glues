function cl_get_iiasa
%CL_GET_IIASA   Retrieves IIASA database
%  CL_GET_IIASA retrieves the temperature (monthly mean) and precipitation
%  (monthly) climatological data from the IIASA database (version 2.1),
%  originally published in Leemans & Cramer (1991)
%
%  two local files iiasa_tmean.grd and iiasa_prec.grd are created on
%  success, these can be further processed with the routine cl_read_iiasa
% 
%  See also CL_READ_IIASA

% Copyright 2009 Carsten Lemmen <carsten.lemmen@gkss.de>

cl_register_function;

parameters={'tmean','prec'};
np=length(parameters);
baseurl='http://www.pik-potsdam.de/members/cramer/climate/PARAM.grd.gz/at_download/file';

for ip=1:np
  par=parameters{ip};
  url=strrep(baseurl,'PARAM',par);
    
  zipname=['iiasa_' par '.grd.gz'];
  if ~exist(zipname)
    [filename,status] = urlwrite(url,zipname);
  end

  filename=strrep(zipname,'.gz','');
  if ~exist(filename)
    status=system(['gunzip ' filename]);
  end
end

return

end