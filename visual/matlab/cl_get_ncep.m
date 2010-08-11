function cl_get_ncep
%CL_GET_NCEP  Retrieves NCEP database

% Copyright 2010 Carsten Lemmen <carsten.lemmen@gkss.de>

param='prate';
years=[1940:2010];

cl_register_function;


%% Get README file
base='http://www.cru.uea.ac.uk/cru/data/ncep/qs_eurasia/daily/sflux';
url=fullfile(base,[param '.sfc'],'Read_me');
filename=fullfile('data',['ncep_' param '.txt']);

[f,status]=urlwrite(url,filename);
if (status~=1) error('Something went wrong'); end
fid=fopen(f,'r');
val=NaN;
i=1;
while (~feof(fid))
    l=fgetl(fid);
    if isempty(l) continue; end
    if (l(1)=='P') 
      description=strrep(l,'PARAMETER: ','');
      description=lower(strrep(description,' ','_'));
    elseif (l(1)=='U') units=strrep(l,'UNITS: ','');
    elseif (l(1)=='L') 
      if (l(2)=='A') continue;
      else
        lat=val; val=NaN; i=1;
      end
    else val(i)=str2num(l); i=i+1;
    end  
end
lon=val;
nlat=length(lat);
nlon=length(lon);


filename=fullfile('data',['ncep_' param '.mat']);
save(filename,'-v6','lat','lon','description','units');

%% Now get the files
nyear=length(years)
for i=1:nyear
  year=years(i);
  filename=fullfile('data',['ncep_' param '_' num2str(year) '.mat']);
  if exist(filename,'file') continue; end
    
  url=fullfile(base,[param '.sfc'],[param '.sfc.gauss.' num2str(year) '.d.qs_eurasia.97x48.dat.gz']);
  zipname=fullfile('data',['ncep_' param '_' num2str(year) '.dat.gz']);
  
  if ~exist(zipname,'file') [zipname,status]=urlwrite(url,zipname); end
  if ~exist(zipname,'file') warning('Could not retrieve file'); continue; end

  filename=strrep(zipname,'.gz','');
  if ~exist(filename)
    status=system(['gunzip ' filename]);
  end

  p=load(filename,'-ascii');
  nday=size(p,1)/nlat;
  day=1:nday;
  p=reshape(p,[nday,nlat,nlon]);
  filename=fullfile('data',['ncep_' param '_' num2str(year) '.mat']);
  save(filename,'-v6','lat','lon','description','units','p','day');
  
end

return
end