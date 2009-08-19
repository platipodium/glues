function result=read_result(filename)
% Reads a glues result file and dumps it to a matlab binary file
% regardless of endianness of result file

cl_register_function();

if nargin<1
  dir='/home/wirtz/glues/setup_686';
  file=fullfile(dir,'results.out');
else file=filename;
end

if ~exist(file,'file') 
  error('Result file does not exist');
  return; 
end

fid=fopen(file,'r');
nums=fread(fid,1,'uint8');  % number of variables
name='                            ';
resname=[name;name;name;name;name;name;name];
for i=1:nums    	% reading Varisble Names
  tline = fgetl(fid);
  vars{i}=tline(isletter(tline));
end;

nreg=fread(fid,1,'uint32');  % number of frames
tstart=fread(fid,1,'float');
tend=fread(fid,1,'float');
tstep=fread(fid,1,'float');
result = fread(fid,inf,'float');
fclose(fid);

fprintf('time = %1.3f %1.3f\n',tstart,tend);
toffset=500.0;
nstep=ceil((tend-tstart)/tstep);

fprintf('nstep = %d %1.3f\n',nstep,tstep);

%check time steps
tnum=length(result)/nums/nreg;
if tnum~=nstep
  if round(tnum)~=tnum
    fprintf('Error, incomplete record');
    return
  else
    fprintf('Warning, unexpected number of time steps (%d)\n',tnum);
    nstep=tnum;
    tend=tstart+tstep*(tnum-1);
  end
end

result=reshape(result,nreg,nums,nstep);

save('result','result','nstep','toffset','tend','tstart','tstep','nums','vars','nreg');

return
