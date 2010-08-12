function cl_get_indus_varves
%CL_GET_INDUS_VARVES  Retrieves Indus varves database

% Copyright 2010 Carsten Lemmen <carsten.lemmen@gkss.de>

cl_register_function;

base='http://doi.pangaea.de/10.1594/PANGAEA.63130';

%% Get README file
url=base;
filename=fullfile('data','indus_varves.html');
if ~exist(filename,'file') [f,status]=urlwrite(url,filename); end

%% Get data
url=[base '?format=textfile'];
filename=fullfile('data','indus_varves.tab');
if ~exist(filename,'file') [f,status]=urlwrite(url,filename);end

fid=fopen(filename,'r');
i=0;
while (~feof(fid))
  l=fgetl(fid);   
  if ~isnumeric(str2num(l(1))) continue; end
  i=i+1;
  %sscanf(l,'%f\t%d\t%f\t%f',ybp(i),year(i),depth(i),thick(i));
  d=sscanf(l,'%f\t%d\t%f\t%f');
  if isempty(d) continue; end
  ybp(i)=d(1);year(i)=d(2);depth(i)=d(3);thick(i)=d(4);
end

filename=fullfile('data','indus_varves.mat');
save('-v6',filename,'ybp','year','depth','thick');

return
end