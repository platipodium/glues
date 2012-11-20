function shape=cl_shapezoom(varargin)
% Reads a shape file or associated mat file and selects a rectangular area
% delimited by latlim and lonlim from this file. Saves zoomed file as shape
% and matlab


arguments = {...
  {'filename','/Users/lemmen/devel/glues/data/naturalearth/ne_10m_rivers_lake_centerlines.shp'},...
  {'noreplace',0},...
  {'latlim',[-90 90]},...
  {'lonlim',[-180 180]},...
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length 
  lv=length(a.value{i});
  if (lv>1 & iscell(a.value{i}))
    for j=1:lv
      eval( [a.name{i} '{' num2str(j) '} = ''' char(clp_valuestring(a.value{i}(j))) ''';']);         
    end
  else
    eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); 
  end
end

latlim=[-40 -20]; lonlim=[10 30];


[filedir filebase fileext] = fileparts(filename);
if ~exist(filename,'file')
  if strncmp(fileext,'.shp',4) 
    filename=strrep(filename,'.shp','.mat');
  else filename=strrep(filename,'.mat','.shp');
  end
  [filedir filebase fileext] = fileparts(filename);
  if ~exist(filename,'file')
    error('File does not exist'); 
  end
end

infix=sprintf('%04d_%04d_%03d_%03d',lonlim,latlim);
if noreplace
  if exist(strrep(filename,fileext,['_' infix fileext]),'file'); return;
  end
end


if strncmp(fileext,'.mat',4)
  load(filename);
else
  shape=shaperead(filename);
end  

k=0;
try
for i=1:length(shape);
  lat=shape(i).Y;
  lon=shape(i).X;
  j=find(lat>=latlim(1) & lat<=latlim(2) & lon>=lonlim(1) & lon<=lonlim(2));
  if isempty(j) continue; end
  k=k+1;
  nshape(k)=shape(i);
  nshape(k).X=[lon(j) NaN];
  nshape(k).Y=[lat(j) NaN];
  nshape(k).BoundingBox=[[min(lon(j)) min(lat(j))];[max(lon(j)) max(lat(j))]];
end

shape=nshape;
filename=strrep(filename,fileext,['_' infix fileext]);
if strncmp(fileext,'.mat',4)
  save(filename,'shape');
else
  shapewrite(shape,filename);
end
%save(fullfile(filedir,filebase),'shape');

catch
    warning('File %s not read, skipped',filename);
end

return;
end
