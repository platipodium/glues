function cl_get_hyde
%CL_GET_HYDE   Retrieves HYDE database
%  CL_GET_HYDE retrieves the data from the History database of human
%  development found at  (ftp://ftp.mnp.nl/hyde)
%
%  two local files  are created on
%  success, these can be further processed with the routine cl_read_hyde
% 
%  See also CL_READ_HYDE

% Copyright 2009 Carsten Lemmen <carsten.lemmen@gkss.de>

cl_register_function;

baseurl='ftp://ftp.mnp.nl/hyde/hyde31_final';

years=[1000:1000:10000]
ny=length(years);

parameters={'lu','pop'};
np=length(parameters);
ziptemplate='YEARbc_PARAM.zip';

for iy=1:ny
for ip=1:np
  par=parameters{ip};
  zipname=strrep(ziptemplate,'YEAR',num2str(years(iy)));
  zipname=strrep(zipname,'PARAM',par);
  url=fullfile(baseurl,zipname);
    
  if ~exist(zipname)
    [filename,status] = urlwrite(url,zipname);
  end

  filename=strrep(zipname,'.zip','');
  if ~exist(filename)
    status=system(['unzip ' filename]);
  end
end
end

return

end