function data=cl_load(varargin)
% CL_LOAD
% loads the argument file contents into the matlab workspace

cl_register_function();

fname=varargin{1};

if exist('CL_JOURNALING','var')
  if exist(fname,'file')
     fid=fopen(CL_JOURNAL,'a');
     fprintf(fid,'%s\n',fname);
     fclose(fid);
  end
end

data=load(varargin);
return
end
