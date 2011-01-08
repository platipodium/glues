function cl_get_hyde
%CL_GET_HYDE   Retrieves HYDE database.  Data is stored in ../../data subdirectory
%  CL_GET_HYDE retrieves the data from the History database of human
%  development found at  (ftp://ftp.mnp.nl/hyde)
%
%  two local files  are created on
%  success, these can be further processed with the routine cl_read_hyde
% 
%  See also CL_READ_HYDE

% Copyright 2009 Carsten Lemmen <carsten.lemmen@gkss.de>

cl_register_function;

scenarios={'final','lower','upper'};
ns=length(scenarios);

baseurl='ftp://ftp.mnp.nl/hyde/hyde31_';
destdir='../../data/hyde';

years=[1000:1000:10000];
ny=length(years);

lupars={'alcp' 'crop' 'algr' 'gras'};
poppars={'popd','popc'};

parameters={'lu','pop'};
np=length(parameters);
ziptemplate='YEARbc_PARAM.zip';

for is=1:ns
for iy=1:ny
for ip=1:np
  par=parameters{ip};
  zipname=strrep(ziptemplate,'YEAR',num2str(years(iy)));
  zipname=[strrep(zipname,'PARAM',par)];
  url=fullfile([baseurl scenarios{is}],zipname);
    
  localname=fullfile(destdir,[scenarios{is} '_' zipname ]);
  zipname=fullfile(destdir,zipname);
  if ~exist(localname,'file')
    [filename,status] = urlwrite(url,zipname);
    if ~exist(zipname)
      error('Zip file could not be downloaded');
    end
  end

  if ~exist(localname)
    system(['mv ' zipname ' ' localname]); 
  end
  continue;
  % TODO: only unzip if contents not yet unzipped
 % if strcmp(parameters{ip},'lu')
  %  if ~exist(fullfile(destdir,[scenarios{is} _ lupars{1} _ num2str(years(iy))]),'file')
       unzip(localname,destdir);
   % end
   % for i=1:length(lupars) 
    %  if  ~exist(fullfile(destdir,[scenarios{is} _ lupars{i} _ num2str(years(iy))]),'file')
     % system(['mv ' fullfile(destdir,[lupars{i} num2str(years(iy))]) ...
      %    ' ' fullfile(destdir,[scenarios{is} _ lupars{i} _ num2str(years(iy))])]
       % end
    %end  
  
  
  
end
end
end

return

end