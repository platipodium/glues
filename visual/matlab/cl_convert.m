function cl_convert(filename,varargin)
% Reads a glues result file and dumps it to a matlab binary file
% regardless of endianness of result file

error('Not yet functional, should replace read_result.m in the future');

cl_register_function();

arguments = {
};

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end


nreg=685;

[d,f]=get_files(nreg);

%% File opening in both big/little endian
if nargin<1
  file=fullfile(d.setup,'results.out');
elseif length(strfind(filename,'/'))>0
  file=filename;
else        
  file=fullfile(d.setup,filename);
end

if ~exist(file,'file') 
  warning('Result file %s does not exist',file);
  return; 
end

[d,f,e,x]=fileparts(file);

fid=fopen(file,'r','ieee-be');
frewind(fid);
nums=fread(fid,1,'uint8');
for i=1:nums
  tline = fgetl(fid);
  vars{i}=tline(isletter(tline));
end
nreg=fread(fid,1,'uint32'); 

if (nreg>1E5)
  fclose(fid);
  fid=fopen(file,'r','ieee-le');  
  frewind(fid);
  nums=fread(fid,1,'uint8');
  for i=1:nums
    tline = fgetl(fid);
    vars{i}=tline(isletter(tline));
  end
  nreg=fread(fid,1,'float32');
end

tstart=fread(fid,1,'float32');
tend=fread(fid,1,'float32');
tstep=fread(fid,1,'float32');
result = fread(fid,inf,'float32');
fclose(fid);


%% Quality checks on time and record length
toffset=500.0;
nstep=ceil((tend-tstart)/tstep);

%check time steps
tnum=length(result)/nums/nreg;
if tnum~=nstep
  if round(tnum)~=tnum
    error('Error, incomplete record');
    return
  else
    fprintf('Warning, unexpected number of time steps (%d)\n',tnum);
    nstep=tnum;
    tstep=(tend-tstart)/tnum;
    tend=tstart+tstep*(tnum-1);
  end
end

%% Reshape results
result=reshape(result,nreg,nums,nstep);

r.nreg=nreg;
r.tend=tend;
r.tstart=tstart;
r.tstep=tstep;
r.nstep=nstep;
r.numvar=nums;
r.variables=vars;
r.time=[tstart:tstep:tend];
for ivar=1:nums eval(['r.' vars{ivar} '= squeeze(result(:,ivar,:));']); end

if (str2num(version('-release'))<14) 
save(f,'r');%,'result','nstep','toffset','tend','tstart','tstep','nums','vars','nreg');
else
    save('-v6',f,'r');%,'result','nstep','toffset','tend','tstart','tstep','nums','vars','nreg');
end
if (nargout>0)
  res=r;
end

return
