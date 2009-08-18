function line=grep(filename,pattern)

cl_register_function();

if ~exist('filename','var') filename='test.red'; end
if ~exist('pattern','var') pattern='Thomson'; end;

fid = fopen(filename);
if fid<0 return; end;

fl = fgetl(fid);

while (~feof(fid))
  pos=strfind(fl,pattern);
  if ~isempty(pos) line=fl; break; end
  fl=fgetl(fid); 
end;

return;
