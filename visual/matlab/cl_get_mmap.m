function cl_get_mmap
%CL_GET_MPROJ   Retrieves M_MAP mapping toolbox
% 

% Copyright 2010 Carsten Lemmen <carsten.lemmen@gkss.de>

cl_register_function;

url='http://www.eos.ubc.ca/%7Erich';
zipname='m_map';
version='1.4';

if ~exist(fullfile(pwd,zipname),'file')
  [filename,status] = urlwrite(fullfile(url,[zipname version '.zip']),[zipname '.zip']);

  if exist(filename,'file')
     unzip(filename);     
     addpath(fullfile(pwd,zipname));
  end
end



return

end