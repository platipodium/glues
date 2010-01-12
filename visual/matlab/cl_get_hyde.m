function cl_get_hyde
%CL_GET_HYDE   Retrieves HYDE database.  Data is stored in ./data subdirectory
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
destdir='./data';

years=[1000:1000:10000];
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
    
  zipname=fullfile(destdir,zipname);
  if ~exist(zipname)
    [filename,status] = urlwrite(url,zipname);
  end

  if ~exist(zipname)
      error('Zip file could not be downloaded');
  end
  
  
      % TODO: only unzip if contents not yet unzipped
    unzip(zipname,destdir);

  
end
end

return

end