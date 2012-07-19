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
  ncols=length(findstr(header,sep))+1;
  format=repmat('%q',1,ncols);
  H=textscan(header,format,'Delimiter',sep);
  clear h;
  for i=1:ncols
    h(i)=cellstr(H{i});
  end
  
  F=textscan(fid,format,1,'Delimiter',sep);
  format='';
  for i=1:ncols
    f(i)=cellstr(F{i});
    if isempty(str2num(f{i})) format=horzcat(format,'%q'); 
    else format=horzcat(format,'%f');
    end
  end
  
  files(ifile).ncols=ncols;
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

% sort those tables which have sample_id according to this id
for ifile=1:nf
  ih=strmatch('sample_id',files(ifile).header);
  if isempty(ih) continue; end
  
  [~,isort]=sort(files(ifile).data{ih});
  for i=1:files(ifile).ncols
      files(ifile).data{i}=files(ifile).data{i}(isort);
  end
  
end





save('Steele2000','files');



return
end