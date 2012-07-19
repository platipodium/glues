function cl_read_steele2000(varargin)

% Spatial and Chronological Patterns in the Neolithisation of Europe
% James Steele, Stephen J. Shennan, 2000
% http://archaeologydataservice.ac.uk/archives/view/c14_meso/overview.cfm

basedir='../../data/Steele2000';
sep=',';

files=dir(fullfile(basedir,'*txt'));
nf=length(files);

for ifile=1:nf
  fid=fopen(fullfile(basedir,files(ifile).name),'rt');

  
  % Read header line
  header=fgetl(fid);
  nrows=length(findstr(header,sep))+1;
  format=repmat('%q',1,nrows);
  H=textscan(header,format,'Delimiter',sep);
  clear h;
  for i=1:nrows
    h(i)=cellstr(H{i});
  end
  
  F=textscan(fid,format,1,'Delimiter',sep);
  format='';
  for i=1:nrows
    f(i)=cellstr(F{i});
    if isempty(str2num(f{i})) format=horzcat(format,'%q'); 
    else format=horzcat(format,'%f');
    end
  end
  
  files(ifile).header=h;
  files(ifile).format=format;
  fclose(fid);
end

% Read data
for ifile=1:nf
  fid=fopen(fullfile(basedir,files(ifile).name),'rt');
  D=textscan(fid,files(ifile).format,'Headerlines',1,'Delimiter',sep);
  files(ifile).data=D;
  files(ifile).nrows=length(D{1});
  fclose(fid);
end

% Make one big table


return
end